"""Publishing a reviewed dialogue (job 7-content-pipeline, "Done when" 15).

Only when every automatic check passes and the reviewer's files approve every
current item does publish() write

- supabase/migrations/<timestamp>_publish_<dialogue_slug>.sql, and
- each approved line's two clips to public/audio/<key>, where the key is
  <dialogue-slug>/<line>-<register>-<first 12 characters of the file's SHA-256>.mp3.

Each approval_ref is the review file path plus the item id. The migration
follows the order in docs/data-model.md (forms, lines with their words, the
dialogue, the unit) and does nothing when the dialogue is already published, so
running it twice changes nothing. Any missing precondition writes nothing.
"""

from __future__ import annotations

import shutil
from datetime import UTC, datetime
from pathlib import Path

from brief import BriefError, validate_brief
from content_checks import run_checks
from fingerprints import sha256_bytes
from review_import import approvals, open_fixes, review_files
from review_items import DIALOGUE_ITEM, all_items, audio_item_id, clip_path, line_item_id

REPO = Path(__file__).resolve().parents[2]


class PublishRefused(RuntimeError):
    def __init__(self, reasons: list[str]):
        super().__init__("; ".join(reasons))
        self.reasons = reasons


# The migration's code block is quoted with this tag. Postgres ends the block at
# the first copy of it, even inside a quoted string, so no published value may
# hold it (security review, round 2).
DOLLAR_TAG = "$publish$"


def sql_text(value: str | None) -> str:
    """A SQL string literal (standard_conforming_strings is on in Postgres)."""
    if value is None:
        return "null"
    if "\x00" in value:
        raise ValueError("text with a NUL character cannot be published")
    if DOLLAR_TAG in value:
        raise ValueError(f"text holding {DOLLAR_TAG} cannot be published")
    return "'" + value.replace("'", "''") + "'"


def _strings(value: object, where: str):
    """Every text inside a value, with where it is."""
    if isinstance(value, str):
        yield where, value
    elif isinstance(value, dict):
        for key, inner in value.items():
            yield from _strings(inner, f"{where}.{key}")
    elif isinstance(value, list):
        for i, inner in enumerate(value, start=1):
            yield from _strings(inner, f"{where}[{i}]")


def unsafe_texts(draft: dict) -> list[str]:
    """Plain reasons for every published text that holds the migration's dollar quote tag."""
    parts = {"brief": draft["brief"], "lines": draft["lines"], "forms": draft["forms"]}
    return [
        f"{where} holds {DOLLAR_TAG}, which would end the migration's code block"
        for where, text in _strings(parts, "draft")
        if DOLLAR_TAG in text
    ]


def audio_key(slug: str, line: int, register: str, sha256: str) -> str:
    return f"{slug}/{line}-{register}-{sha256[:12]}.mp3"


