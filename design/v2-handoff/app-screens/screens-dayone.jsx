/* PuhuScribe v2 — Day One flow (6-8). window.SCREENS.* */
(function () {
  const e = React.createElement;
  const PS = window.PS, A = window.APP;
  const { I, Bar, OrbCluster, Orb, SpeakerBtn, Ring } = PS;
  const { Screen, ExBar, CenterLabel, Counter, TabBar, OptionRow, CTA, Eyebrow, Gloss, HubHeader, IconTile } = A;
  const S = (window.SCREENS = window.SCREENS || {});

  const BODY_BOTTOM = 96; // room above tab bar

  /* ---- 6 · SPRINT INTRO (Day One · first-run takeover) ---- */
  const SPRINT_STEPS = [
    { icon: 'eye', fi: 'Näe sana', en: 'See the word' },
    { icon: 'volume', fi: 'Kuule se', en: 'Hear it said' },
    { icon: 'check', fi: 'Tunnista merkitys', en: 'Recognise the meaning' },
  ];
  S.VocabHub = () => e('div', { style: { position: 'absolute', inset: 0 } },
    e(Screen, { pad: 24, style: { paddingTop: 8 } },
      e(ExBar, { nav: 'close', center: e(CenterLabel, { fi: 'PÄIVÄ YKSI', en: 'Day one' }) }),
      e('div', { style: { marginTop: 22 } },
        e(Eyebrow, { fi: 'SANASTOSPRINTTI', en: 'Vocabulary sprint', color: 'var(--written)', style: { marginBottom: 12 } }),
        e('h1', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 27.4, lineHeight: 0.98, letterSpacing: '-0.035em', color: 'var(--ink)', margin: 0 } }, 'Ensimmäiset 150 sanaa'),
        e('p', { style: { fontFamily: 'var(--font-body)', fontWeight: 500, fontSize: 14.9, lineHeight: 1.5, color: 'var(--ink-2)', margin: '14px 0 0', textWrap: 'pretty' } },
          'The first 30 minutes take you through the 150 most common Finnish words, enough to start recognising the language around you.')),
      // goal card with ring
      e('div', { className: 'ps-card', style: { marginTop: 20, padding: 22, borderRadius: 'var(--r-xl)', display: 'flex', alignItems: 'center', gap: 20 } },
        e(Ring, { value: 0, max: 150, size: 96, stroke: 11, color: 'var(--written)', track: 'var(--glass-deep)' },
          e('div', { style: { textAlign: 'center' } },
            e('div', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 20.3, letterSpacing: '-0.03em', color: 'var(--ink)', lineHeight: 1 } }, '0'),
            e('div', { style: { fontFamily: 'var(--font-body)', fontWeight: 600, fontSize: 11.5, color: 'var(--ink-3)', marginTop: 2 } }, '/ 150'))),
        e('div', { style: { flex: 1, minWidth: 0 } },
          e('div', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 15.5, color: 'var(--ink)' } }, 'Tunnista 150 sanaa'),
          e(Gloss, null, 'Recognise 150 words'),
          e('p', { style: { fontFamily: 'var(--font-body)', fontWeight: 500, fontSize: 13.5, lineHeight: 1.4, color: 'var(--ink-2)', margin: '8px 0 0' } }, 'Etenet aalloittain. Edistymisesi tallentuu. ',
            e('span', { style: { color: 'var(--ink-3)' } }, 'In waves. Your progress saves.')))),
      // how it works
      e(Eyebrow, { fi: 'NÄIN SE TOIMII', en: 'How it works', color: 'var(--ink-3)', style: { marginTop: 24, marginBottom: 14 } }),
      e('div', { style: { display: 'flex', flexDirection: 'column', gap: 12 } },
        SPRINT_STEPS.map((s, i) => e('div', { key: s.icon, style: { display: 'flex', alignItems: 'center', gap: 14 } },
          e(IconTile, { icon: s.icon, size: 44, r: 13, color: 'var(--written)', bg: 'var(--written-bg)' }),
          e('div', { style: { flex: 1 } },
            e('span', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 15.3, color: 'var(--ink)' } }, s.fi),
            e('span', { style: { fontFamily: 'var(--font-body)', fontSize: 13, color: 'var(--ink-3)', display: 'block', marginTop: 1 } }, s.en)),
          e('span', { className: 'ps-num', style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 14.9, color: 'var(--ink-3)' } }, i + 1)))),
      e('div', { style: { flex: 1, minHeight: 22 } }),
      e(CTA, { fi: 'Aloita sprintti', en: 'Start the sprint', icon: 'sparkle', variant: 'ink' }),
      e('button', { className: 'ps-press', style: { marginTop: 12, width: '100%', background: 'transparent', border: 'none', cursor: 'pointer', padding: '6px 0' } },
        e('span', { style: { fontFamily: 'var(--font-body)', fontWeight: 600, fontSize: 14.5, color: 'var(--ink-2)' } }, 'Tutustun sovellukseen ensin ',
          e('span', { style: { color: 'var(--ink-3)' } }, 'Explore the app first, and pick this up anytime')))));

  /* ---- 6b · DAILY VOCABULARY BANK (recurring, post-sprint Learn tab) ---- */
  const DAILY_PREVIEW = ['kahvi', 'juna', 'kiire', 'melkein', 'sopia', 'tietysti'];
  S.DailyVocab = () => e('div', { style: { position: 'absolute', inset: 0 } },
    e(Screen, { bottom: BODY_BOTTOM, style: { paddingTop: 12 } },
      e(HubHeader, { eyebrowFi: 'PÄIVÄN SANAT', eyebrowEn: "Today's words", title: '15 uutta sanaa' }),
      // progress toward 1000
      e('div', { className: 'ps-card', style: { marginTop: 16, padding: 18, borderRadius: 'var(--r-xl)' } },
        e('div', { style: { display: 'flex', alignItems: 'baseline', justifyContent: 'space-between' } },
          e('span', null,
            e('span', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 21.6, letterSpacing: '-0.03em', color: 'var(--ink)' } }, '240'),
            e('span', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 15.5, color: 'var(--ink-3)' } }, ' / 1000')),
          e('span', { style: { display: 'inline-flex', alignItems: 'center', gap: 6, padding: '6px 11px', borderRadius: 999, background: 'var(--written-bg)' } },
            e('span', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 13, color: 'var(--written)' } }, 'Taso A1'))),
        e('div', { style: { fontFamily: 'var(--font-body)', fontWeight: 500, fontSize: 13.5, color: 'var(--ink-2)', margin: '4px 0 14px' } }, 'sanaa opittu ',
          e('span', { style: { color: 'var(--ink-3)' } }, 'words learned · goal in ~6 weeks')),
        e(Bar, { value: 24, color: 'var(--written)', track: 'var(--glass-deep)', h: 9 })),
      // today's set preview
      e(Eyebrow, { fi: 'TÄNÄÄN VUOROSSA', en: "Today's set", color: 'var(--ink-3)', style: { marginTop: 18, marginBottom: 12 } }),
      e('div', { className: 'ps-card', style: { padding: 18, borderRadius: 'var(--r-lg)' } },
        e('div', { style: { display: 'flex', flexWrap: 'wrap', gap: 9 } },
          DAILY_PREVIEW.map((w) => e('span', { key: w, style: { padding: '9px 15px', borderRadius: 999, background: 'var(--written-bg)',
            fontFamily: 'var(--font-display)', fontWeight: 600, fontSize: 14.4, color: 'var(--ink)' } }, w)),
          e('span', { style: { padding: '9px 15px', borderRadius: 999, background: 'transparent',
            fontFamily: 'var(--font-body)', fontWeight: 600, fontSize: 14, color: 'var(--ink-3)' } }, '+9 lisää'))),
      e('div', { style: { flex: 1, minHeight: 18 } }),
      e(CTA, { fi: 'Aloita', en: 'Start · 15 words', iconRight: 'arrow', variant: 'ink' })),
    e(TabBar, { active: 'learn' }));

  /* ---- 7 · WORD CARD ---- */
  S.WordCard = () => e(Screen, { bottom: 26, style: { paddingTop: 8 } },
      e(ExBar, { nav: 'close',
        center: e('span', { className: 'ps-label', style: { color: 'var(--written)' } }, 'DAY ONE · WAVE 1 / 8'),
        right: e(Counter, { a: 0, b: 16 }) },
        e(Bar, { value: 2, color: 'var(--ink)', track: 'var(--glass-deep)', h: 7 })),
      e('div', { className: 'ps-card', style: { marginTop: 20, padding: 0, borderRadius: 'var(--r-xl)', overflow: 'hidden' } },
        e('div', { style: { background: 'var(--written-bg)', padding: '18px 22px', display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 14 } },
          e('span', { className: 'ps-label', style: { color: 'var(--written)' } }, 'SANA',
            e('span', { style: { fontFamily: 'var(--font-body)', fontStyle: 'italic', fontWeight: 500, fontSize: 10.5, color: 'var(--ink-3)', display: 'block', marginTop: 1, letterSpacing: 0, textTransform: 'none' } }, 'word')),
          e(SpeakerBtn, { reg: 'kirja', size: 50 })),
        e('div', { style: { padding: '22px 24px 26px' } },
          e('div', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 37.4, letterSpacing: '-0.04em', lineHeight: 1, color: 'var(--ink)' } }, 'olla'),
          e('div', { style: { fontFamily: 'ui-monospace, SFMono-Regular, Menlo, monospace', fontSize: 17.2, color: 'var(--written)', marginTop: 12 } }, "/\u02C8ol\u02D0\u0251/"),
          e('div', { style: { fontFamily: 'var(--font-body)', fontWeight: 500, fontSize: 16.3, color: 'var(--ink-2)', marginTop: 8 } }, '"to be"'),
          e('hr', { className: 'ps-rule', style: { margin: '20px 0' } }),
          e('div', { style: { display: 'flex', alignItems: 'center', gap: 10, flexWrap: 'wrap' } },
            e('span', { className: 'ps-label', style: { color: 'var(--written)' } }, 'KIRJA'),
            e('span', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 16.3, color: 'var(--ink)' } }, 'olla'),
            e('span', { style: { color: 'var(--ink-3)' } }, I('arrow', { size: 18, sw: 2 })),
            e('span', { className: 'ps-label', style: { color: 'var(--spoken)' } }, 'PUHE'),
            e('span', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 16.3, color: 'var(--ink)' } }, 'olla'),
            e('span', { style: { fontFamily: 'var(--font-body)', fontSize: 14, color: 'var(--ink-3)' } }, '· sama')))),
      e('div', { style: { flex: 1, minHeight: 16 } }),
      e(CTA, { fi: 'Testaa minua', en: 'Test me', iconRight: 'arrow', variant: 'ink' }));

  /* ---- 8 · RECOGNISE QUIZ ---- */
  S.Quiz = () => e(Screen, { bottom: 26, style: { paddingTop: 8 } },
      e(ExBar, { nav: 'close',
        center: e('span', { className: 'ps-label', style: { color: 'var(--written)' } }, 'DAY ONE · WAVE 1 / 8'),
        right: e(Counter, { a: 0, b: 16 }) },
        e(Bar, { value: 2, color: 'var(--ink)', track: 'var(--glass-deep)', h: 7 })),
      e('div', { style: { textAlign: 'center', marginTop: 14 } },
        e('span', { className: 'ps-label', style: { color: 'var(--ink-3)' } }, 'TUNNISTA',
          e('span', { style: { fontFamily: 'var(--font-body)', fontStyle: 'italic', fontWeight: 500, fontSize: 10.5, color: 'var(--ink-3)', display: 'block', marginTop: 1, letterSpacing: 0, textTransform: 'none' } }, 'Recognise')),
        e('div', { style: { display: 'flex', justifyContent: 'center', margin: '14px 0 4px' } },
          e(SpeakerBtn, { reg: 'kirja', size: 52 })),
        e('div', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 33.1, letterSpacing: '-0.04em', color: 'var(--ink)' } }, 'olla'),
        e('div', { style: { fontFamily: 'var(--font-body)', fontWeight: 600, fontSize: 15.5, color: 'var(--ink-2)', marginTop: 8 } }, 'Mitä tämä tarkoittaa?',
          e('span', { style: { display: 'block', fontWeight: 500, fontSize: 13.5, color: 'var(--ink-3)', marginTop: 1 } }, 'What does this mean?'))),
      e('div', { style: { flex: 1, minHeight: 12 } }),
      e('div', { style: { display: 'flex', flexDirection: 'column', gap: 11 } },
        ['and', 'no, not', 'to be', 'I, me'].map((t) => e(OptionRow, { key: t }, t))));
})();
