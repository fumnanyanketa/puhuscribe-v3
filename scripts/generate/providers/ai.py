"""The one AI module of the content pipeline (job 7-content-pipeline, "Done when" 3 and 4).

This is the only file in the pipeline that imports the `anthropic` package or
calls an AI address. AI_PROVIDER picks the provider:

- `anthropic`: Claude through the Anthropic API, with structured JSON outputs.
  The key comes from ANTHROPIC_API_KEY (a GitHub secret in the pipeline
  workflow, or .env.local); it is never logged or printed.
- `fake`: replays recorded responses from a JSON file, so every test runs
  offline with the network switched off.

Every call, real or fake, appends one line to content/logs/ai-calls.jsonl:
time, purpose, model, input and output tokens, cost in US dollars and the
dialogue slug. The log is written here, inside the one function every call goes
through, so no call can skip it. It never holds a key or any prompt text.
"""

from __future__ import annotations

import json
import os
from datetime import UTC, datetime
from pathlib import Path

REPO = Path(__file__).resolve().parents[3]
DEFAULT_LOG = REPO / "content" / "logs" / "ai-calls.jsonl"

PURPOSES = ("draft", "why", "judge")

# Model per purpose (spec: Opus for drafting and the "why" lines, Sonnet for the judge).
MODELS = {"draft": "claude-opus-5-5", "why": "claude-opus-5-5", "judge": "claude-sonnet-5-5"}
EFFORT = {"draft": "high", "why": "high", "judge": "medium"}

# US dollars per million tokens. Source: Anthropic's pricing page,
# https://platform.claude.com/docs/en/about-claude/pricing, read 21 October 2026.
PRICES_DATE = "2026-10-21"
PRICES_PER_MILLION = {
    "claude-opus-5-5": {"input": 4.00, "output": 20.00},
    "claude-sonnet-5-5": {"input": 2.00, "output": 10.00},
}

MAX_TOKENS = 16000


class AiError(RuntimeError):
    """An AI call failed. The message never holds a key or the prompt."""


def cost_usd(model: str, input_tokens: int, output_tokens: int) -> float:
    if model not in PRICES_PER_MILLION:
        raise AiError(f"no price for model {model} in the price table; add it before using the model")
    price = PRICES_PER_MILLION[model]
    return round((input_tokens * price["input"] + output_tokens * price["output"]) / 1_000_000, 6)


class _Provider:
    name = ""

    def __init__(self, log_path: Path | str | None = None) -> None:
        self.log_path = Path(log_path) if log_path else DEFAULT_LOG

    def complete_json(self, *, purpose: str, dialogue: str, system: str, prompt: str, schema: dict) -> dict:
        """Ask for JSON that follows `schema`. Logs the call with its cost, then returns the JSON."""
        if purpose not in PURPOSES:
            raise AiError(f"unknown AI purpose '{purpose}'")
        model = MODELS[purpose]
        text, input_tokens, output_tokens, problem = self._call(purpose, model, system, prompt, schema)
        self._log(purpose, model, input_tokens, output_tokens, dialogue)
        if problem:
            raise AiError(problem)
        try:
            data = json.loads(text)
        except json.JSONDecodeError as err:
            raise AiError(f"the {purpose} answer was not valid JSON ({err.msg})") from err
        if not isinstance(data, dict):
            raise AiError(f"the {purpose} answer was not a JSON object")
        return data

    def _log(self, purpose: str, model: str, input_tokens: int, output_tokens: int, dialogue: str) -> None:
        line = {
            "time": datetime.now(UTC).strftime("%Y-%m-%dT%H:%M:%SZ"),
            "provider": self.name,
            "purpose": purpose,
            "model": model,
            "input_tokens": input_tokens,
            "output_tokens": output_tokens,
            "cost_usd": cost_usd(model, input_tokens, output_tokens),
            "prices_date": PRICES_DATE,
            "dialogue": dialogue,
        }
        self.log_path.parent.mkdir(parents=True, exist_ok=True)
        with open(self.log_path, "a", encoding="utf-8", newline="\n") as fh:
            fh.write(json.dumps(line, ensure_ascii=False) + "\n")

    def _call(
        self, purpose: str, model: str, system: str, prompt: str, schema: dict
    ) -> tuple[str, int, int, str | None]:
        """Returns the answer text, the input and output tokens, and a problem (or None)."""
        raise NotImplementedError


