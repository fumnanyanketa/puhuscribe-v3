"""The native reviewer's page (job 7-content-pipeline, "Done when" 13).

One self contained HTML file per review round. It opens from disk in a desktop
browser and loads nothing from the network: the audio is inside the file as
data, and a Content Security Policy allows only this page's own script and
style (by hash) and data: audio.

All drafted text travels as JSON inside a <script type="application/json">
block with <, > and & escaped, and the page's script puts it on screen with
textContent only. So text such as "<script>" is printed, never run.

"Download my review" saves a JSON file with each item's decision and content
fingerprint. The pipeline reads it back (review_import.py).
"""

from __future__ import annotations

import base64
import hashlib
import json
from pathlib import Path

from review_items import DIALOGUE_ITEM, all_items, clip_path

REVIEW_FORMAT = "puhuscribe-review-1"
ROUND_FORMAT = "puhuscribe-review-round-1"

STYLE = """
:root { color-scheme: light; }
* { box-sizing: border-box; }
body { margin: 0; background: #faf9fc; color: #1b1a20;
  font: 16px/1.5 system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif; }
main { max-width: 760px; margin: 0 auto; padding: 32px 20px 96px; }
h1 { font-size: 28px; line-height: 1.2; margin: 0 0 8px; font-weight: 650; letter-spacing: -0.01em; }
h2 { font-size: 20px; margin: 40px 0 12px; font-weight: 650; }
h3 { font-size: 17px; margin: 0 0 12px; font-weight: 650; }
p { margin: 0 0 12px; }
h1, h2, h3, p, li, legend, .field span { overflow-wrap: anywhere; }
.intro { color: #56525e; }
fieldset { border: 0; margin: 8px 0; padding: 0; min-width: 0; }
legend { font-size: 14px; font-weight: 600; padding: 0; margin: 0 0 2px; }
.item { background: #ffffff; border-radius: 14px; padding: 20px; margin: 0 0 16px;
  box-shadow: 0 1px 2px #1a16341a; }
.register { margin: 0 0 14px; }
.label { font-size: 14px; font-weight: 600; margin: 0 0 2px; }
.spoken .label { color: #166270; }
.written .label { color: #6b46c1; }
.finnish { font-size: 20px; margin: 0 0 6px; }
.meaning { color: #56525e; }
.note { color: #56525e; font-size: 14px; }
.row { display: flex; flex-wrap: wrap; gap: 8px 16px; align-items: center; margin: 8px 0; }
.choice { display: inline-flex; gap: 6px; align-items: center; }
button { font: inherit; background: #1b1a20; color: #ffffff; border: 0; border-radius: 999px;
  padding: 8px 18px; cursor: pointer; }
button:hover { background: #2a2832; }
button:focus-visible, input:focus-visible, textarea:focus-visible {
  outline: 3px solid #1f42ac; outline-offset: 2px; }
textarea, input[type=text] { font: inherit; color: #1b1a20; background: #ffffff; width: 100%;
  border: 1px solid #7a7689; border-radius: 8px; padding: 8px 10px; }
textarea { min-height: 44px; }
.fix { margin: 8px 0 0; }
.fix[hidden] { display: none; }
.field { margin: 0 0 10px; }
.field span { display: block; font-size: 14px; font-weight: 600; margin: 0 0 4px; }
.status { margin: 16px 0 0; font-weight: 600; }
.status ul { margin: 8px 0 0; padding-left: 20px; font-weight: 400; }
.code { max-width: 200px; }
"""

