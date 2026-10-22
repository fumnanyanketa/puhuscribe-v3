/* PuhuScribe v2 — Sentence Bank flow (12-15). window.SCREENS.* */
(function () {
  const e = React.createElement;
  const PS = window.PS, A = window.APP;
  const { I, Bar, OrbCluster, Orb, RegisterCard, Sentence } = PS;
  const { Screen, ExBar, CenterLabel, Counter, TabBar, HubHeader, CTA, IconTile, ChoiceCard, Eyebrow, Gloss, Field, SkillChip } = A;
  const S = (window.SCREENS = window.SCREENS || {});
  const BODY_BOTTOM = 96;

  /* ---- 12 · MY SENTENCE BANK ---- */
  S.SentenceList = () => e('div', { style: { position: 'absolute', inset: 0 } },
    e(Screen, { bottom: BODY_BOTTOM, style: { paddingTop: 12 } },
      e(HubHeader, { eyebrowFi: 'SENTENCE BANK', title: 'Omat lauseet',
        sub: 'Your own life, in Finnish. Build sets from real situations you live.' }),
      e('div', { className: 'ps-card', style: { marginTop: 20, padding: 16, borderRadius: 'var(--r-lg)', display: 'flex', gap: 16, alignItems: 'center' } },
        e(Stat, { n: '4', fi: 'settiä', en: 'sets' }),
        e('span', { style: { width: 1, alignSelf: 'stretch', background: 'var(--glass-edge)' } }),
        e(Stat, { n: '47', fi: 'lausetta', en: 'sentences' }),
        e('span', { style: { width: 1, alignSelf: 'stretch', background: 'var(--glass-edge)' } }),
        e(Stat, { n: '12', fi: 'opittu', en: 'learned' })),
      e(Eyebrow, { fi: 'SETTISI', en: 'Your sets', color: 'var(--ink-3)', style: { marginTop: 24, marginBottom: 14 } }),
      e('div', { style: { display: 'flex', flexDirection: 'column', gap: 12 } },
        e(SetRow, { title: 'Lääkärissä', en: 'At the doctor', n: 14, learned: 9, tone: 'var(--written)', toneBg: 'var(--written-bg)', icon: 'sparkle' }),
        e(SetRow, { title: 'Kahvilassa', en: 'At the café', n: 11, learned: 3, tone: 'var(--spoken)', toneBg: 'var(--spoken-bg)', icon: 'sprout' }),
        e(SetRow, { title: 'Töissä', en: 'At work', n: 12, learned: 0, tone: 'var(--flag)', toneBg: 'var(--flag-bg)', icon: 'bolt' }),
        e(SetRow, { title: 'Kela-asiat', en: 'Kela paperwork', n: 10, learned: 0, tone: '#C2603F', toneBg: 'rgba(194,96,63,.12)', icon: 'pencil' })),
      e('div', { style: { height: 16 } }),
      e(CTA, { fi: 'Uusi setti', en: 'New set', icon: 'plus', variant: 'ink' })),
    e(TabBar, { active: 'sentences' }));

  const Stat = ({ n, fi, en }) => e('div', { style: { flex: 1, textAlign: 'center' } },
    e('div', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 20.3, letterSpacing: '-0.03em', color: 'var(--ink)' } }, n),
    e('div', { style: { fontFamily: 'var(--font-body)', fontWeight: 600, fontSize: 13.5, color: 'var(--ink-2)', marginTop: 2 } }, fi),
    e('div', { style: { fontFamily: 'var(--font-body)', fontSize: 11.5, color: 'var(--ink-3)' } }, en));

  const SetRow = ({ title, en, n, learned, tone, toneBg, icon }) =>
    e('div', { className: 'ps-card', style: { padding: 16, borderRadius: 'var(--r-lg)', display: 'flex', alignItems: 'center', gap: 14 } },
      e(IconTile, { icon, color: tone, bg: toneBg }),
      e('div', { style: { flex: 1, minWidth: 0 } },
        e('div', { style: { display: 'flex', alignItems: 'baseline', gap: 8, flexWrap: 'wrap' } },
          e('span', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 15.5, color: 'var(--ink)' } }, title),
          e(Gloss, null, en)),
        e('div', { style: { marginTop: 9, display: 'flex', alignItems: 'center', gap: 9 } },
          e('div', { style: { flex: 1 } }, e(Bar, { value: (learned / n) * 100, color: tone, track: 'var(--glass-deep)', h: 6 })),
          e('span', { className: 'ps-num', style: { fontFamily: 'var(--font-body)', fontWeight: 600, fontSize: 12.5, color: 'var(--ink-3)', flexShrink: 0 } }, learned + '/' + n))),
      e('span', { style: { color: 'var(--ink-3)', flexShrink: 0 } }, I('arrow', { size: 20, sw: 2 })));

  /* ---- 13 · NEW SET · TOPICS ---- */
  const TOPICS = [
    ['Lääkärissä', 'At the doctor', 'sparkle'], ['Kaupassa', 'Shopping', 'bolt'],
    ['Töissä', 'At work', 'pencil'], ['Naapurit', 'Neighbours', 'user'],
    ['Lasten kanssa', 'With the kids', 'sprout'], ['Virastossa', 'Government office', 'review'],
  ];
  S.NewTopics = () => e(Screen, { style: { paddingTop: 8 } },
    e(ExBar, { nav: 'back', center: e(CenterLabel, { fi: 'UUSI SETTI · 1/2', en: 'New set · step 1 of 2' }) },
      e(Bar, { value: 50, color: 'var(--ink)', track: 'var(--glass-deep)', h: 7 })),
    e('div', { style: { marginTop: 24 } },
      e('h1', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 23, lineHeight: 1.02, letterSpacing: '-0.03em', color: 'var(--ink)', margin: 0 } }, 'Mistä haluat puhua?'),
      e('p', { style: { fontFamily: 'var(--font-body)', fontWeight: 500, fontSize: 14, color: 'var(--ink-3)', margin: '6px 0 0' } }, 'What do you want to talk about?'),
      e('p', { style: { fontFamily: 'var(--font-body)', fontWeight: 500, fontSize: 14, lineHeight: 1.45, color: 'var(--ink-2)', margin: '14px 0 0' } }, 'Pick a situation, or describe your own.')),
    e('div', { style: { marginTop: 22, display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 } },
      TOPICS.map(([fi, en, icon], i) => e('div', { key: fi, className: 'ps-card', style: {
        padding: '16px 14px', borderRadius: 'var(--r-lg)', border: i === 0 ? '1.5px solid var(--written)' : '1px solid var(--glass-line)',
        background: i === 0 ? 'var(--written-bg)' : '#fff' } },
        e(IconTile, { icon, size: 38, r: 12, color: 'var(--written)', bg: i === 0 ? '#fff' : 'var(--written-bg)' }),
        e('div', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 14.9, color: 'var(--ink)', marginTop: 10 } }, fi),
        e('div', { style: { fontFamily: 'var(--font-body)', fontSize: 12, color: 'var(--ink-3)' } }, en)))),
    e('div', { className: 'ps-card', style: { marginTop: 14, padding: '16px 18px', borderRadius: 'var(--r-lg)', display: 'flex', alignItems: 'center', gap: 12, border: '1px dashed var(--glass-edge)' } },
      e('span', { style: { color: 'var(--ink-3)' } }, I('pencil', { size: 20, sw: 1.9 })),
      e('span', { style: { fontFamily: 'var(--font-body)', fontWeight: 500, fontSize: 14, color: 'var(--ink-3)' } }, 'Kuvaile omin sanoin… ',
        e('span', { style: { fontSize: 13 } }, 'describe your own'))),
    e('div', { style: { flex: 1, minHeight: 16 } }),
    e(CTA, { fi: 'Jatka', en: 'Continue', iconRight: 'arrow', variant: 'ink', style: { marginTop: 14 } }));

  /* ---- 14 · ANSWER QUESTIONS ---- */
  S.Questions = () => e(Screen, { style: { paddingTop: 8 } },
    e(ExBar, { nav: 'back', center: e(CenterLabel, { fi: 'UUSI SETTI · 2/2', en: 'New set · step 2 of 2' }) },
      e(Bar, { value: 100, color: 'var(--ink)', track: 'var(--glass-deep)', h: 7 })),
    e('div', { style: { marginTop: 16 } },
      e(Eyebrow, { fi: 'LÄÄKÄRISSÄ', en: 'At the doctor', color: 'var(--written)', style: { marginBottom: 12 } }),
      e('h1', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 21.1, lineHeight: 1.05, letterSpacing: '-0.03em', color: 'var(--ink)', margin: 0 } }, 'Pari kysymystä, niin teemme sinulle sopivat lauseet.'),
      e('p', { style: { fontFamily: 'var(--font-body)', fontWeight: 500, fontSize: 14, color: 'var(--ink-3)', margin: '8px 0 0' } }, 'A couple of questions, so we build sentences that fit you.')),
    e('div', { style: { marginTop: 18, display: 'flex', flexDirection: 'column', gap: 14 } },
      e(QField, { fi: 'Mikä sinua vaivaa?', en: 'What\u2019s bothering you?', value: 'Päänsärky ja kuume', focus: true }),
      e(QField, { fi: 'Kuinka kauan?', en: 'For how long?', placeholder: 'esim. kolme päivää' })),
    e('div', { style: { flex: 1, minHeight: 16 } }),
    e(CTA, { fi: 'Luo lauseet', en: 'Generate sentences', icon: 'sparkle', variant: 'ink', style: { marginTop: 14 } }));

  const QField = ({ fi, en, value, placeholder, focus }) => e('div', null,
    e('div', { style: { marginBottom: 7 } },
      e('div', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 15.8, color: 'var(--ink)' } }, fi),
      e('div', { style: { fontFamily: 'var(--font-body)', fontSize: 13, color: 'var(--ink-3)' } }, en)),
    e(Field, { value, placeholder, focus }));

  /* ---- 15 · SET DETAIL ---- */
  S.SentenceDetail = () => e(Screen, { bottom: 26, style: { paddingTop: 8 } },
      e(ExBar, { nav: 'back', center: e(CenterLabel, { fi: 'SETTI', en: 'Set' }),
        right: e('span', { className: 'ps-press', style: { width: 48, height: 48, borderRadius: '50%', background: '#fff', boxShadow: 'var(--sh-1)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--ink)' } }, I('volume', { size: 20, sw: 1.9 })) }),
      e('div', { style: { marginTop: 16 } },
        e('h1', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 23, letterSpacing: '-0.03em', color: 'var(--ink)', margin: 0 } }, 'Lääkärissä'),
        e('div', { style: { fontFamily: 'var(--font-body)', fontSize: 14, color: 'var(--ink-3)', marginTop: 2 } }, 'At the doctor'),
        e('div', { style: { display: 'flex', gap: 7, marginTop: 12 } }, e(SkillChip, { skill: 'reading' }), e(SkillChip, { skill: 'speaking' }))),
      e(Eyebrow, { fi: '3 LAUSETTA', en: '3 sentences', color: 'var(--ink-3)', style: { marginTop: 22, marginBottom: 12 } }),
      e('div', { style: { display: 'flex', flexDirection: 'column', gap: 14 } },
        e(SentCard, { gloss: 'I have a headache and a fever.',
          kirja: [{ t: 'Minulla' }, { t: 'on', hot: true }, { t: 'päänsärky', hot: true }, { t: 'ja' }, { t: 'kuume' }],
          puhe: [{ t: 'Mul', hot: true }, { t: 'on', hot: true }, { t: 'päänsärky' }, { t: 'ja' }, { t: 'kuume' }] }),
        e(SentCard, { gloss: "It's been going on for three days.",
          kirja: [{ t: 'Se', hot: true }, { t: 'on', hot: true }, { t: 'kestänyt' }, { t: 'kolme' }, { t: 'päivää' }],
          puhe: [{ t: 'Se', hot: true }, { t: 'on', hot: true }, { t: 'kestäny', hot: true }, { t: 'kolme' }, { t: 'päivää' }] })));

  const SentCard = ({ kirja, puhe, gloss }) =>
    e(RegisterCard, { kirja, puhe, gloss, compact: true, onPlay: () => {} });
})();