class AnthropicProvider(_Provider):
    name = "anthropic"

    def __init__(self, log_path: Path | str | None = None) -> None:
        super().__init__(log_path)
        if not os.environ.get("ANTHROPIC_API_KEY", "").strip():
            raise AiError("ANTHROPIC_API_KEY is not set, so the anthropic provider cannot run")
        import anthropic  # only here: the fake provider and the tests never need it

        self._anthropic = anthropic
        self._client = anthropic.Anthropic()

    def _call(
        self, purpose: str, model: str, system: str, prompt: str, schema: dict
    ) -> tuple[str, int, int, str | None]:
        try:
            response = self._client.messages.create(
                model=model,
                max_tokens=MAX_TOKENS,
                system=system,
                messages=[{"role": "user", "content": prompt}],
                output_config={
                    "effort": EFFORT[purpose],
                    "format": {"type": "json_schema", "schema": schema},
                },
            )
        except self._anthropic.APIStatusError as err:
            raise AiError(f"the Anthropic API refused the {purpose} call (HTTP {err.status_code})") from None
        except self._anthropic.APIConnectionError:
            raise AiError(f"could not reach the Anthropic API for the {purpose} call") from None
        usage = response.usage
        # No prompt caching is used, so cache tokens are normally 0. If any appear
        # they are counted at the full input price, which can only overstate the cost.
        input_tokens = int(usage.input_tokens or 0) + int(
            getattr(usage, "cache_creation_input_tokens", 0) or 0
        )
        input_tokens += int(getattr(usage, "cache_read_input_tokens", 0) or 0)
        output_tokens = int(usage.output_tokens or 0)
        problem = None
        if response.stop_reason == "refusal":
            problem = f"the model declined the {purpose} call"
        elif response.stop_reason == "max_tokens":
            problem = f"the {purpose} answer was cut off at {MAX_TOKENS} tokens"
        text = "".join(block.text for block in response.content if getattr(block, "type", None) == "text")
        return text, input_tokens, output_tokens, problem


class FakeProvider(_Provider):
    """Replays recorded responses in order. The file holds {"calls": [...]}, each call
    {"purpose", "output", "input_tokens", "output_tokens"}. A call whose purpose does not
    match the next recording fails, so a test cannot pass on the wrong answer."""

    name = "fake"

    def __init__(self, recording: Path | str | dict, log_path: Path | str | None = None) -> None:
        super().__init__(log_path)
        if isinstance(recording, dict):
            data = recording
        else:
            with open(recording, encoding="utf-8") as fh:
                data = json.load(fh)
        self._calls = list(data["calls"])
        self.prompts: list[dict] = []

    def remaining(self) -> int:
        return len(self._calls)

    def _call(
        self, purpose: str, model: str, system: str, prompt: str, schema: dict
    ) -> tuple[str, int, int, str | None]:
        if not self._calls:
            raise AiError(f"the fake provider has no recorded response left for a {purpose} call")
        call = self._calls.pop(0)
        if call["purpose"] != purpose:
            raise AiError(f"the fake provider expected a {call['purpose']} call, got a {purpose} call")
        self.prompts.append({"purpose": purpose, "system": system, "prompt": prompt})
        return (
            json.dumps(call["output"], ensure_ascii=False),
            call["input_tokens"],
            call["output_tokens"],
            None,
        )


def get_provider(log_path: Path | str | None = None) -> _Provider:
    """The provider AI_PROVIDER names. The fake reads AI_FAKE_RECORDING."""
    choice = os.environ.get("AI_PROVIDER", "")
    if choice == "anthropic":
        return AnthropicProvider(log_path)
    if choice == "fake":
        recording = os.environ.get("AI_FAKE_RECORDING", "")
        if not recording:
            raise AiError("AI_PROVIDER is fake but AI_FAKE_RECORDING names no recording file")
        return FakeProvider(recording, log_path)
    raise AiError("AI_PROVIDER must be 'anthropic' or 'fake'")