SCRIPT = r"""
(function () {
  'use strict';
  var data = JSON.parse(document.getElementById('review-data').textContent);
  var state = {};
  var main = document.getElementById('page');

  function el(tag, className, text) {
    var node = document.createElement(tag);
    if (className) node.className = className;
    if (text !== undefined && text !== null) node.textContent = String(text);
    return node;
  }

  function radios(itemId, legendText, options, onChange) {
    var group = el('fieldset');
    group.appendChild(el('legend', null, legendText));
    var row = el('div', 'row');
    group.appendChild(row);
    options.forEach(function (option) {
      var label = el('label', 'choice');
      var input = document.createElement('input');
      input.type = 'radio';
      input.name = 'choice-' + itemId;
      input.value = option.value;
      input.addEventListener('change', function () { onChange(option.value); });
      label.appendChild(input);
      label.appendChild(document.createTextNode(option.text));
      row.appendChild(label);
    });
    return group;
  }

  function field(labelText, value, onInput, multiline, lang) {
    var wrap = el('label', 'field');
    wrap.appendChild(el('span', null, labelText));
    var input = document.createElement(multiline ? 'textarea' : 'input');
    if (!multiline) input.type = 'text';
    if (lang) input.lang = lang;
    input.value = value || '';
    input.addEventListener('input', function () { onInput(input.value); });
    wrap.appendChild(input);
    return wrap;
  }

  function comment(itemId) {
    return field('Comment (optional)', '', function (v) { state[itemId].comment = v; }, true);
  }

  function decisionBlock(itemId, legendText, fixFields) {
    var block = el('div');
    var fix = el('div', 'fix');
    fix.hidden = true;
    block.appendChild(radios(itemId, legendText, [
      { value: 'approve', text: 'Approve' },
      { value: 'fix', text: 'Fix' }
    ], function (value) {
      state[itemId].decision = value;
      fix.hidden = value !== 'fix';
    }));
    fixFields.forEach(function (f) {
      state[itemId].fix[f.key] = f.value;
      fix.appendChild(field(f.label, f.value, function (v) { state[itemId].fix[f.key] = v; }, true, f.lang));
    });
    block.appendChild(fix);
    block.appendChild(comment(itemId));
    return block;
  }

  function audioBlock(clip) {
    var block = el('div', 'row');
    var player = document.createElement('audio');
    player.preload = 'none';
    player.src = 'data:audio/mpeg;base64,' + clip.mp3;
    var play = el('button', null, 'Play');
    play.type = 'button';
    play.setAttribute('aria-label', 'Play the ' + clip.registerName + ' audio of line ' + clip.line);
    play.addEventListener('click', function () { player.currentTime = 0; player.play(); });
    block.appendChild(play);
    block.appendChild(player);
    block.appendChild(el('span', 'note', clip.source));
    if (clip.item) {
      state[clip.item] = { kind: 'audio', verdict: null, comment: '' };
      block.appendChild(radios(clip.item,
        'Line ' + clip.line + ' ' + clip.registerName + ' audio, the sound only', [
        { value: 'right', text: 'Sounds right' },
        { value: 'wrong', text: 'Sounds wrong' }
      ], function (value) { state[clip.item].verdict = value; }));
    }
    var wrap = el('div');
    wrap.appendChild(block);
    if (clip.item) wrap.appendChild(comment(clip.item));
    return wrap;
  }

  function register(className, labelText, text, clip) {
    var block = el('div', 'register ' + className);
    block.appendChild(el('p', 'label', labelText));
    var finnish = el('p', 'finnish', text);
    finnish.lang = 'fi';
    block.appendChild(finnish);
    if (clip) block.appendChild(audioBlock(clip));
    return block;
  }

  document.title = 'Review: ' + data.dialogue.title_en + ' (round ' + data.round + ')';
  main.appendChild(el('h1', null, 'Review: ' + data.dialogue.title_en));
  main.appendChild(el('p', 'intro', 'Unit ' + data.unit.position + ': ' + data.unit.title_en +
    '. Can do: ' + data.unit.can_do_en));
  main.appendChild(el('p', 'intro', 'Round ' + data.round + '. Listen to every clip and read every line ' +
    'and word card. Approve what is right. Choose Fix and write the correct text where something is wrong. ' +
    'When you are done, press "Download my review" and send the file back.'));
  main.appendChild(el('p', 'intro', 'Approve and Fix are about the Finnish text and its English meaning. ' +
    'The sound of each clip has its own choice. If something needs fixing, you can answer "Not yet" for ' +
    'the dialogue as a whole and you will see it again after the fixes.'));
  main.appendChild(el('p', 'intro', 'Nothing is saved until you press "Download my review". ' +
    'Closing or refreshing this page before then loses your work.'));
  var codeField = field('Your reviewer code (for example R1, not your name)', '',
    function (v) { data.reviewerCode = v; }, false);
  codeField.querySelector('input').className = 'code';
  main.appendChild(codeField);

  if (data.lines.length) main.appendChild(el('h2', null, 'Lines'));
  data.lines.forEach(function (line) {
    var card = el('section', 'item');
    card.appendChild(el('h3', null, 'Line ' + line.n + ', ' + line.speaker + ' (' + line.role + ')'));
    card.appendChild(register('spoken', 'Spoken Finnish', line.text_puhe, line.audio.puhe));
    card.appendChild(register('written', 'Written Finnish', line.text_kirja, line.audio.kirja));
    card.appendChild(el('p', 'meaning', 'English meaning: ' + line.gloss_en));
    if (line.spokenOnly.length) {
      card.appendChild(el('p', 'note',
        'Spoken only words (no written partner): ' + line.spokenOnly.join(', ')));
    }
    if (line.item) {
      state[line.item] = { kind: 'line', decision: null, fix: {}, comment: '' };
      card.appendChild(decisionBlock(line.item,
        'Line ' + line.n + ': is the Finnish text and its English meaning right?', [
        { key: 'text_puhe', label: 'Corrected spoken Finnish', value: line.text_puhe, lang: 'fi' },
        { key: 'text_kirja', label: 'Corrected written Finnish', value: line.text_kirja, lang: 'fi' },
        { key: 'gloss_en', label: 'Corrected English meaning', value: line.gloss_en }
      ]));
    } else {
      card.appendChild(el('p', 'note', 'This line was approved in an earlier round. Only its audio is new.'));
    }
    main.appendChild(card);
  });

  if (data.forms.length) main.appendChild(el('h2', null, 'Word cards'));
  data.forms.forEach(function (form) {
    var card = el('section', 'item');
    var heading = el('h3');
    var written = el('span', null, form.surface_kirja);
    written.lang = 'fi';
    var spoken = el('span', null, form.surface_puhe);
    spoken.lang = 'fi';
    heading.appendChild(written);
    heading.appendChild(document.createTextNode(' (spoken: '));
    heading.appendChild(spoken);
    heading.appendChild(document.createTextNode(')'));
    card.appendChild(heading);
    var base = el('p', null, 'Base form: ');
    var lemma = el('span', null, form.lemma);
    lemma.lang = 'fi';
    base.appendChild(lemma);
    card.appendChild(base);
    card.appendChild(el('p', null, 'Form: ' + form.form_name_en));
    card.appendChild(el('p', null, 'Why: ' + form.why_en));
    card.appendChild(el('p', 'note', 'In line ' + form.lines.join(', ')));
    state[form.item] = { kind: 'form', decision: null, fix: {}, comment: '' };
    card.appendChild(decisionBlock(form.item, 'Word card ' + form.surface_kirja + ': is it right?', [
      { key: 'why_en', label: 'Corrected why (one line)', value: form.why_en }
    ]));
    main.appendChild(card);
  });

  main.appendChild(el('h2', null, 'The dialogue as a whole'));
  var whole = el('section', 'item');
  whole.appendChild(el('p', null,
    'Approve the whole dialogue as a learner will see it, every line in order, ' +
    'with the unit title and can do statement above. If you marked anything Fix or Sounds wrong, ' +
    'answer "Not yet". You will see the dialogue again after the fixes.'));
  state.dialogue = { kind: 'dialogue', decision: null, fix: {}, comment: '' };
  whole.appendChild(radios('dialogue', 'The dialogue as a whole', [
    { value: 'approve', text: 'I approve this dialogue as a whole' },
    { value: 'not-yet', text: 'Not yet' }
  ], function (value) { state.dialogue.decision = value; }));
  whole.appendChild(comment('dialogue'));
  main.appendChild(whole);

  var status = el('div', 'status');
  status.setAttribute('role', 'status');
  status.setAttribute('aria-live', 'polite');
  var download = el('button', null, 'Download my review');
  download.type = 'button';
  download.addEventListener('click', function () {
    var problems = [];
    var code = (data.reviewerCode || '').trim();
    if (!/^[A-Za-z0-9]{1,12}$/.test(code)) {
      problems.push('Write your reviewer code: letters and digits only, such as R1.');
    }
    var items = [];
    var asksForChanges = data.items.some(function (item) {
      var s = state[item.id];
      return s && (s.decision === 'fix' || s.verdict === 'wrong');
    });
    data.items.forEach(function (item) {
      var s = state[item.id];
      var out = { id: item.id, kind: item.kind, fingerprint: item.fingerprint,
        comment: (s && s.comment) || '' };
      if (item.kind === 'audio') {
        if (!s.verdict) problems.push(item.label + ': choose sounds right or sounds wrong.');
        out.verdict = s.verdict;
      } else {
        if (!s.decision) {
          problems.push(item.label + ': choose ' +
            (item.kind === 'dialogue' ? 'I approve or Not yet.' : 'approve or fix.'));
        } else if (s.decision === 'not-yet' && !asksForChanges) {
          problems.push('The dialogue as a whole: you chose Not yet, but nothing is marked Fix or ' +
            'Sounds wrong. Mark what needs changing, or approve the dialogue.');
        }
        out.decision = s.decision;
        if (s.decision === 'fix') {
          out.fix = s.fix;
          Object.keys(s.fix).forEach(function (k) {
            if (!String(s.fix[k]).trim()) problems.push(item.label + ': the corrected text is empty.');
          });
        }
      }
      items.push(out);
    });
    status.textContent = '';
    if (problems.length) {
      status.appendChild(el('p', null, 'Not saved yet. Please finish these first:'));
      var list = el('ul');
      problems.forEach(function (p) { list.appendChild(el('li', null, p)); });
      status.appendChild(list);
      return;
    }
    var review = { format: data.format, dialogue_slug: data.dialogue.slug, round: data.round,
      reviewer_code: code, items: items };
    var blob = new Blob([JSON.stringify(review, null, 2) + '\n'], { type: 'application/json' });
    var link = document.createElement('a');
    link.href = URL.createObjectURL(blob);
    link.download = 'review-' + data.dialogue.slug + '-round-' + data.round + '.json';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    status.appendChild(el('p', null, 'Saved as ' + link.download + '. Send this file back.'));
  });
  main.appendChild(download);
  main.appendChild(status);
})();
"""


