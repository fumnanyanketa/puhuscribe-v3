"""A reviewer's fix replaces a live line (job 20-a1-road, "Done when" 24).

The native reviewer reads the road after launch and sends the same review file as for any dialogue
(content/reviews/<slug>/round-<n>.json). road_next_round():

1. reads the file with job 7's refusal rules,
2. writes each accepted line fix into the exact markdown cell (and logs it in content/road/fixes.md),
   and each "why" fix into the word notes,
3. imports that dialogue again and checks it (a new form that needs texts stops the command with a list),
4. makes the voice read the changed lines again, only those, and
5. writes supabase/migrations/<timestamp>_fix_<slug>_round_<n>.sql.

The migration runs in one transaction. It sets the dialogue back to draft (so a learner never reads a
half changed dialogue), sets the changed lines back to draft, replaces their words and audio keys,
approves the new forms, then approves the lines and the dialogue with new references of the form
content/reviews/<slug>/round-<n>.json#line-<k>. The old references stay in private.approval_history, so
approving a changed line with the owner's old reference is refused. No AI is called.
"""

# ruff: noqa: E501  (the SQL template keeps readable lines)
from __future__ import annotations

from datetime import UTC, datetime
from pathlib import Path

from publish import sql_text
from road_markdown import log_fix, read_cell, replace_cell

REPO = Path(__file__).resolve().parents[2]
CELL_FOR = {"text_puhe": "puhe", "text_kirja": "kirja", "gloss_en": "en"}


def dialogue_label(draft: dict) -> str:
    return f"{draft['brief']['unit']['position']}.{draft['brief']['dialogue']['position']}"


def write_fixes_to_markdown(
    draft: dict,
    entries: dict[str, dict],
    review_name: str,
    written: Path | None = None,
    fixes: Path | None = None,
) -> set[int]:
    """Write each accepted line fix into its markdown cell and log it. Returns the changed line numbers."""
    label = dialogue_label(draft)
    changed: set[int] = set()
    for item_id, entry in entries.items():
        if entry.get("decision") != "fix" or not item_id.startswith("line-"):
            continue
        number = int(item_id.split("-")[1])
        for field, column in CELL_FOR.items():
            new = entry["fix"][field].strip()
            kwargs = {"written": written} if written else {}
            before = read_cell(label, number, column, **kwargs)
            if before == new:
                continue
            replace_cell(label, number, column, new, **kwargs)
            log_fix(
                label,
                number,
                column,
                before,
                new,
                f"The native reviewer fixed this text ({review_name}).",
                f"Reviewer {review_name}",
                **({"fixes": fixes} if fixes else {}),
            )
            changed.add(number)
    return changed


def changed_lines(old: dict, new: dict) -> set[int]:
    """The numbers of lines whose texts differ between two versions of a draft."""
    before = {ln["n"]: (ln["text_puhe"], ln["text_kirja"], ln["gloss_en"]) for ln in old["lines"]}
    return {
        ln["n"]
        for ln in new["lines"]
        if before.get(ln["n"]) != (ln["text_puhe"], ln["text_kirja"], ln["gloss_en"])
    }


def changed_forms(old: dict, new: dict) -> tuple[list[dict], list[dict]]:
    """The forms the new draft adds, and the forms whose texts changed (a "why" fix)."""
    before = {f["id"]: f for f in old["forms"]}
    added = [f for f in new["forms"] if f["id"] not in before]
    texts = ("form_name_en", "why_en", "meaning_en", "lemma_meaning_en")
    edited = [
        f
        for f in new["forms"]
        if f["id"] in before and any(f.get(k, "") != before[f["id"]].get(k, "") for k in texts)
    ]
    return added, edited


def _form_where(form: dict) -> str:
    return (
        f"lemma = {sql_text(form['lemma'])} and form_tag = {sql_text(form['form_tag'])} "
        f"and surface_kirja = {sql_text(form['surface_kirja'])} "
        f"and surface_puhe = {sql_text(form['surface_puhe'])}"
    )


def _form_values(form: dict, ref: str) -> str:
    return (
        f"form_name_en = {sql_text(form['form_name_en'])}, why_en = {sql_text(form['why_en'])}, "
        f"meaning_en = {sql_text(form['meaning_en'])}, "
        f"lemma_meaning_en = {sql_text(form['lemma_meaning_en'])}, "
        f"status = 'approved', approved_at = now(), approval_ref = {sql_text(ref)}"
    )


