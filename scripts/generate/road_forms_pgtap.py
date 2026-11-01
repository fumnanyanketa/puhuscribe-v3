# ruff: noqa: E501  (the SQL template keeps the test file's own line lengths)
"""The pgTAP test of how a road migration puts in a form (job 20-a1-road, "Done when" 17 as amended).

  python scripts/generate/road_forms_pgtap.py          write supabase/tests/database/a1_road_forms.test.sql
  python scripts/generate/road_forms_pgtap.py --check  exit 1 when the committed file differs

The test runs the exact lines publish.road_form_lines() puts in every publish migration, against the real
public.forms table, in one rolled back transaction. It proves: a new form is inserted; the same form with
the same texts goes through again and changes nothing; the same form with different texts is refused, with
a message that names the form and both sets of texts, and the stored texts stay as they were; an existing
form that is not approved is refused.
"""

from __future__ import annotations

import sys
from pathlib import Path

from publish import road_form_lines

REPO = Path(__file__).resolve().parents[2]
TEST_FILE = REPO / "supabase" / "tests" / "database" / "a1_road_forms.test.sql"
PLAN = 7

FORM = {
    "id": "pgtap-form",
    "lemma": "pgtap-road-form",
    "form_tag": "CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular",
    "surface_kirja": "pgtap-road-form",
    "surface_puhe": "pgtap-road-form",
    "form_name_en": "nominative singular",
    "why_en": "pgtap old why",
    "meaning_en": "pgtap old meaning",
    "lemma_meaning_en": "pgtap old dictionary meaning",
    "analysis": {},
}
OTHER_WHY = {**FORM, "why_en": "pgtap new why"}
DRAFT_FORM = {
    **FORM,
    "id": "pgtap-draft-form",
    "lemma": "pgtap-road-draft-form",
    "surface_kirja": "pgtap-road-draft-form",
    "surface_puhe": "pgtap-road-draft-form",
}


def block(form: dict, ref: str) -> str:
    return "\n".join(["do $check$", "begin", *road_form_lines(form, ref), "end", "$check$;"])


def pgtap_text() -> str:
    out = [
        '-- How a road publish migration puts in a form (job 20-a1-road, "Done when" 17 as amended, pgTAP).',
        "-- Made by scripts/generate/road_forms_pgtap.py from publish.road_form_lines(): do not edit by hand.",
        "-- The lines are the ones every publish migration holds. One rolled back transaction.",
        "",
        "begin;",
        "",
        "create extension if not exists pgtap with schema extensions;",
        "",
        f"select plan({PLAN});",
        "",
        "select lives_ok($q$",
        block(FORM, "pgtap-ref-1"),
        "$q$, '[a1-road 17] a form that does not exist is inserted');",
        "select is((select count(*) from public.forms where lemma = 'pgtap-road-form' and status = 'approved'),",
        "  1::bigint, '[a1-road 17] it is there once, approved');",
        "",
        "select lives_ok($q$",
        block(FORM, "pgtap-ref-2"),
        "$q$, '[a1-road 17] the same form with the same texts goes through again');",
        "select is((select count(*) from public.forms where lemma = 'pgtap-road-form'),",
        "  1::bigint, '[a1-road 17] and still there is one row');",
        "",
        "select throws_ilike($q$",
        block(OTHER_WHY, "pgtap-ref-3"),
        "$q$, '%form pgtap-road-form (pgtap-road-form) already exists with different texts. Existing:"
        "%why pgtap old why%New:%why pgtap new why%',",
        "  '[a1-road 17] the same form with another why is refused, naming the form and both texts');",
        "select is((select why_en from public.forms where lemma = 'pgtap-road-form'), 'pgtap old why',",
        "  '[a1-road 17] the stored text stays as it was');",
        "",
        "insert into public.forms (lemma, form_tag, analysis, surface_kirja, surface_puhe, form_name_en, why_en)",
        "  values ('pgtap-road-draft-form', 'CLASS=nimisana;SIJAMUOTO=nimento;NUMBER=singular', '{}'::jsonb,",
        "    'pgtap-road-draft-form', 'pgtap-road-draft-form', 'nominative singular', 'pgtap why');",
        "select throws_ilike($q$",
        block(DRAFT_FORM, "pgtap-ref-4"),
        "$q$, '%exists but is not approved%',",
        "  '[a1-road 17] an existing form that is not approved is refused');",
        "",
        "select * from finish();",
        "",
        "rollback;",
        "",
    ]
    return "\n".join(out)


def main(argv: list[str]) -> int:
    text = pgtap_text()
    if "--check" in argv:
        current = TEST_FILE.read_text(encoding="utf-8") if TEST_FILE.is_file() else ""
        if current != text:
            print(f"{TEST_FILE} is not what road_forms_pgtap.py makes")
            return 1
        return 0
    TEST_FILE.write_text(text, encoding="utf-8", newline="\n")
    print(f"wrote {TEST_FILE}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