def _csp_hash(text: str) -> str:
    return "'sha256-" + base64.b64encode(hashlib.sha256(text.encode("utf-8")).digest()).decode("ascii") + "'"


def _safe_json(value: object) -> str:
    """JSON that cannot end its <script> block or start markup."""
    return (
        json.dumps(value, ensure_ascii=False, separators=(",", ":"))
        .replace("&", "\\u0026")
        .replace("<", "\\u003c")
        .replace(">", "\\u003e")
        .replace(" ", "\\u2028")
        .replace(" ", "\\u2029")
    )


def pending_items(draft: dict, approved: dict[str, str]) -> dict[str, dict]:
    """Items not yet approved with their current fingerprint, plus the dialogue (always)."""
    items = all_items(draft)
    return {
        item_id: item
        for item_id, item in items.items()
        if item_id == DIALOGUE_ITEM or approved.get(item_id) != item["fingerprint"]
    }


def page_data(draft: dict, draft_dir: Path, round_number: int, pending: dict[str, dict]) -> dict:
    brief = draft["brief"]
    roles = {s["name"]: s["role_en"] for s in brief["speakers"]}
    form_lines: dict[str, list[int]] = {}
    for line in draft["lines"]:
        for tok in line["kirja_tokens"]:
            if tok.get("form"):
                form_lines.setdefault(tok["form"], [])
                if line["n"] not in form_lines[tok["form"]]:
                    form_lines[tok["form"]].append(line["n"])
    lines = []
    labels: dict[str, str] = {"dialogue": "The dialogue as a whole"}
    for line in draft["lines"]:
        line_item = f"line-{line['n']}"
        audio_items = {r: f"audio-{line['n']}-{r}" for r in ("puhe", "kirja")}
        if line_item not in pending and not any(a in pending for a in audio_items.values()):
            continue
        clips = {}
        for register, item_id in audio_items.items():
            audio = line["audio"][register]
            if audio["file"] != clip_path(line["n"], register):
                raise ValueError(
                    f"line {line['n']} {register} audio must be {clip_path(line['n'], register)}"
                )
            clips[register] = {
                "line": line["n"],
                "registerName": "spoken" if register == "puhe" else "written",
                "source": "Native recording" if audio["source"] == "native recording" else "Synthetic voice",
                "mp3": base64.b64encode((draft_dir / audio["file"]).read_bytes()).decode("ascii"),
                "item": item_id if item_id in pending else None,
            }
            labels[item_id] = f"Line {line['n']} {clips[register]['registerName']} audio"
        labels[line_item] = f"Line {line['n']}"
        lines.append(
            {
                "n": line["n"],
                "speaker": line["speaker"],
                "role": roles.get(line["speaker"], ""),
                "text_puhe": line["text_puhe"],
                "text_kirja": line["text_kirja"],
                "gloss_en": line["gloss_en"],
                "spokenOnly": [t["surface"] for t in line["puhe_tokens"] if t.get("spoken_only")],
                "audio": clips,
                "item": line_item if line_item in pending else None,
            }
        )
    forms = []
    for form in draft["forms"]:
        if form["id"] not in pending:
            continue
        labels[form["id"]] = f"Word card {form['surface_kirja']}"
        forms.append(
            {
                "item": form["id"],
                "lemma": form["lemma"],
                "surface_kirja": form["surface_kirja"],
                "surface_puhe": form["surface_puhe"],
                "form_name_en": form["form_name_en"],
                "why_en": form["why_en"],
                "lines": form_lines.get(form["id"], []),
            }
        )
    return {
        "format": REVIEW_FORMAT,
        "round": round_number,
        "unit": brief["unit"],
        "dialogue": brief["dialogue"],
        "lines": lines,
        "forms": forms,
        "items": [
            {
                "id": item_id,
                "kind": item["kind"],
                "fingerprint": item["fingerprint"],
                "label": labels[item_id],
            }
            for item_id, item in pending.items()
        ],
    }


