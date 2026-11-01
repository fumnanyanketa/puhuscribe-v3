"""The migration that loads the 6 parts and 36 stops of the A1 road (job 20-a1-road, "Done when" 1).

The names and the "I can" sentences come from docs/curriculum-a1.md and the `**I can:**` lines of
content/written/part-1.md to part-6.md, and the stop slugs from content/road/stops.json. Nothing is
typed twice, so a test fails when the committed migration differs from this script's output.

python scripts/generate/road_sql.py          write the migration
python scripts/generate/road_sql.py --check  exit 1 when the committed file differs
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

from publish import sql_text
from road_parse import REPO, parse_curriculum, parse_part_file

MIGRATION = REPO / "supabase" / "migrations" / "20261101120100_load_road_stops.sql"
STOPS_JSON = REPO / "content" / "road" / "stops.json"


def road_sql(repo: Path = REPO) -> str:
    parts, stops = parse_curriculum(repo / "docs" / "curriculum-a1.md")
    for part in parts:
        parse_part_file(repo / "content" / "written" / f"part-{part}.md", part, stops)
    settings = json.loads((repo / "content" / "road" / "stops.json").read_text(encoding="utf-8"))["stops"]
    out = [
        "-- Job 20-a1-road: the 6 parts and 36 stops of the A1 road.",
        "-- Made by scripts/generate/road_sql.py from docs/curriculum-a1.md, content/written/part-1.md to",
        "-- part-6.md and content/road/stops.json. Do not edit by hand: change those files and run the",
        "-- script again. A test fails when this file differs from the script's output.",
        "-- Running it a second time changes nothing. Later legs of the road add their own migration.",
        "",
        "insert into public.road_parts (number, title_en) values",
        ",\n".join(f"  ({number}, {sql_text(title)})" for number, title in sorted(parts.items())),
        "on conflict (number) do nothing;",
        "",
        "insert into public.road_stops "
        "(number, slug, part_number, name_en, can_do_en, planned_dialogues) values",
    ]
    rows = []
    for number, stop in sorted(stops.items()):
        slug = settings[str(number)]["unit_slug"]
        rows.append(
            f"  ({number}, {sql_text(slug)}, {stop.part}, {sql_text(stop.name)}, {sql_text(stop.can_do)}, 3)"
        )
    out += [",\n".join(rows), "on conflict (number) do nothing;", ""]
    return "\n".join(out)


def main(argv: list[str]) -> int:
    text = road_sql()
    if "--check" in argv:
        same = MIGRATION.is_file() and MIGRATION.read_text(encoding="utf-8") == text
        print("The migration matches the files." if same else f"{MIGRATION.name} differs from the files.")
        return 0 if same else 1
    MIGRATION.write_text(text, encoding="utf-8", newline="\n")
    print(f"Wrote {MIGRATION.name}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
