/* PuhuScribe v2 — Practice flow (16-20). window.SCREENS.* */
(function () {
  const e = React.createElement;
  const PS = window.PS, A = window.APP;
  const { I, Bar, OrbCluster, Orb, RegisterCard } = PS;
  const { Screen, ExBar, CenterLabel, Counter, TabBar, HubHeader, CTA, IconTile, ChoiceCard, Eyebrow, Gloss, Field, OptionRow, SkillChip, Waveform } = A;
  const S = (window.SCREENS = window.SCREENS || {});
  const BODY_BOTTOM = 96;

  /* ---- 16 · PRACTICE HUB ---- */
  const SKILLS = [
    { skill: 'speaking', fi: 'Puhuminen', en: 'Speaking', icon: 'mic', desc: 'Say sentences out loud and check your pronunciation.', done: 8, total: 20 },
    { skill: 'listening', fi: 'Kuunteleminen', en: 'Listening', icon: 'volume', desc: 'Hear real Finnish and show you understood.', done: 12, total: 20 },
    { skill: 'reading', fi: 'Lukeminen', en: 'Reading', icon: 'eye', desc: 'Read short texts from everyday life.', done: 5, total: 20 },
    { skill: 'writing', fi: 'Kirjoittaminen', en: 'Writing', icon: 'pen', desc: 'Write your own sentences and get them checked.', done: 2, total: 20 },
  ];
  S.PracticeHub = () => e('div', { style: { position: 'absolute', inset: 0 } },
    e(Screen, { bottom: BODY_BOTTOM, style: { paddingTop: 12 } },
      e(HubHeader, { eyebrowFi: 'PRACTICE', title: 'Harjoittele',
        sub: 'The four skills the YKI test measures. Train each one in real situations.' }),
      e('div', { style: { marginTop: 20, display: 'flex', flexDirection: 'column', gap: 12 } },
        SKILLS.map((s) => {
          const c = A.SKILL[s.skill];
          return e('div', { key: s.skill, className: 'ps-card', style: { padding: 16, borderRadius: 'var(--r-lg)' } },
            e('div', { style: { display: 'flex', alignItems: 'flex-start', gap: 14 } },
              e(IconTile, { icon: s.icon, color: c.c, bg: c.bg }),
              e('div', { style: { flex: 1, minWidth: 0 } },
                e('div', { style: { display: 'flex', alignItems: 'baseline', gap: 8, flexWrap: 'wrap' } },
                  e('span', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 15.5, color: 'var(--ink)' } }, s.fi),
                  e(Gloss, null, s.en)),
                e('div', { style: { fontFamily: 'var(--font-body)', fontWeight: 500, fontSize: 13.5, lineHeight: 1.4, color: 'var(--ink-2)', marginTop: 4, textWrap: 'pretty' } }, s.desc)),
              e('span', { style: { color: 'var(--ink-3)', flexShrink: 0 } }, I('arrow', { size: 20, sw: 2 }))),
            e('div', { style: { marginTop: 14, display: 'flex', alignItems: 'center', gap: 10 } },
              e('div', { style: { flex: 1 } }, e(Bar, { value: (s.done / s.total) * 100, color: c.c, track: 'var(--glass-deep)', h: 6 })),
              e('span', { className: 'ps-num', style: { fontFamily: 'var(--font-body)', fontWeight: 600, fontSize: 12.5, color: 'var(--ink-3)' } }, s.done + '/' + s.total)));
        }))),
    e(TabBar, { active: 'practice' }));

  /* ---- 17 · SPEAK ---- */
  S.Speak = () => e(Screen, { bottom: 26, style: { paddingTop: 8 } },
      e(ExBar, { nav: 'close', center: e(CenterLabel, { fi: 'PUHUMINEN', en: 'Speaking', color: 'var(--spoken)' }),
        right: e(Counter, { a: 3, b: 10 }) },
        e(Bar, { value: 30, color: 'var(--spoken)', track: 'var(--glass-deep)', h: 7 })),
      e('div', { style: { textAlign: 'center', marginTop: 10 } },
        e('span', { className: 'ps-label', style: { color: 'var(--ink-3)' } }, 'SANO ÄÄNEEN',
          e('span', { style: { fontFamily: 'var(--font-body)', fontStyle: 'italic', fontWeight: 500, fontSize: 10.5, color: 'var(--ink-3)', display: 'block', marginTop: 1, letterSpacing: 0, textTransform: 'none' } }, 'Say it out loud'))),
      e('div', { style: { marginTop: 10 } },
        e(RegisterCard, { gloss: 'Could I get a coffee, please?', onPlay: () => {},
          kirja: [{ t: 'Saisinko', hot: true }, { t: 'kahvin' }, { t: 'kiitos' }],
          puhe: [{ t: 'Saisinks', hot: true }, { t: 'mä' }, { t: 'kahvin' }] })),
      e('div', { style: { flex: 1, minHeight: 8 } }),
      e('div', { style: { display: 'flex', justifyContent: 'center', marginBottom: 4 } },
        e(Waveform, { color: 'var(--spoken)', n: 30, active: 0.5, h: 32 })),
      e('p', { style: { textAlign: 'center', fontFamily: 'var(--font-body)', fontWeight: 500, fontSize: 13.5, color: 'var(--ink-3)', margin: '0 0 12px' } }, 'Paina ja puhu · Tap and speak'),
      e(CTA, { fi: 'Pidä ja puhu', en: 'Hold to speak', icon: 'mic', variant: 'spoken' }));

  /* ---- 18 · LISTEN ---- */
  S.Listen = () => e(Screen, { bottom: 26, style: { paddingTop: 8 } },
      e(ExBar, { nav: 'close', center: e(CenterLabel, { fi: 'KUUNTELEMINEN', en: 'Listening', color: 'var(--flag)' }),
        right: e(Counter, { a: 4, b: 10 }) },
        e(Bar, { value: 40, color: 'var(--flag)', track: 'var(--glass-deep)', h: 7 })),
      e('div', { style: { textAlign: 'center', marginTop: 26 } },
        e('span', { className: 'ps-label', style: { color: 'var(--ink-3)' } }, 'KUUNTELE',
          e('span', { style: { fontFamily: 'var(--font-body)', fontStyle: 'italic', fontWeight: 500, fontSize: 10.5, color: 'var(--ink-3)', display: 'block', marginTop: 1, letterSpacing: 0, textTransform: 'none' } }, 'Listen'))),
      e('div', { style: { display: 'flex', justifyContent: 'center', margin: '24px 0' } },
        e('button', { className: 'ps-press', 'aria-label': 'Play', style: { width: 132, height: 132, borderRadius: '50%', border: 'none', cursor: 'pointer',
          background: 'var(--flag)', color: '#fff', boxShadow: '0 18px 40px -14px rgba(43,111,219,.6)', display: 'flex', alignItems: 'center', justifyContent: 'center' } },
          I('volume', { size: 52, sw: 1.8 }))),
      e('div', { style: { display: 'flex', justifyContent: 'center' } }, e(Waveform, { color: 'var(--flag)', n: 32, active: 0.6, h: 44 })),
      e('p', { style: { textAlign: 'center', fontFamily: 'var(--font-body)', fontWeight: 500, fontSize: 14, color: 'var(--ink-2)', margin: '20px auto 0', maxWidth: 260, textWrap: 'pretty' } },
        'Kuuntele ja kirjoita, mitä kuulit.',
        e('span', { style: { display: 'block', fontSize: 13, color: 'var(--ink-3)', marginTop: 2 } }, 'Listen, then type what you heard.')),
      e('div', { style: { flex: 1, minHeight: 16 } }),
      e('div', { style: { marginBottom: 14 } }, e(Field, { placeholder: 'Kirjoita tähän…' })),
      e(CTA, { fi: 'Tarkista', en: 'Check', variant: 'ink' }));

  /* ---- 19 · LISTEN · CHOOSE ---- */
  S.ListenChoose = () => e(Screen, { bottom: 26, style: { paddingTop: 8 } },
      e(ExBar, { nav: 'close', center: e(CenterLabel, { fi: 'KUUNTELEMINEN', en: 'Listening', color: 'var(--flag)' }),
        right: e(Counter, { a: 5, b: 10 }) },
        e(Bar, { value: 50, color: 'var(--flag)', track: 'var(--glass-deep)', h: 7 })),
      e('div', { style: { textAlign: 'center', marginTop: 22 } },
        e('button', { className: 'ps-press', 'aria-label': 'Play again', style: { width: 76, height: 76, borderRadius: '50%', border: 'none', cursor: 'pointer',
          background: 'var(--flag-bg)', color: 'var(--flag)', display: 'inline-flex', alignItems: 'center', justifyContent: 'center' } },
          I('volume', { size: 32, sw: 1.9 })),
        e('div', { style: { fontFamily: 'var(--font-body)', fontWeight: 600, fontSize: 15.8, color: 'var(--ink)', marginTop: 16 } }, 'Mitä henkilö tilasi?',
          e('span', { style: { display: 'block', fontWeight: 500, fontSize: 13.5, color: 'var(--ink-3)', marginTop: 1 } }, 'What did the person order?'))),
      e('div', { style: { flex: 1, minHeight: 22 } }),
      e('div', { style: { display: 'flex', flexDirection: 'column', gap: 14 } },
        e(OptionRow, { state: 'correct' }, e('span', { style: { display: 'flex', alignItems: 'center', justifyContent: 'space-between' } },
          'Kahvin ja pullan', e('span', { style: { color: 'var(--spoken)' } }, I('check', { size: 24, sw: 2.6 })))),
        e(OptionRow, null, 'Teen ja voileivän'),
        e(OptionRow, null, 'Vettä, kiitos')));

  /* ---- 20 · WRITE ---- */
  S.Write = () => e(Screen, { bottom: 26, style: { paddingTop: 8 } },
      e(ExBar, { nav: 'close', center: e(CenterLabel, { fi: 'KIRJOITTAMINEN', en: 'Writing', color: '#C2603F' }),
        right: e(Counter, { a: 2, b: 8 }) },
        e(Bar, { value: 25, color: '#C2603F', track: 'var(--glass-deep)', h: 7 })),
      e('div', { style: { marginTop: 22 } },
        e('span', { className: 'ps-label', style: { color: 'var(--ink-3)' } }, 'KIRJOITA SUOMEKSI',
          e('span', { style: { fontFamily: 'var(--font-body)', fontStyle: 'italic', fontWeight: 500, fontSize: 10.5, color: 'var(--ink-3)', display: 'block', marginTop: 1, letterSpacing: 0, textTransform: 'none' } }, 'Write it in Finnish'))),
      e('div', { className: 'ps-card', style: { marginTop: 16, padding: '18px 20px', borderRadius: 'var(--r-lg)', background: 'var(--written-bg)' } },
        e('div', { style: { fontFamily: 'var(--font-body)', fontWeight: 500, fontSize: 13, color: 'var(--ink-3)', marginBottom: 6 } }, 'Translate'),
        e('div', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 17.2, letterSpacing: '-0.02em', color: 'var(--ink)', lineHeight: 1.2 } }, '"I live in Helsinki and I study Finnish."')),
      e('div', { style: { marginTop: 18 } }, e(Field, { multiline: true, value: 'Asun Helsingissä ja opiskelen', focus: true })),
      e('div', { style: { display: 'flex', gap: 8, marginTop: 14, flexWrap: 'wrap' } },
        ['suomea', 'Helsingissä', 'opiskelen', 'asun'].map((w) => e('span', { key: w, style: { padding: '9px 15px', borderRadius: 999, background: '#fff', boxShadow: 'var(--sh-1)',
          fontFamily: 'var(--font-display)', fontWeight: 600, fontSize: 14, color: 'var(--ink)' } }, w))),
      e('div', { style: { flex: 1, minHeight: 16 } }),
      e(CTA, { fi: 'Tarkista', en: 'Check', variant: 'ink' }));
})();