def build_sql(draft: dict, refs: dict[str, str], keys: dict[tuple[int, str], str], source: str) -> str:
    """The publish migration. refs maps item ids (and "unit") to approval references."""
    brief = draft["brief"]
    unit, dialogue = brief["unit"], brief["dialogue"]
    slug = dialogue["slug"]
    out = [
        f"-- Publishes the dialogue {slug} (unit {unit['slug']}). Made by",
        f"-- scripts/generate/pipeline.py publish from {source}. Do not edit by hand:",
        "-- change the draft, get the changed items reviewed again and publish again.",
        '-- Job 7-content-pipeline, "Done when" 15. Order (docs/data-model.md): forms, then',
        "-- the lines with their words, then the dialogue, then the unit. Running it a second",
        "-- time does nothing, because the dialogue is then already approved.",
        "do $publish$",
        "declare",
        "  v_unit_id bigint;",
        "  v_dialogue_id bigint;",
        "  v_line_id bigint;",
        "  v_status public.content_status;",
        "begin",
        "  if exists (select 1 from public.dialogues",
        f"    where slug = {sql_text(slug)} and status = 'approved') then",
        f"    raise notice 'dialogue % is already published; nothing to do', {sql_text(slug)};",
        "    return;",
        "  end if;",
        "",
        "  -- The unit, as a draft until the end.",
        "  insert into public.units (slug, position, title_en, can_do_en)",
        f"  values ({sql_text(unit['slug'])}, {int(unit['position'])}, {sql_text(unit['title_en'])}, "
        f"{sql_text(unit['can_do_en'])})",
        "  on conflict (slug) do nothing;",
        "  select id, status into strict v_unit_id, v_status from public.units",
        f"  where slug = {sql_text(unit['slug'])} and position = {int(unit['position'])}",
        f"    and title_en = {sql_text(unit['title_en'])} and can_do_en = {sql_text(unit['can_do_en'])};",
        "  if v_status = 'retired' then",
        f"    raise exception 'unit % is retired', {sql_text(unit['slug'])};",
        "  end if;",
        "",
        "  -- The dialogue, as a draft until its lines are approved.",
        "  insert into public.dialogues (unit_id, slug, position, title_en)",
        f"  values (v_unit_id, {sql_text(slug)}, {int(dialogue['position'])},",
        f"    {sql_text(dialogue['title_en'])})",
        "  on conflict (slug) do nothing;",
        "  select id into strict v_dialogue_id from public.dialogues",
        f"  where slug = {sql_text(slug)} and unit_id = v_unit_id and status = 'draft'",
        f"    and position = {int(dialogue['position'])} and title_en = {sql_text(dialogue['title_en'])};",
        "  if exists (select 1 from public.dialogue_lines where dialogue_id = v_dialogue_id) then",
        "    raise exception 'dialogue % already has lines; fix them through the review rounds',",
        f"      {sql_text(slug)};",
        "  end if;",
        "",
        "  -- 1. Forms, approved. An existing form must already be approved.",
    ]
    for form in draft["forms"]:
        identity = (
            f"lemma = {sql_text(form['lemma'])} and form_tag = {sql_text(form['form_tag'])} "
            f"and surface_kirja = {sql_text(form['surface_kirja'])} "
            f"and surface_puhe = {sql_text(form['surface_puhe'])}"
        )
        analysis = sql_text(_json(form.get("analysis", {})))
        out += [
            "  insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,",
            "    form_name_en, why_en, status, approved_at, approval_ref)",
            f"  values ({sql_text(form['lemma'])}, {sql_text(form['form_tag'])}, {analysis}::jsonb,",
            f"    {sql_text(form['surface_kirja'])}, {sql_text(form['surface_puhe'])},",
            f"    {sql_text(form['form_name_en'])},",
            f"    {sql_text(form['why_en'])}, 'approved', now(), {sql_text(refs[form['id']])})",
            "  on conflict (lemma, form_tag, surface_kirja, surface_puhe) do nothing;",
            f"  if not exists (select 1 from public.forms where {identity} and status = 'approved') then",
            "    raise exception 'form % (%) exists but is not approved',",
            f"      {sql_text(form['surface_kirja'])}, {sql_text(form['lemma'])};",
            "  end if;",
        ]
    out += ["", "  -- 2. Lines with their words, each approved after its words are in."]
    for line in draft["lines"]:
        n = line["n"]
        out += [
            "  insert into public.dialogue_lines (dialogue_id, position, speaker, text_puhe, text_kirja,",
            "    gloss_en, audio_puhe_key, audio_kirja_key)",
            f"  values (v_dialogue_id, {n}, {sql_text(line['speaker'])}, {sql_text(line['text_puhe'])},",
            f"    {sql_text(line['text_kirja'])}, {sql_text(line['gloss_en'])},",
            f"    {sql_text(keys[(n, 'puhe')])}, {sql_text(keys[(n, 'kirja')])})",
            "  returning id into v_line_id;",
        ]
        forms = {f["id"]: f for f in draft["forms"]}
        rows = []
        for register, toks in (("kirja", line["kirja_tokens"]), ("puhe", line["puhe_tokens"])):
            for position, tok in enumerate(toks, start=1):
                if register == "kirja":
                    form = forms.get(tok.get("form") or "")
                else:
                    target = tok.get("kirja")
                    linked = line["kirja_tokens"][target - 1] if isinstance(target, int) else {}
                    form = forms.get(linked.get("form") or "")
                rows.append((register, position, tok["surface"], form))
        out.append("  insert into public.tokens (line_id, register, position, surface, form_id)")
        values = []
        for register, position, surface, form in rows:
            form_sql = "null"
            if form is not None:
                form_sql = (
                    f"(select id from public.forms where lemma = {sql_text(form['lemma'])} "
                    f"and form_tag = {sql_text(form['form_tag'])} "
                    f"and surface_kirja = {sql_text(form['surface_kirja'])} "
                    f"and surface_puhe = {sql_text(form['surface_puhe'])})"
                )
            values.append(f"    (v_line_id, '{register}', {position}, {sql_text(surface)}, {form_sql})")
        out.append("  values\n" + ",\n".join(values) + ";")
        out += [
            "  update public.dialogue_lines set status = 'approved', approved_at = now(),",
            f"    approval_ref = {sql_text(refs[line_item_id(n)])}",
            "  where id = v_line_id;",
        ]
    out += [
        "",
        "  -- 3. The dialogue, now that every line is approved.",
        "  update public.dialogues set status = 'approved', approved_at = now(),",
        f"    approval_ref = {sql_text(refs[DIALOGUE_ITEM])}",
        "  where id = v_dialogue_id;",
        "",
        "  -- 4. The unit, unless an earlier dialogue already published it.",
        "  if v_status = 'draft' then",
        "    update public.units set status = 'approved', approved_at = now(),",
        f"      approval_ref = {sql_text(refs['unit'])}",
        "    where id = v_unit_id;",
        "  end if;",
        "end",
        "$publish$;",
        "",
    ]
    return "\n".join(out)


