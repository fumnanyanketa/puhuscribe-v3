/* PuhuScribe v2 — Onboarding flow screens (1-5). window.SCREENS.* */
(function () {
  const e = React.createElement;
  const PS = window.PS, A = window.APP;
  const { I, Bar, Steps, RegisterCard, OrbCluster } = PS;
  const { Phone, Screen, OnbBar, MiniMark, HubHeader, Eyebrow, Gloss, ChoiceCard, IconTile, CTA, SkillChip } = A;

  const S = (window.SCREENS = window.SCREENS || {});

  /* ---- 1 · AUTH ---- */
  S.Auth = () => e(Screen, { pad: 26, style: { paddingTop: 14 } },
    e(MiniMark, { size: 22 }),
    e('div', { style: { display: 'flex', flexDirection: 'column', paddingTop: 14 } },
      e('div', { style: { display: 'flex', justifyContent: 'center', marginBottom: 12 } }, e(OrbCluster, { size: 72 })),
      e('h1', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 27.4, letterSpacing: '-0.035em', lineHeight: 1, color: 'var(--ink)', margin: 0 } }, 'Kirjaudu sisään'),
      e('p', { style: { fontFamily: 'var(--font-body)', fontWeight: 500, fontSize: 14.9, color: 'var(--ink-2)', margin: '8px 0 0' } }, 'Sign in to continue.'),
      // tab toggle
      e('div', { style: { display: 'flex', padding: 6, borderRadius: 999, background: 'var(--glass-deep)', marginTop: 20 } },
        [['Kirjaudu', 'Log in', true], ['Luo tili', 'Sign up', false]].map(([fi, en, on], i) =>
          e('div', { key: i, style: { flex: 1, textAlign: 'center', padding: '12px 0', borderRadius: 999,
            background: on ? '#fff' : 'transparent', boxShadow: on ? 'var(--sh-1)' : 'none' } },
            e('div', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 14.9, color: on ? 'var(--ink)' : 'var(--ink-3)' } }, fi),
            e('div', { style: { fontFamily: 'var(--font-body)', fontStyle: 'italic', fontSize: 11, color: 'var(--ink-3)' } }, en)))),
      // fields
      e('div', { style: { marginTop: 20 } },
        e(FieldLabel, { fi: 'Sähköposti', en: 'Email' }),
        e(Input, { placeholder: 'you@example.com' })),
      e('div', { style: { marginTop: 14 } },
        e(FieldLabel, { fi: 'Salasana', en: 'Password' }),
        e(Input, { placeholder: 'At least 6 characters', trailing: I('eye', { size: 22 }) }))),
    e('div', { style: { flex: 1, minHeight: 10 } }),
    e(CTA, { fi: 'Kirjaudu sisään', en: 'Log in', variant: 'ink' }));

  const FieldLabel = ({ fi, en }) =>
    e('div', { style: { marginBottom: 8 } },
      e('div', { style: { fontFamily: 'var(--font-display)', fontWeight: 600, fontSize: 14.9, color: 'var(--ink)' } }, fi),
      e('div', { style: { fontFamily: 'var(--font-body)', fontStyle: 'italic', fontSize: 11.5, color: 'var(--ink-3)', marginTop: 0 } }, en));

  const Input = ({ placeholder, trailing }) =>
    e('div', { className: 'ps-card', style: { padding: '14px 18px', borderRadius: 'var(--r-lg)',
      display: 'flex', alignItems: 'center', gap: 12 } },
      e('span', { style: { flex: 1, fontFamily: 'var(--font-body)', fontWeight: 500, fontSize: 15.8, color: 'var(--ink-3)' } }, placeholder),
      trailing && e('span', { style: { color: 'var(--ink-3)' } }, trailing));

  /* ---- 2 · WELCOME ---- */
  S.Welcome = () => e(Screen, { style: { paddingTop: 8 } },
    e(OnbBar, { step: 0, total: 4 }),
    e('div', { style: { display: 'flex', justifyContent: 'center', margin: '10px 0 2px' } }, e(OrbCluster, { size: 132 })),
    e('div', { style: { flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'center' } },
      e(Eyebrow, { fi: 'TERVETULOA', en: 'Welcome', style: { marginBottom: 12 } }),
      e('h1', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 25.9, lineHeight: 0.98, letterSpacing: '-0.035em', color: 'var(--ink)', margin: 0 } },
        'Speak the Finnish Finland ', e('span', { style: { color: 'var(--written)' } }, 'actually'), ' speaks'),
      e('p', { style: { fontFamily: 'var(--font-body)', fontWeight: 500, fontSize: 15.8, lineHeight: 1.5, color: 'var(--ink-2)', margin: '18px 0 0', textWrap: 'pretty' } },
        'Finnish for your new life here. The textbook language and the spoken street language, taught together from day one.')),
    e(CTA, { fi: 'Jatka', en: 'Continue', iconRight: 'arrow', variant: 'ink', style: { marginTop: 16 } }));

  /* ---- 3 · TWO REGISTERS ---- */
  S.TwoRegisters = () => e(Screen, { style: { paddingTop: 8 } },
    e(OnbBar, { step: 1, total: 4 }),
    e('div', { style: { marginTop: 12 } },
      e(Eyebrow, { fi: 'MIKSI KAKSI', en: 'Why two', style: { marginBottom: 8 } }),
      e('h1', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 21.6, lineHeight: 1.0, letterSpacing: '-0.03em', color: 'var(--ink)', margin: 0 } },
        'Books teach one Finnish. The street speaks another.'),
      e('p', { style: { fontFamily: 'var(--font-body)', fontWeight: 500, fontSize: 14.5, lineHeight: 1.4, color: 'var(--ink-2)', margin: '8px 0 0', textWrap: 'pretty' } },
        'Each phrase is taught twice. First the written ',
        e('strong', { style: { color: 'var(--written)', fontWeight: 700 } }, 'kirjakieli'),
        ', then the spoken ',
        e('strong', { style: { color: 'var(--spoken)', fontWeight: 700 } }, 'puhekieli'),
        '.')),
    e('div', { style: { marginTop: 12 } },
      e(RegisterCard, { gloss: 'I am at home',
        kirja: [{ t: 'Minä', hot: true }, { t: 'olen', hot: true }, { t: 'kotona' }],
        puhe: [{ t: 'Mä', hot: true }, { t: 'oon', hot: true }, { t: 'kotona' }] })),
    e('div', { style: { flex: 1, minHeight: 8 } }),
    e('div', { style: { display: 'flex', gap: 12, marginTop: 8, alignItems: 'stretch' } },
      e(BackBtn, null),
      e(CTA, { fi: 'Jatka', en: 'Continue', iconRight: 'arrow', variant: 'ink', flex: '1' })));

  const BackBtn = () => e('button', { 'aria-label': 'Back', className: 'ps-press', style: {
    width: 62, minHeight: 62, borderRadius: 999, border: '1px solid var(--glass-line)', background: '#fff',
    color: 'var(--ink)', boxShadow: 'var(--sh-1)', cursor: 'pointer', flexShrink: 0,
    display: 'flex', alignItems: 'center', justifyContent: 'center' } }, I('arrowL', { size: 24, sw: 2 }));

  /* ---- 4 · METHOD ---- */
  S.Method = () => e(Screen, { style: { paddingTop: 8 } },
    e(OnbBar, { step: 2, total: 4 }),
    e('div', { style: { marginTop: 26 } },
      e(Eyebrow, { fi: 'MITEN', en: 'How it works', style: { marginBottom: 12 } }),
      e('h1', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 25.9, lineHeight: 1.0, letterSpacing: '-0.03em', color: 'var(--ink)', margin: 0 } }, 'A method that sticks.'),
      e('p', { style: { fontFamily: 'var(--font-body)', fontWeight: 500, fontSize: 14.9, lineHeight: 1.5, color: 'var(--ink-2)', margin: '14px 0 0', textWrap: 'pretty' } },
        'Built on how people actually learn a language, not on what feels busy.')),
    e('div', { style: { marginTop: 22, display: 'flex', flexDirection: 'column', gap: 16 } },
      e(ChoiceCard, { align: 'top', icon: 'sparkle', iconColor: 'var(--written)', iconBg: 'var(--written-bg)',
        title: 'Tapaa sanat', en: 'Meet words', desc: 'Recognise the most useful Finnish words. See it, hear it, tap the meaning.' }),
      e(ChoiceCard, { align: 'top', icon: 'review', iconColor: 'var(--written)', iconBg: 'var(--written-bg)',
        title: 'Kertaa', en: 'Review', desc: 'Spaced repetition brings each word back right before you would forget it.' }),
      e(ChoiceCard, { align: 'top', icon: 'sprout', iconColor: 'var(--written)', iconBg: 'var(--written-bg)',
        title: 'Puhu', en: 'Speak', desc: 'Say real sentences out loud, for the situations you will actually face.' })),
    e('div', { style: { flex: 1, minHeight: 16 } }),
    e('div', { style: { display: 'flex', gap: 12, marginTop: 8 } },
      e(BackBtn, null),
      e(CTA, { fi: 'Jatka', en: 'Continue', iconRight: 'arrow', variant: 'ink', flex: '1' })));

  /* ---- 5 · JOURNEY ---- */
  const MILES = [
    { fi: 'Ensimmäiset sanat', en: 'First words', lvl: 'A1', now: true,
      desc: 'Recognise your first Finnish words by sight and sound.', skills: ['reading', 'listening'] },
    { fi: 'Kasvata sanavarastoa', en: 'Grow your word bank', lvl: 'A1',
      desc: 'Meet new words daily and start producing them; spaced repetition locks them in.',
      skills: ['reading', 'writing'], unlock: 'Avautuu 1 sanalla', unlockEn: 'Unlocks at 1 words' },
    { fi: 'Puhu rohkeasti', en: 'Speak with confidence', lvl: 'A2',
      desc: 'Say and hear real-life sentences for the situations you will face.',
      skills: ['speaking', 'listening'], unlock: 'Avautuu 50 sanalla', unlockEn: 'Unlocks at 50 words' },
    { fi: 'Arjen sujuvuus', en: 'Everyday fluency', lvl: 'B1',
      desc: 'Hold everyday conversations across all four skills. YKI B1 (citizenship).',
      skills: ['speaking', 'listening', 'reading', 'writing'], unlock: 'Avautuu 300 sanalla', unlockEn: 'Unlocks at 300 words' },
    { fi: 'Työelämän suomi', en: 'Professional Finnish', lvl: 'B2',
      desc: 'Work and study in Finnish. YKI B2.',
      skills: ['speaking', 'listening', 'reading', 'writing'], unlock: 'Avautuu 1500 sanalla', unlockEn: 'Unlocks at 1500 words' },
  ];

  S.Journey = () => e(Screen, { style: { paddingTop: 8 } },
    e(OnbBar, { step: 3, total: 4 }),
    e('div', { style: { marginTop: 22 } },
      e(Eyebrow, { fi: 'POLKUSI', en: 'Your path', style: { marginBottom: 12 } }),
      e('h1', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 24.5, lineHeight: 1.0, letterSpacing: '-0.03em', color: 'var(--ink)', margin: 0 } }, 'From your first words to YKI.'),
      e('p', { style: { fontFamily: 'var(--font-body)', fontWeight: 500, fontSize: 14.9, lineHeight: 1.5, color: 'var(--ink-2)', margin: '14px 0 0', textWrap: 'pretty' } },
        'About 30 minutes a day. B1 for citizenship, B2 for work, over months not weeks. You will always see where you are.')),
    e('div', { className: 'ps-card', style: { marginTop: 20, padding: 18, borderRadius: 'var(--r-xl)' } },
      e(Timeline, null)),
    e('div', { style: { display: 'flex', gap: 12, marginTop: 18 } },
      e(BackBtn, null),
      e(CTA, { fi: 'Aloita', en: 'Start learning', icon: 'sparkle', variant: 'ink', flex: '1' })));

  function Timeline() {
    return e('div', { style: { display: 'flex', flexDirection: 'column' } },
      MILES.map((m, i) => {
        const last = i === MILES.length - 1;
        return e('div', { key: i, style: { display: 'flex', gap: 14 } },
          // rail
          e('div', { style: { width: 36, flexShrink: 0, display: 'flex', flexDirection: 'column', alignItems: 'center' } },
            e('span', { style: { width: 36, height: 36, borderRadius: '50%', flexShrink: 0,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              background: m.now ? 'var(--written)' : 'var(--glass-deep)',
              color: m.now ? '#fff' : 'var(--ink-3)' } },
              m.now ? I('sparkle', { size: 18 }) : I('lock', { size: 15, sw: 2 })),
            !last && e('span', { style: { flex: 1, width: 2, background: 'var(--glass-edge)', margin: '4px 0', minHeight: 18 } })),
          // body
          e('div', { style: { flex: 1, minWidth: 0, paddingBottom: last ? 0 : 22,
            background: m.now ? 'var(--written-bg)' : 'transparent', borderRadius: m.now ? 14 : 0,
            padding: m.now ? '12px 14px' : '0 0 22px', marginBottom: m.now ? 4 : 0,
            marginTop: m.now ? -6 : 0 } },
            e('div', { style: { display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', gap: 8 } },
              e('div', { style: { minWidth: 0 } },
                e('div', { style: { display: 'flex', alignItems: 'center', gap: 8, flexWrap: 'wrap' } },
                  e('span', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 15.8, color: m.now ? 'var(--ink)' : 'var(--ink-3)' } }, m.fi),
                  m.now && e('span', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 9.5, letterSpacing: '0.08em',
                    color: 'var(--written)', background: '#fff', borderRadius: 999, padding: '4px 9px' } }, 'NYT',
                    e('span', { style: { fontWeight: 500, fontFamily: 'var(--font-body)', opacity: .7, marginLeft: 4 } }, 'now'))),
                e('div', { style: { fontFamily: 'var(--font-body)', fontSize: 12.5, color: 'var(--ink-3)', marginTop: 2 } }, m.en)),
              e('span', { className: 'ps-num', style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 14, color: 'var(--ink-3)', flexShrink: 0 } }, m.lvl)),
            e('p', { style: { fontFamily: 'var(--font-body)', fontWeight: 500, fontSize: 13.5, lineHeight: 1.4, color: m.now ? 'var(--ink-2)' : 'var(--ink-3)', margin: '8px 0 0', textWrap: 'pretty' } }, m.desc),
            e('div', { style: { display: 'flex', flexWrap: 'wrap', gap: 7, marginTop: 10 } },
              m.skills.map((sk) => e(SkillChip, { key: sk, skill: sk }))),
            m.unlock && e('div', { style: { display: 'flex', alignItems: 'center', gap: 7, marginTop: 10, color: 'var(--ink-3)' } },
              I('lock', { size: 13, sw: 2 }),
              e('span', { style: { fontFamily: 'var(--font-body)', fontWeight: 600, fontSize: 13, color: 'var(--ink-2)' } }, m.unlock,
                e('span', { style: { fontWeight: 500, color: 'var(--ink-3)', marginLeft: 5 } }, m.unlockEn)))));
      }));
  }
})();