def fix_sql(
    new: dict,
    old: dict,
    changed: set[int],
    round_number: int,
    keys: dict[tuple[int, str], str],
    source: str,
) -> str:
    """The fix migration for one dialogue and one round. It does nothing when it was applied before."""
    slug = new["brief"]["dialogue"]["slug"]
    base = f"content/reviews/{slug}/round-{round_number}.json#"
    first = min(changed) if changed else 0
    added, edited = changed_forms(old, new)
    out = [
        f"-- Fix round {round_number} of the dialogue {slug}. Made by scripts/generate/pipeline.py",
        f'-- road-next-round from {source}. Do not edit by hand. Job 20-a1-road, "Done when" 24.',
        "-- One transaction: the dialogue is a draft while its lines change, so a learner never reads a",
        "-- half changed dialogue; the old approvals stay in private.approval_history, so they cannot be",
        "-- used again. Running it a second time does nothing.",
        "do $fix$",
        "declare",
        "  v_dialogue_id bigint;",
        "  v_line_id bigint;",
        "begin",
        "  select id into v_dialogue_id from public.dialogues",
        f"  where slug = {sql_text(slug)} and status = 'approved';",
        "  if v_dialogue_id is null then",
        f"    raise notice 'dialogue % is not published; nothing to fix', {sql_text(slug)};",
        "    return;",
        "  end if;",
    ]
    if changed:
        out += [
            "  if exists (select 1 from public.dialogue_lines l where l.dialogue_id = v_dialogue_id",
            f"    and l.approval_ref = {sql_text(base + 'line-' + str(first))}) then",
            f"    raise notice 'fix round {round_number} of % is already applied; nothing to do', {sql_text(slug)};",
            "    return;",
            "  end if;",
        ]
    out += [
        "",
        "  -- 1. The dialogue is hidden from learners until every change is in.",
        "  update public.dialogues set status = 'draft' where id = v_dialogue_id;",
        "",
    ]
    for form in added:
        out += [
            "  insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe,",
            "    form_name_en, why_en, meaning_en, lemma_meaning_en, status, approved_at, approval_ref)",
            f"  values ({sql_text(form['lemma'])}, {sql_text(form['form_tag'])}, "
            f"{sql_text(json_text(form.get('analysis', {})))}::jsonb,",
            f"    {sql_text(form['surface_kirja'])}, {sql_text(form['surface_puhe'])},",
            f"    {sql_text(form['form_name_en'])}, {sql_text(form['why_en'])}, {sql_text(form['meaning_en'])},",
            f"    {sql_text(form['lemma_meaning_en'])}, 'approved', now(), {sql_text(base + form['id'])})",
            "  on conflict (lemma, form_tag, surface_kirja, surface_puhe) do nothing;",
        ]
    for form in edited:
        out += [
            f"  update public.forms set status = 'draft' where {_form_where(form)};",
            f"  update public.forms set {_form_values(form, base + form['id'])} where {_form_where(form)};",
        ]
    forms = {f["id"]: f for f in new["forms"]}
    for line in new["lines"]:
        n = line["n"]
        if n not in changed:
            continue
        out += [
            "",
            f"  -- Line {n}.",
            f"  update public.dialogue_lines set status = 'draft' where dialogue_id = v_dialogue_id and position = {n};",
            f"  update public.dialogue_lines set text_puhe = {sql_text(line['text_puhe'])},",
            f"    text_kirja = {sql_text(line['text_kirja'])}, gloss_en = {sql_text(line['gloss_en'])},",
            f"    audio_puhe_key = {sql_text(keys[(n, 'puhe')])}, audio_kirja_key = {sql_text(keys[(n, 'kirja')])}",
            f"  where dialogue_id = v_dialogue_id and position = {n}",
            "  returning id into v_line_id;",
            "  delete from public.tokens where line_id = v_line_id;",
        ]
        rows = []
        for register, toks in (("kirja", line["kirja_tokens"]), ("puhe", line["puhe_tokens"])):
            for position, tok in enumerate(toks, start=1):
                if register == "kirja":
                    form = forms.get(tok.get("form") or "")
                else:
                    target = tok.get("kirja")
                    linked = line["kirja_tokens"][target - 1] if isinstance(target, int) else {}
                    form = forms.get(linked.get("form") or "")
                form_sql = "null"
                if form is not None:
                    form_sql = f"(select id from public.forms where {_form_where(form)})"
                rows.append(
                    f"    (v_line_id, '{register}', {position}, {sql_text(tok['surface'])}, {form_sql})"
                )
        out += [
            "  insert into public.tokens (line_id, register, position, surface, form_id) values",
            ",\n".join(rows) + ";",
        ]
    out += ["", "  -- 2. Approve the changed lines with the reviewer's new references, then the dialogue."]
    for n in sorted(changed):
        out += [
            "  update public.dialogue_lines set status = 'approved', approved_at = now(),",
            f"    approval_ref = {sql_text(base + 'line-' + str(n))}",
            f"  where dialogue_id = v_dialogue_id and position = {n};",
        ]
    out += [
        "  update public.dialogues set status = 'approved', approved_at = now(),",
        f"    approval_ref = {sql_text(base + 'dialogue')}",
        "  where id = v_dialogue_id;",
        "end",
        "$fix$;",
        "",
    ]
    return "\n".join(out)


def json_text(value: object) -> str:
    import json

    return json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":"))


def fix_migration_name(slug: str, round_number: int, now: datetime | None = None) -> str:
    stamp = (now or datetime.now(UTC)).strftime("%Y%m%d%H%M%S")
    return f"{stamp}_fix_{slug.replace('-', '_')}_round_{round_number}.sql"


def set_note_why(form: dict, why: str, notes_path: Path) -> None:
    """Write a reviewer's corrected "why" into the form's row of word-notes.tsv (a row is added when the
    form had none, for example a dictionary form with the fixed line)."""
    tab, newline = chr(9), chr(10)
    rows = notes_path.read_text(encoding="utf-8").splitlines()
    out, found = [], False
    for row in rows:
        cells = row.split(tab)
        if cells[0] == form["id"]:
            cells += [""] * (7 - len(cells))
            cells[6] = why
            row, found = tab.join(cells), True
        out.append(row)
    if not found:
        cells = [
            form["id"],
            form["surface_kirja"],
            form["surface_puhe"],
            form["lemma"],
            form["form_name_en"],
            form.get("meaning_en", ""),
            why,
        ]
        out.append(tab.join(cells))
    notes_path.write_text(newline.join(out) + newline, encoding="utf-8", newline=newline)