def _json(value: object) -> str:
    import json

    return json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":"))


def preconditions(
    draft: dict,
    draft_dir: Path,
    reviews_dir: Path,
    repo: Path,
    gate,
    ranks,
    thresholds,
    allow_fake: bool = False,
) -> tuple[dict[str, str], dict[tuple[int, str], str], list[str]]:
    """Check everything publishing needs.

    Returns the approval refs, the audio keys and every reason it cannot publish."""
    reasons: list[str] = []
    try:
        validate_brief(draft["brief"])
    except BriefError as err:
        reasons.append(f"the draft's brief is not valid: {err}")
    reasons += unsafe_texts(draft)
    providers = draft.get("providers", {})
    if not allow_fake and providers.get("ai") != "anthropic":
        reasons.append("the draft was not made by the real AI provider (fake drafts are for tests only)")
    report = run_checks(draft, gate, ranks, thresholds)
    reasons += [f"check failed: {f}" for f in report["failures"]]

    files = review_files(reviews_dir)
    if not files:
        reasons.append(f"there is no review file in {reviews_dir.as_posix()}")
    fixes = open_fixes(files)
    if fixes:
        reasons.append(
            f"the latest review still has open fixes ({', '.join(fixes)}): apply them in a next round"
        )
    found = approvals(files, repo)
    items = all_items(draft)
    latest_round = files[-1][0] if files else None
    refs: dict[str, str] = {}
    for item_id, item in items.items():
        approval = found.get(item_id)
        if approval is None:
            reasons.append(f"item {item_id} is not approved by the reviewer")
        elif approval["fingerprint"] != item["fingerprint"]:
            reasons.append(f"item {item_id} changed after the reviewer approved it")
        elif item_id == DIALOGUE_ITEM and approval["round"] != latest_round:
            reasons.append("the dialogue as a whole was not approved in the latest round")
        else:
            refs[item_id] = approval["ref"]
    if DIALOGUE_ITEM in refs:
        refs["unit"] = refs[DIALOGUE_ITEM]

    slug = draft["brief"]["dialogue"]["slug"]
    keys: dict[tuple[int, str], str] = {}
    for line in draft["lines"]:
        for register in ("puhe", "kirja"):
            audio = line.get("audio", {}).get(register)
            if audio is None:
                reasons.append(f"line {line['n']} has no {register} audio")
                continue
            if not allow_fake and audio.get("provider") == "fake":
                reasons.append(f"line {line['n']} {register} audio comes from the fake voice provider")
            if audio.get("file") != clip_path(line["n"], register):
                reasons.append(f"line {line['n']} {register} audio must be {clip_path(line['n'], register)}")
                continue
            path = draft_dir / audio["file"]
            if not path.is_file():
                reasons.append(f"the audio file {audio['file']} is missing")
                continue
            digest = sha256_bytes(path.read_bytes())
            if digest != audio["sha256"]:
                reasons.append(f"the audio file {audio['file']} changed after it was made")
                continue
            if audio_item_id(line["n"], register) not in refs:
                continue
            keys[(line["n"], register)] = audio_key(slug, line["n"], register, digest)
    return refs, keys, reasons


def publish(
    draft: dict,
    draft_dir: Path,
    reviews_dir: Path,
    gate,
    ranks,
    thresholds,
    repo: Path = REPO,
    timestamp: str | None = None,
    allow_fake: bool = False,
) -> tuple[Path, list[Path]]:
    """Write the migration and copy the audio, or raise PublishRefused and write nothing."""
    refs, keys, reasons = preconditions(
        draft, draft_dir, reviews_dir, repo, gate, ranks, thresholds, allow_fake
    )
    if reasons:
        raise PublishRefused(reasons)
    slug = draft["brief"]["dialogue"]["slug"]
    stamp = timestamp or datetime.now(UTC).strftime("%Y%m%d%H%M%S")
    migrations = repo / "supabase" / "migrations"
    existing = sorted(migrations.glob(f"*_publish_{slug.replace('-', '_')}.sql"))
    if existing:
        raise PublishRefused([f"{existing[0].name} already publishes this dialogue"])
    source = (
        draft_dir.resolve().relative_to(repo.resolve()).as_posix()
        if draft_dir.resolve().is_relative_to(repo.resolve())
        else draft_dir.name
    )
    sql = build_sql(draft, refs, keys, source)
    migration = migrations / f"{stamp}_publish_{slug.replace('-', '_')}.sql"
    targets = []
    for line in draft["lines"]:
        for register in ("puhe", "kirja"):
            targets.append(
                (
                    draft_dir / line["audio"][register]["file"],
                    repo / "public" / "audio" / keys[(line["n"], register)],
                )
            )
    migration.parent.mkdir(parents=True, exist_ok=True)
    migration.write_text(sql, encoding="utf-8", newline="\n")
    written = []
    for source_file, target in targets:
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(source_file, target)
        written.append(target)
    return migration, written
