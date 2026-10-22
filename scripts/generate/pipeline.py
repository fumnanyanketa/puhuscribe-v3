"""The content pipeline's command line (job 7-content-pipeline). Needs Linux with Voikko.

python scripts/generate/pipeline.py run --brief content/briefs/<slug>.json --out <folder>
    Brief to review pack: draft, checks, audio and the round 1 review page.
    Needs AI_PROVIDER and VOICE_PROVIDER (the manual GitHub workflow sets them).

python scripts/generate/pipeline.py next-round --draft content/drafts/<slug> [--out <folder>]
    Reads the reviewer's latest file from content/reviews/<slug>/, refuses it with
    plain reasons or applies its fixes, runs the checks and the audio again for the
    changed lines only, and writes the next round's page.

python scripts/generate/pipeline.py publish --draft content/drafts/<slug>
    Writes the publish migration and copies the reviewed audio to public/audio/,
    only when every check passes and every item is approved.

python scripts/generate/pipeline.py check-committed
    Runs the automatic checks (statements 7 to 11 and 21) offline on every committed
    draft and every published dialogue. The Python check runs it on every pull request.

python scripts/generate/pipeline.py judge-golden --out <file>
    Runs the AI judge on the golden set of 20 pairs and writes the result.
"""

from __future__ import annotations

import argparse
import json
import shutil
import sys
from pathlib import Path

from analysis import frequency_ranks
from audio import RECORDINGS, make_audio, recording_path
from brief import BriefError, load_brief, validate_brief
from content_checks import load_thresholds, run_checks
from drafting import LINKS_SCHEMA, DraftFailed, draft_dialogue, enrich, set_links
from judge import GOLDEN_PATH, evaluate_golden
from providers import ai as ai_module
from providers import voice as voice_module
from publish import PublishRefused, publish
from review_import import ReviewRefused, approvals, load_manifest, read_round, review_files
from review_page import write_round
from voikko_gate import VoikkoGate

REPO = Path(__file__).resolve().parents[2]
DRAFTS = REPO / "content" / "drafts"
REVIEWS = REPO / "content" / "reviews"
AI_LOG = REPO / "content" / "logs" / "ai-calls.jsonl"


class Run:
    """Collects the run's log lines; written to run.log in the output folder."""

    def __init__(self) -> None:
        self.lines: list[str] = []

    def __call__(self, message: str) -> None:
        print(message, flush=True)
        self.lines.append(message)

    def save(self, folder: Path) -> None:
        folder.mkdir(parents=True, exist_ok=True)
        (folder / "run.log").write_text("\n".join(self.lines) + "\n", encoding="utf-8", newline="\n")


def write_json(path: Path, value: object) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n", encoding="utf-8", newline="\n")


def read_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def log_size() -> int:
    return len(AI_LOG.read_text(encoding="utf-8").splitlines()) if AI_LOG.is_file() else 0


def copy_new_log_lines(before: int, folder: Path) -> None:
    """Put this run's cost log lines next to the review pack (the manager commits them)."""
    if AI_LOG.is_file():
        new = AI_LOG.read_text(encoding="utf-8").splitlines()[before:]
        (folder / "ai-calls.jsonl").write_text(
            "".join(f"{line}\n" for line in new), encoding="utf-8", newline="\n"
        )


def cmd_run(args, gate=None, ai=None, voice=None, recordings: Path = RECORDINGS) -> int:
    out = Path(args.out)
    log = Run()
    before = log_size()
    try:
        brief = load_brief(args.brief)
    except (BriefError, OSError) as err:
        log(f"The brief cannot be used: {err}")
        log.save(out)
        return 1
    gate = gate or VoikkoGate()
    ai = ai or ai_module.get_provider()
    voice = voice or voice_module.get_provider()
    ranks = frequency_ranks()
    thresholds = load_thresholds()
    try:
        draft, report = draft_dialogue(brief, Path(args.brief).as_posix(), ai, gate, ranks, thresholds, log)
    except DraftFailed as failed:
        log("The draft still fails after the last round. No review pack was made. Failing words and lines:")
        for problem in failed.failures:
            log(f"  {problem}")
        write_json(out / "check-report.json", {"ok": False, "failures": failed.failures})
        if failed.draft:
            write_json(out / "failed-draft.json", failed.draft)
        copy_new_log_lines(before, out)
        log.save(out)
        return 1
    draft["providers"]["voice"] = voice.name
    log("Making audio for both registers")
    make_audio(draft, out, voice, recordings, log=log)
    write_json(out / "draft.json", draft)
    write_json(out / "check-report.json", report)
    page, _ = write_round(draft, out, {}, 1)
    log(f"Review page: {page.relative_to(out).as_posix()}")
    copy_new_log_lines(before, out)
    log.save(out)
    return 0


