/* PuhuScribe v2 — shared app chrome on top of window.PS. Exposes window.APP.*
   Everything every screen shares lives here, so screens that teach the same
   thing are guaranteed to look alike. */
(function () {
  const e = React.createElement;
  const PS = window.PS;
  const { I, Label, Orb, OrbCluster, Bar, Steps, RegDot, Sentence, SpeakerBtn } = PS;

  /* ---- extra icons (merge into PS.icons) ---- */
  Object.assign(PS.icons, {
    eye:     ['M2 12s3.6-7 10-7 10 7 10 7-3.6 7-10 7-10-7-10-7z', 'M12 9a3 3 0 1 0 0 6 3 3 0 0 0 0-6z'],
    pencil:  ['M4 20h4L19 9l-4-4L5 16z', 'M14.5 5.5l4 4'],
    trash:   ['M5 7h14', 'M9 7V5h6v2', 'M7 7l1 12.5h8L17 7'],
    review:  ['M3 6.5h18v11H3z', 'M3 10.5h18'],
    sprout:  ['M12 21v-7.5', 'M12 13.5C12 10 9 8 4.5 8c0 3.5 3 5.5 7.5 5.5z', 'M12 12c0-3 3-4.8 7-4.8 0 3.3-3 4.8-7 4.8z'],
    volume:  ['M11 5 6 9H3v6h3l5 4z', 'M15.5 8.5a5 5 0 0 1 0 7', 'M18.5 6a9 9 0 0 1 0 12'],
    refresh: ['M4 11a8 8 0 0 1 14-5l2 2', 'M20 13a8 8 0 0 1-14 5l-2-2', 'M18 4v4h-4', 'M6 20v-4h4'],
    bolt:    ['M13 3 5 14h6l-1 7 8-11h-6z'],
    user:    ['M12 12a4 4 0 1 0 0-8 4 4 0 0 0 0 8z', 'M5 20a7 7 0 0 1 14 0'],
    pen:     ['M4 20h4L19 9l-4-4L5 16z', 'M14.5 5.5l4 4'],
    lines:   ['M5 8h13', 'M5 12.5h14', 'M5 17h9'],
  });
  const Ic = (name, props) => I(name, props);

  /* =====================================================================
     PHONE — iOS frame, snow ground. Content sits below the status bar.
     ===================================================================== */
  function Phone({ children, w = 320, accentGlow = 'rgba(107,70,193,.30)' }) {
    const h = Math.round(w * 2.08);
    return e('div', { style: {
      position: 'relative', width: w, height: h, flexShrink: 0,
      borderRadius: w * 0.15, padding: w * 0.034,
      background: 'linear-gradient(150deg,#2b2933,#16151b 60%,#2b2933)',
      boxShadow: `inset 0 2px 3px rgba(255,255,255,.22), 0 40px 70px -34px ${accentGlow}, var(--sh-3)` } },
      e('div', { className: 'ps-root ps-theme-snow', style: {
        position: 'relative', width: '100%', height: '100%', overflow: 'hidden',
        borderRadius: w * 0.118, background: 'var(--bg-grad)' } },
        // status bar
        e('div', { style: {
          position: 'absolute', top: 0, left: 0, right: 0, height: 50, zIndex: 6,
          display: 'flex', alignItems: 'center', justifyContent: 'space-between',
          padding: '0 26px 0 24px', fontFamily: 'var(--font-display)', fontWeight: 600, fontSize: 13, color: 'var(--ink)' } },
          e('span', { className: 'ps-num' }, '9:41'),
          e('span', { style: { display: 'flex', gap: 6, alignItems: 'center', opacity: .92 } },
            Ic('chart', { size: 15, sw: 2.4 }),
            e('span', { style: { width: 22, height: 11, borderRadius: 3, border: '1.5px solid var(--ink)', position: 'relative' } },
              e('span', { style: { position: 'absolute', inset: 1.5, background: 'var(--ink)', borderRadius: 1 } })))),
        // dynamic island
        e('div', { style: { position: 'absolute', top: 12, left: '50%', transform: 'translateX(-50%)', zIndex: 7,
          width: 92, height: 28, borderRadius: 16, background: '#0b0a0f' } }),
        // content fills the phone; each Screen reserves the safe area itself
        e('div', { style: { position: 'absolute', inset: 0, overflow: 'hidden' } }, children)));
  }

  // Safe area below the status bar / dynamic island — content never starts higher.
  const SAFE_TOP = 50;

  /* Scrollable / static screen body (snow ground). The safe-area top padding is
     forced AFTER any incoming style, so a screen can never pull content up under
     the status bar. `top` adds optional breathing room below the safe area. */
  const Screen = ({ children, pad = 22, bottom = 22, bg = 'var(--bg-grad)', top = 4, style }) =>
    e('div', { className: 'ps-noscroll', style: {
      position: 'absolute', inset: 0, overflowY: 'auto', background: bg,
      paddingLeft: pad, paddingRight: pad, paddingBottom: bottom,
      display: 'flex', flexDirection: 'column', ...style,
      paddingTop: SAFE_TOP + top } }, children);

  /* =====================================================================
     WORDMARK
     ===================================================================== */
  const Wordmark = ({ size = 21 }) =>
    e('div', { style: { display: 'flex', alignItems: 'center', gap: 9 } },
      e(OrbCluster, { size: size * 1.7, style: { width: size * 1.7, height: size * 1.7 } }),
      e('span', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: size,
        letterSpacing: '-0.03em', color: 'var(--ink)' } },
        'Puhu', e('span', { style: { color: 'var(--ink-3)' } }, 'Scribe')));

  /* small single-bubble logo for tight headers */
  const MiniMark = ({ size = 20 }) =>
    e('div', { style: { display: 'flex', alignItems: 'center', gap: 9 } },
      e(OrbCluster, { size: size * 1.15 }),
      e('span', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: size,
        letterSpacing: '-0.03em', color: 'var(--ink)' } },
        'Puhu', e('span', { style: { color: 'var(--ink-3)' } }, 'Scribe')));

  /* =====================================================================
     BILINGUAL helpers — Finnish primary, English as a quiet secondary line
     (no brackets, no italic): muted ink-3, weight 500. The signature pattern.
     ===================================================================== */
  // Thin middot separator for inline FI · EN pairings.
  const Sep = () => e('span', { style: { color: 'var(--ink-3)', opacity: 0.5, margin: '0 7px', fontWeight: 400 } }, '\u00B7');

  // Eyebrow: uppercase FI label (colored) with optional EN gloss beneath, tucked close.
  const Eyebrow = ({ fi, en, color = 'var(--written)', center, style }) =>
    e('div', { style: { textAlign: center ? 'center' : 'left', ...style } },
      e('span', { className: 'ps-label', style: { color, display: 'block' } }, fi),
      en && e('span', { style: { fontFamily: 'var(--font-body)', fontStyle: 'italic', fontWeight: 500,
        fontSize: 10.5, letterSpacing: '0.01em', color: 'var(--ink-3)', display: 'block', marginTop: 1 } }, en));

  // Inline EN gloss after FI text — muted italic, no brackets.
  const Gloss = ({ children, size = 12 }) =>
    e('span', { style: { fontFamily: 'var(--font-body)', fontStyle: 'italic', fontWeight: 500,
      fontSize: size, color: 'var(--ink-3)' } }, children);

  /* =====================================================================
     SKILL CHIP — the 4 YKI skills, fixed color coding everywhere.
     ===================================================================== */
  const SKILL = {
    reading:   { label: 'READING',   c: 'var(--written)', bg: 'var(--written-bg)' },
    listening: { label: 'LISTENING', c: 'var(--flag)',    bg: 'var(--flag-bg)' },
    speaking:  { label: 'SPEAKING',  c: 'var(--spoken)',  bg: 'var(--spoken-bg)' },
    writing:   { label: 'WRITING',   c: '#C2603F',        bg: 'rgba(194,96,63,.12)' },
  };
  const SkillChip = ({ skill, style }) => {
    const s = SKILL[skill];
    return e('span', { style: { display: 'inline-flex', alignItems: 'center', gap: 6,
      padding: '5px 11px', borderRadius: 999, background: s.bg,
      fontFamily: 'var(--font-body)', fontWeight: 700, fontSize: 10.5, letterSpacing: '0.08em',
      color: s.c, ...style } },
      e('span', { style: { width: 6, height: 6, borderRadius: '50%', background: s.c } }), s.label);
  };

  /* =====================================================================
     ONBOARDING TOP BAR — wordmark + Skip + segmented progress
     ===================================================================== */
  const OnbBar = ({ step = 0, total = 4 }) =>
    e('div', { style: { flexShrink: 0 } },
      e('div', { style: { display: 'flex', alignItems: 'center', justifyContent: 'space-between' } },
        e(MiniMark, { size: 20 }),
        e('div', { style: { textAlign: 'right' } },
          e('span', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 14, color: 'var(--ink)' } }, 'Ohita'),
          e('span', { style: { display: 'block', fontFamily: 'var(--font-body)', fontSize: 11.5, color: 'var(--ink-3)' } }, 'Skip'))),
      e('div', { style: { marginTop: 13 } }, e(Steps, { total, current: step, color: 'var(--ink)' })));

  /* =====================================================================
     EXERCISE TOP BAR — circular nav button + centered context + counter
     `nav`: 'close' | 'back' | null
     ===================================================================== */
  const RoundBtn = ({ icon, onClick, size = 48 }) =>
    e('button', { onClick, 'aria-label': icon, className: 'ps-press', style: {
      width: size, height: size, borderRadius: '50%', border: 'none', cursor: 'pointer', flexShrink: 0,
      background: '#fff', color: 'var(--ink)', boxShadow: 'var(--sh-1)',
      display: 'flex', alignItems: 'center', justifyContent: 'center' } },
      Ic(icon, { size: size * 0.4, sw: 2 }));

  // Centered context label (purple eyebrow + optional EN gloss line)
  const CenterLabel = ({ fi, en, color = 'var(--written)' }) =>
    e('div', { style: { textAlign: 'center', flex: 1, minWidth: 0 } },
      e('span', { className: 'ps-label', style: { color } }, fi),
      en && e('span', { style: { display: 'block', fontFamily: 'var(--font-body)', fontStyle: 'italic',
        fontSize: 10, fontWeight: 500, color: 'var(--ink-3)', marginTop: 0 } }, en));

  // Generic exercise header. children render under the row (progress etc.)
  const ExBar = ({ nav, onNav, left, center, right, children }) =>
    e('div', { style: { flexShrink: 0 } },
      e('div', { style: { display: 'flex', alignItems: 'center', gap: 12, minHeight: 48 } },
        nav ? e(RoundBtn, { icon: nav === 'back' ? 'arrowL' : 'close', onClick: onNav })
            : (left || e('span', { style: { width: 48, flexShrink: 0 } })),
        center,
        right || e('span', { style: { width: 48, flexShrink: 0 } })),
      children && e('div', { style: { marginTop: 13 } }, children));

  /* Counter like "0/16" or "1/9" */
  const Counter = ({ a, b }) =>
    e('span', { className: 'ps-num', style: { fontFamily: 'var(--font-display)', fontWeight: 700,
      fontSize: 15.8, color: 'var(--ink)', flexShrink: 0 } },
      a, e('span', { style: { color: 'var(--ink-3)' } }, '/' + b));

  /* =====================================================================
     BOTTOM TAB BAR — identical across every in-app screen.
     active: learn | review | sentences | practice | progress
     ===================================================================== */
  const TABS = [
    { id: 'home', icon: 'home' },
    { id: 'learn', icon: 'book' },
    { id: 'sentences', icon: 'lines' },
    { id: 'practice', icon: 'mic' },
    { id: 'progress', icon: 'chart' },
  ];
  const TabBar = ({ active }) =>
    e('div', { style: { position: 'absolute', left: 0, right: 0, bottom: 0, zIndex: 40,
      paddingBottom: 18, paddingLeft: 18, paddingRight: 18, pointerEvents: 'none' } },
      e('div', { style: { display: 'flex', alignItems: 'center', justifyContent: 'space-between',
        padding: '10px 16px', borderRadius: 999, background: '#fff',
        boxShadow: 'var(--sh-2)', border: '1px solid var(--glass-line)', pointerEvents: 'auto' } },
        TABS.map((t) => {
          const on = active === t.id;
          return e('span', { key: t.id, style: {
            width: on ? 50 : 44, height: on ? 50 : 44, borderRadius: '50%',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            background: on ? 'var(--ink)' : 'transparent', color: on ? 'var(--on-dark)' : 'var(--ink-3)' } },
            Ic(t.icon, { size: 23, sw: on ? 2 : 1.8 }));
        })));

  /* =====================================================================
     HUB HEADER — eyebrow + big title + subtitle (+ optional centered orb)
     ===================================================================== */
  const HubHeader = ({ eyebrowFi, eyebrowEn, eyebrowColor, title, sub, center, titleSize = 33 }) =>
    e('div', { style: { textAlign: center ? 'center' : 'left' } },
      (eyebrowFi || eyebrowEn) && e(Eyebrow, { fi: eyebrowFi, en: eyebrowEn, color: eyebrowColor, center,
        style: { marginBottom: 14 } }),
      e('h1', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: titleSize,
        lineHeight: 1.0, letterSpacing: '-0.03em', color: 'var(--ink)', margin: 0 } }, title),
      sub && e('p', { style: { fontFamily: 'var(--font-body)', fontWeight: 500, fontSize: 14.4,
        lineHeight: 1.45, color: 'var(--ink-2)', margin: '12px 0 0', textWrap: 'pretty',
        maxWidth: center ? 320 : 'none', marginLeft: center ? 'auto' : 0, marginRight: center ? 'auto' : 0 } }, sub));

  /* Big centered bilingual title (FI then EN under, muted) */
  const BigTitle = ({ fi, en, size = 33 }) =>
    e('div', null,
      e('h1', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: size,
        lineHeight: 1.0, letterSpacing: '-0.03em', color: 'var(--ink)', margin: 0 } }, fi),
      en && e('div', { style: { fontFamily: 'var(--font-body)', fontStyle: 'italic', fontWeight: 500,
        fontSize: size * 0.48, lineHeight: 1.05, color: 'var(--ink-3)', marginTop: 2 } }, en));

  /* =====================================================================
     CHOICE / LIST CARD — icon tile + FI title + (EN) + desc + trailing
     ===================================================================== */
  const IconTile = ({ icon, color = 'var(--written)', bg = 'var(--written-bg)', size = 52, r = 16 }) =>
    e('span', { style: { width: size, height: size, borderRadius: r, flexShrink: 0,
      background: bg, color, display: 'flex', alignItems: 'center', justifyContent: 'center' } },
      Ic(icon, { size: size * 0.44, sw: 1.9 }));

  const Card = ({ children, onWhite = true, pad = 16, r = 'var(--r-lg)', style }) =>
    e('div', { className: 'ps-card', style: { padding: pad, borderRadius: r, ...style } }, children);

  // List row: icon | (title + en + desc) | trailing
  const ChoiceCard = ({ icon, iconColor, iconBg, title, en, desc, trailing, style, align = 'center' }) =>
    e('div', { className: 'ps-card', style: { padding: 16, display: 'flex', alignItems: align === 'top' ? 'flex-start' : 'center', gap: 14, ...style } },
      icon && e(IconTile, { icon, color: iconColor, bg: iconBg }),
      e('div', { style: { flex: 1, minWidth: 0 } },
        e('div', { style: { display: 'flex', alignItems: 'baseline', gap: 8, flexWrap: 'wrap' } },
          e('span', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 15.5,
            letterSpacing: '-0.01em', color: 'var(--ink)' } }, title),
          en && e(Gloss, null, en)),
        desc && e('div', { style: { fontFamily: 'var(--font-body)', fontWeight: 500, fontSize: 14,
          lineHeight: 1.4, color: 'var(--ink-2)', marginTop: 5, textWrap: 'pretty' } }, desc)),
      trailing);

  const TrailArrow = () => e('span', { style: { color: 'var(--ink-3)', flexShrink: 0 } }, Ic('arrow', { size: 22, sw: 2 }));

  /* =====================================================================
     CTA — full-width pill, bilingual stacked label, optional icon
     variant: ink | light | accent | spoken
     ===================================================================== */
  const CTA = ({ fi, en, icon, iconRight, variant = 'ink', flex, onClick, style }) => {
    const themes = {
      ink:    { background: 'var(--ink)', color: 'var(--on-dark)', shadow: '0 10px 24px -8px rgba(27,26,32,.45)' },
      accent: { background: 'var(--written)', color: '#fff', shadow: '0 10px 24px -8px rgba(107,70,193,.5)' },
      spoken: { background: 'var(--spoken)', color: '#fff', shadow: '0 10px 24px -8px rgba(31,124,142,.5)' },
      light:  { background: '#fff', color: 'var(--ink)', shadow: 'var(--sh-1)', border: '1px solid var(--glass-line)' },
    };
    const th = themes[variant];
    const dim = th.color === 'var(--ink)' ? 'var(--ink-3)' : 'rgba(255,255,255,.6)';
    return e('button', { onClick, className: 'ps-press', style: {
      flex: flex || 'none', width: flex ? 'auto' : '100%', border: th.border || 'none', cursor: 'pointer',
      background: th.background, color: th.color, boxShadow: th.shadow, borderRadius: 999,
      padding: '13px 22px', minHeight: 56, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 12, ...style } },
      icon && Ic(icon, { size: 21, sw: 2 }),
      e('span', { style: { display: 'flex', flexDirection: 'column', alignItems: 'center', lineHeight: 1.05 } },
        e('span', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 15.5, letterSpacing: '-0.01em' } }, fi),
        en && e('span', { style: { fontFamily: 'var(--font-body)', fontStyle: 'italic', fontWeight: 500, fontSize: 11, color: dim, marginTop: 0 } }, en)),
      iconRight && Ic(iconRight, { size: 21, sw: 2 }));
  };

  /* Tappable answer / option row (quiz, listen-choose) */
  const OptionRow = ({ children, state, style }) => {
    const map = {
      correct: { border: '1.5px solid var(--spoken)', background: 'var(--spoken-bg)' },
      wrong:   { border: '1.5px solid #C2603F', background: 'rgba(194,96,63,.08)' },
    };
    const st = state ? map[state] : {};
    return e('div', { className: 'ps-card', style: {
      padding: '17px 22px', borderRadius: 'var(--r-lg)',
      fontFamily: 'var(--font-display)', fontWeight: 600, fontSize: 16.3, color: 'var(--ink)', ...st, ...style } }, children);
  };

  /* Text input field (placeholder look) */
  const Field = ({ placeholder, value, focus, multiline, style }) =>
    e('div', { className: 'ps-card', style: {
      padding: multiline ? '17px 18px' : '17px 18px', borderRadius: 'var(--r-lg)',
      border: focus ? '1.5px solid var(--flag)' : '1px solid var(--glass-line)',
      minHeight: multiline ? 84 : 'auto',
      fontFamily: 'var(--font-display)', fontWeight: value ? 700 : 600, fontSize: 17.2,
      color: value ? 'var(--ink)' : 'var(--ink-3)', ...style } }, value || placeholder);

  /* Audio waveform (decorative) */
  const Waveform = ({ color = 'var(--written)', n = 26, active = 0.55, h = 40, style }) =>
    e('div', { style: { display: 'flex', alignItems: 'center', gap: 3, height: h, ...style } },
      Array.from({ length: n }).map((_, i) => {
        const base = 5 + Math.abs(Math.sin(i * 0.8)) * (h - 10);
        return e('span', { key: i, style: { width: 3, borderRadius: 2, height: base,
          background: color, opacity: i / n < active ? 0.9 : 0.3 } });
      }));

  Object.assign(window.APP = window.APP || {}, {
    e, Ic, Phone, Screen, Wordmark, MiniMark, Eyebrow, Gloss, SkillChip, SKILL,
    OnbBar, ExBar, RoundBtn, CenterLabel, Counter, TabBar, HubHeader, BigTitle,
    IconTile, Card, ChoiceCard, TrailArrow, CTA, OptionRow, Field, Waveform,
  });
})();