def render_page(data: dict) -> str:
    csp = (
        "default-src 'none'; "
        f"script-src {_csp_hash(SCRIPT)}; "
        f"style-src {_csp_hash(STYLE)}; "
        "media-src data:; img-src data:; base-uri 'none'; form-action 'none'"
    )
    title = f"Review round {data['round']}"
    return (
        "<!doctype html>\n"
        '<html lang="en">\n<head>\n<meta charset="utf-8">\n'
        f'<meta http-equiv="Content-Security-Policy" content="{csp}">\n'
        '<meta name="viewport" content="width=device-width, initial-scale=1">\n'
        f"<title>{title}</title>\n"
        f"<style>{STYLE}</style>\n</head>\n<body>\n"
        '<main id="page"></main>\n'
        f'<script type="application/json" id="review-data">{_safe_json(data)}</script>\n'
        f"<script>{SCRIPT}</script>\n"
        "</body>\n</html>\n"
    )


def write_round(
    draft: dict, draft_dir: Path, approved: dict[str, str], round_number: int
) -> tuple[Path, Path]:
    """Write review/round-<n>.html and its manifest review/round-<n>.json (the items and
    fingerprints the page asked about)."""
    pending = pending_items(draft, approved)
    data = page_data(draft, draft_dir, round_number, pending)
    review_dir = draft_dir / "review"
    review_dir.mkdir(parents=True, exist_ok=True)
    page = review_dir / f"round-{round_number}.html"
    page.write_text(render_page(data), encoding="utf-8", newline="\n")
    manifest = review_dir / f"round-{round_number}.json"
    manifest.write_text(
        json.dumps(
            {
                "format": ROUND_FORMAT,
                "dialogue_slug": draft["brief"]["dialogue"]["slug"],
                "round": round_number,
                "items": {item_id: item["fingerprint"] for item_id, item in pending.items()},
            },
            ensure_ascii=False,
            indent=2,
        )
        + "\n",
        encoding="utf-8",
        newline="\n",
    )
    return page, manifest