def apply_fixes(draft: dict, entries: dict[str, dict]) -> tuple[set[int], bool]:
    """Apply the reviewer's fixes. Returns the changed line numbers and whether a "why" changed."""
    changed: set[int] = set()
    why_changed = False
    forms = {f["id"]: f for f in draft["forms"]}
    for item_id, entry in entries.items():
        if entry.get("decision") != "fix":
            continue
        if item_id.startswith("line-"):
            n = int(item_id.split("-")[1])
            line = draft["lines"][n - 1]
            for field in ("text_puhe", "text_kirja", "gloss_en"):
                line[field] = entry["fix"][field].strip()
            line.pop("judge", None)
            changed.add(n)
        elif item_id in forms:
            forms[item_id]["why_en"] = entry["fix"]["why_en"].strip()
            why_changed = True
    return changed, why_changed


RELINK_SYSTEM = """A native Finnish reviewer corrected some dialogue lines. For each line, give \
puhe_links: one number for each spoken word, in order (words are separated by spaces, punctuation \
does not count). The number is the position of the written word it renders (1 is the first \
written word), or 0 for a spoken only word. Each written word is rendered by exactly one spoken \
word. Do not change any text."""


def relink(draft: dict, changed: set[int], ai, gate) -> None:
    lines = [line for line in draft["lines"] if line["n"] in changed]
    prompt = "\n".join(
        f'Line {line["n"]}: written "{line["text_kirja"]}" | spoken "{line["text_puhe"]}"' for line in lines
    )
    answer = ai.complete_json(
        purpose="draft",
        dialogue=draft["brief"]["dialogue"]["slug"],
        system=RELINK_SYSTEM,
        prompt=prompt,
        schema=LINKS_SCHEMA,
    )
    links = {item.get("n"): item.get("puhe_links", []) for item in answer.get("lines", [])}
    for line in lines:
        set_links(line, links.get(line["n"], []), gate)
        line.pop("link_count_ok", None)


def cmd_next_round(
    args, gate=None, ai=None, voice=None, repo: Path = REPO, recordings: Path = RECORDINGS
) -> int:
    draft_dir = Path(args.draft)
    out = Path(args.out) if args.out else draft_dir
    log = Run()
    before = log_size()
    draft = read_json(draft_dir / "draft.json")
    try:
        validate_brief(draft["brief"])
    except BriefError as err:
        log(f"The draft's brief is not valid, so nothing was read or written: {err}")
        log.save(out)
        return 1
    slug = draft["brief"]["dialogue"]["slug"]
    reviews_dir = (
        Path(args.reviews) if getattr(args, "reviews", None) else repo / "content" / "reviews" / slug
    )
    try:
        files = review_files(reviews_dir)
        if not files:
            raise ReviewRefused([f"there is no review file in {reviews_dir.as_posix()}"])
        number, path, review = files[-1]
        manifest = load_manifest(draft_dir, number)
        entries = read_round(
            review,
            manifest,
            slug,
            lambda line, register: recording_path(recordings, slug, line, register).is_file(),
        )
    except ReviewRefused as refused:
        log("The review file was refused:")
        for reason in refused.reasons:
            log(f"  {reason}")
        log.save(out)
        return 1
    log(f"Read {path.name} (round {number}, reviewer {review['reviewer_code']})")
    if out != draft_dir:
        shutil.copytree(draft_dir, out, dirs_exist_ok=True)
    changed, why_changed = apply_fixes(draft, entries)
    rerecorded = {
        (int(item_id.split("-")[1]), item_id.split("-")[2])
        for item_id, entry in entries.items()
        if item_id.startswith("audio-") and entry.get("verdict") == "wrong"
    }
    if not changed and not why_changed and not rerecorded:
        log("Every item in this round is approved. Ready to publish.")
        log.save(out)
        return 0
    gate = gate or VoikkoGate()
    ranks = frequency_ranks()
    thresholds = load_thresholds()
    if changed:
        ai = ai or ai_module.get_provider()
        log(f"Lines changed by the reviewer: {', '.join(str(n) for n in sorted(changed))}")
        relink(draft, changed, ai, gate)
        failures = enrich(draft, ai, gate, only=changed)
    else:
        failures = []
    report = run_checks(draft, gate, ranks, thresholds)
    failures += report["failures"]
    if failures:
        log("The corrected draft fails these checks. No next round page was made:")
        for problem in failures:
            log(f"  {problem}")
        write_json(out / "check-report.json", {"ok": False, "failures": failures})
        copy_new_log_lines(before, out)
        log.save(out)
        return 1
    redo = {(n, register) for n in changed for register in ("puhe", "kirja")} | rerecorded
    if redo:
        voice = voice or voice_module.get_provider()
        make_audio(draft, out, voice, recordings, only=redo, log=log)
    write_json(out / "draft.json", draft)
    write_json(out / "check-report.json", report)
    approved = {item_id: a["fingerprint"] for item_id, a in approvals(files, repo).items()}
    page, _ = write_round(draft, out, approved, number + 1)
    log(f"Next round page: {page.name}")
    copy_new_log_lines(before, out)
    log.save(out)
    return 0


def cmd_publish(args, gate=None, repo: Path = REPO) -> int:
    draft_dir = Path(args.draft)
    draft = read_json(draft_dir / "draft.json")
    try:
        validate_brief(draft["brief"])
    except BriefError as err:
        print(f"Not published. The draft's brief is not valid: {err}")
        return 1
    slug = draft["brief"]["dialogue"]["slug"]
    try:
        migration, audio = publish(
            draft,
            draft_dir,
            repo / "content" / "reviews" / slug,
            gate or VoikkoGate(),
            frequency_ranks(),
            load_thresholds(),
            repo,
        )
    except PublishRefused as refused:
        print("Not published. Every reason:")
        for reason in refused.reasons:
            print(f"  {reason}")
        return 1
    print(f"Wrote {migration.relative_to(repo).as_posix()} and {len(audio)} audio files under public/audio/")
    return 0


def committed_dialogues(repo: Path = REPO) -> list[Path]:
    """Every committed draft folder (content/drafts/<slug>/draft.json)."""
    return sorted(p.parent for p in (repo / "content" / "drafts").glob("*/draft.json"))


def published_slugs(repo: Path = REPO) -> list[str]:
    return sorted(
        p.stem.split("_publish_", 1)[1].replace("_", "-")
        for p in (repo / "supabase" / "migrations").glob("*_publish_*.sql")
    )


def cmd_check_committed(args, gate=None, repo: Path = REPO) -> int:
    gate = gate or VoikkoGate()
    ranks = frequency_ranks()
    thresholds = load_thresholds()
    drafts = committed_dialogues(repo)
    failed = False
    have = {d.name for d in drafts}
    for slug in published_slugs(repo):
        if slug not in have:
            print(f"{slug}: published, but its draft is not in content/drafts/{slug}/")
            failed = True
    for folder in drafts:
        report = run_checks(read_json(folder / "draft.json"), gate, ranks, thresholds)
        state = "passes" if report["ok"] else "FAILS"
        print(f"{folder.name}: {state} every check")
        for problem in report["failures"]:
            print(f"  {problem}")
        failed = failed or not report["ok"]
    if not drafts:
        print("No committed drafts yet.")
    return 1 if failed else 0


def cmd_judge_golden(args, ai=None) -> int:
    ai = ai or ai_module.get_provider()
    result = evaluate_golden(ai, read_json(GOLDEN_PATH), load_thresholds())
    write_json(Path(args.out), result)
    print(
        f"Changed pairs caught: {result['changed_caught']} of {result['changed_total']}. "
        f"Faithful pairs accepted: {result['faithful_accepted']} of {result['faithful_total']}. "
        f"{'Passed' if result['passed'] else 'FAILED'}."
    )
    return 0 if result["passed"] else 1


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description="PuhuScribe content pipeline")
    sub = parser.add_subparsers(dest="command", required=True)
    run = sub.add_parser("run")
    run.add_argument("--brief", required=True)
    run.add_argument("--out", required=True)
    nxt = sub.add_parser("next-round")
    nxt.add_argument("--draft", required=True)
    nxt.add_argument("--out")
    pub = sub.add_parser("publish")
    pub.add_argument("--draft", required=True)
    sub.add_parser("check-committed")
    golden = sub.add_parser("judge-golden")
    golden.add_argument("--out", required=True)
    args = parser.parse_args(argv)
    commands = {
        "run": cmd_run,
        "next-round": cmd_next_round,
        "publish": cmd_publish,
        "check-committed": cmd_check_committed,
        "judge-golden": cmd_judge_golden,
    }
    try:
        return commands[args.command](args)
    except (ai_module.AiError, voice_module.VoiceError) as err:
        print(f"Stopped: {err}")
        return 1


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
