/* PuhuScribe v2 — Onboarding + Day One Sprint ("Lake Glass"). window.PS.screens.{Onboarding,DayOne} */
(function () {
  const e = React.createElement;
  const { I, Label, Btn, RegisterCard, OrbCluster, Orb, IconBtn, Steps } = window.PS;
  const { PuhuMark, ScreenScroll } = window.PS.shell;

  /* =======================================================================
     ONBOARDING — 3-step welcome
     ===================================================================== */
  const ONB = [
    {
      key: 'welcome',
      render: () => e('div', { style: { flex: 1, display: 'flex', flexDirection: 'column' } },
        e('div', { style: { flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'center', gap: 30 } },
          e('div', { style: { display: 'flex', justifyContent: 'center' } }, e(OrbCluster, { size: 220 })),
          e('div', null,
            e(Label, { color: 'var(--written)' }, 'Tervetuloa · Welcome'),
            e('h1', { className: 'ps-display', style: { margin: '14px 0 0', fontSize: 42 } },
              'Puhu niin kuin ', e('span', { style: { color: 'var(--written)' } }, 'täällä'), ' puhutaan'),
            e('p', { className: 'ps-body-l', style: { color: 'var(--ink-2)', marginTop: 14, maxWidth: 300 } },
              'Finnish as it is really spoken — for your new life in Finland. Two registers, one habit a day.')))),
    },
    {
      key: 'register',
      render: () => e('div', { style: { flex: 1, display: 'flex', flexDirection: 'column' } },
        e('div', { style: { marginTop: 4 } },
          e(Label, { color: 'var(--written)' }, 'Miksi kaksi · Why two'),
          e('h2', { className: 'ps-title-1', style: { margin: '12px 0 0' } },
            'Books teach one Finnish. The street speaks another.')),
        e('p', { className: 'ps-body', style: { color: 'var(--ink-2)', marginTop: 12 } },
          'Every card pairs the written form (kirjakieli) with how people actually say it (puhekieli). The azure marks what changes.'),
        e('div', { style: { marginTop: 20 } },
          e(RegisterCard, { glass: true, onPlay: () => {}, gloss: 'I am at home',
            kirja: [{ t: 'Minä', hot: true }, { t: 'olen', hot: true }, { t: 'kotona' }],
            puhe: [{ t: 'Mä', hot: true }, { t: 'oon', hot: true }, { t: 'kotona' }] })),
        e('div', { style: { flex: 1 } })),
    },
    {
      key: 'dayone',
      render: () => e('div', { style: { flex: 1, display: 'flex', flexDirection: 'column' } },
        e('div', { style: { flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'center' } },
          e('div', { style: { display: 'flex', justifyContent: 'center', marginBottom: 30 } }, e(OrbCluster, { size: 200 })),
          e('div', { style: { textAlign: 'center' } },
            e(Label, { color: 'var(--written)', style: { display: 'block' } }, 'Day One Sprint'),
            e('h2', { className: 'ps-title-1', style: { margin: '12px 0 0' } }, '150 words. One sitting.'),
            e('p', { className: 'ps-body', style: { color: 'var(--ink-2)', marginTop: 12, maxWidth: 290, marginInline: 'auto' } },
              'A fast first wave of recognition — mnemonic, then a quick check. No typing. You only do this once.')),
          e('div', { style: { display: 'flex', gap: 8, justifyContent: 'center', marginTop: 26, flexWrap: 'wrap' } },
            ['Recognise', 'No typing', 'One sitting'].map((t) =>
              e('span', { key: t, className: 'ps-chip ps-chip--glass' }, t))))),
    },
  ];

  function Onboarding({ go }) {
    const [i, setI] = React.useState(0);
    const last = i === ONB.length - 1;
    return e(ScreenScroll, null,
      e('div', { style: { display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 18 } },
        e(PuhuMark, { size: 19 }),
        e('button', { onClick: () => go('dayone'), className: 'ps-press', style: {
          background: 'none', border: 'none', cursor: 'pointer', color: 'var(--ink-2)',
          fontFamily: 'var(--font-body)', fontWeight: 600, fontSize: 13.5 } }, 'Ohita')),
      e('div', { style: { marginBottom: 22 } }, e(Steps, { total: ONB.length, current: i })),
      ONB[i].render(),
      e('div', { style: { marginTop: 18, display: 'flex', gap: 12, alignItems: 'center' } },
        i > 0 && e(IconBtn, { icon: 'arrowL', tone: 'glass', size: 54, onClick: () => setI(i - 1) }),
        e(Btn, { variant: 'primary', block: true, iconRight: last ? null : 'arrow', icon: last ? 'sparkle' : null,
          onClick: () => last ? go('dayone') : setI(i + 1) }, last ? 'Aloita Day One' : 'Jatka')));
  }

  /* =======================================================================
     DAY ONE SPRINT
     ===================================================================== */
  const WORDS = [
    { fi: 'kahvi', en: 'coffee', ipa: 'KAH-vee', bridge: 'A “cuppa” at the café — kah-vee.', orb: ['var(--orb-magenta)', 'var(--orb-pink)'], puhe: null },
    { fi: 'koti', en: 'home', ipa: 'KOH-ti', bridge: 'Cosy “koti” — your home.', orb: ['var(--orb-violet)', 'var(--orb-magenta)'], puhe: null },
    { fi: 'ruoka', en: 'food', ipa: 'RUO-ka', bridge: 'You “roar-ka” when hungry for food.', orb: ['var(--orb-deep)', 'var(--orb-violet)'], puhe: null },
    { fi: 'kauppa', en: 'shop', ipa: 'KOWP-pa', bridge: '“Cow-pa” pops to the shop.', orb: ['var(--orb-pink)', '#7FC6D8'], puhe: null },
    { fi: 'terve', en: 'hi / hello', ipa: 'TER-veh', bridge: 'Wave and say “ter-veh”.', orb: ['var(--orb-magenta)', 'var(--orb-violet)'], puhe: null },
  ];

  function DayOne({ go }) {
    const [idx, setIdx] = React.useState(0);
    const [phase, setPhase] = React.useState('card');
    const [picked, setPicked] = React.useState(null);
    const [mastered, setMastered] = React.useState(34);
    const w = WORDS[idx % WORDS.length];

    const options = React.useMemo(() => {
      const others = WORDS.filter((x) => x.fi !== w.fi).slice(0, 3).map((x) => x.en);
      return [w.en, ...others].sort((a, b) => ((a.length + idx) % 3) - ((b.length + idx) % 3));
    }, [idx]);

    const next = () => { setMastered((m) => m + 1); setPicked(null); setPhase('card'); setIdx((x) => x + 1); };
    const wave = Math.min(8, Math.floor(mastered / 19) + 1);

    return e('div', { style: { position: 'absolute', inset: 0 } },
      e(ScreenScroll, null,
        // header
        e('div', { style: { display: 'flex', alignItems: 'center', justifyContent: 'space-between' } },
          e(IconBtn, { icon: 'close', tone: 'glass', size: 40, onClick: () => go('daily') }),
          e(Label, { color: 'var(--written)' }, `Day One · Aalto ${wave} / 8`),
          e('span', { className: 'ps-label ps-num', style: { color: 'var(--ink)' } }, `${mastered}/150`)),
        e('div', { style: { marginTop: 12, height: 7, borderRadius: 999, background: 'var(--glass-deep)', overflow: 'hidden' } },
          e('div', { style: { width: `${(mastered / 150) * 100}%`, height: '100%', borderRadius: 999,
            background: 'linear-gradient(90deg, var(--written), var(--spoken))', transition: 'width .5s' } })),

        phase === 'card'
          ? e('div', { key: 'card' + idx, style: { flex: 1, display: 'flex', flexDirection: 'column', marginTop: 22 } },
              e('div', { className: 'ps-glass', style: { padding: 0, overflow: 'hidden', flexShrink: 0, borderRadius: 'var(--r-2xl)' } },
                // orb hero
                e('div', { style: { height: 188, position: 'relative', display: 'flex', alignItems: 'center', justifyContent: 'center',
                  background: 'radial-gradient(120% 90% at 70% 20%, rgba(255,255,255,.5), transparent), var(--lav-tint)' } },
                  e('div', { style: { position: 'absolute', top: 14, left: 16 } }, e(Label, { color: 'var(--written)' }, 'Muistikuva · mnemonic')),
                  e(OrbCluster, { size: 150 }),
                  e('div', { style: { position: 'absolute', bottom: 12, right: 16 }, className: 'ps-caption' }, '[ 3D render ]')),
                e('div', { style: { padding: 22 } },
                  e('div', { style: { display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', gap: 12 } },
                    e('div', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 44, lineHeight: 1, letterSpacing: '-0.04em' } }, w.fi),
                    e('span', { className: 'ps-label ps-num', style: { color: 'var(--ink-3)' } }, w.ipa)),
                  e('div', { className: 'ps-body-l', style: { marginTop: 8, color: 'var(--ink-2)' } }, '“', w.en, '”'),
                  e('div', { style: { marginTop: 16, padding: '13px 15px', background: 'var(--flag-bg)', borderRadius: 'var(--r-md)',
                    display: 'flex', gap: 10, alignItems: 'flex-start' } },
                    e('span', { style: { color: 'var(--flag)', flexShrink: 0, marginTop: 1 } }, I('sparkle', { size: 18 })),
                    e('span', { className: 'ps-body', style: { color: 'var(--ink)' } }, w.bridge)),
                  e('div', { style: { marginTop: 16, display: 'flex', alignItems: 'center', gap: 10, flexWrap: 'wrap',
                    paddingTop: 16, borderTop: '1px solid var(--glass-edge)' } },
                    e('span', { className: 'ps-label', style: { color: 'var(--written)' } }, 'Kirja'),
                    e('span', { style: { fontFamily: 'var(--font-display)', fontWeight: 600, fontSize: 15 } }, w.fi),
                    e('span', { style: { color: 'var(--ink-3)' } }, I('arrow', { size: 15 })),
                    e('span', { className: 'ps-label', style: { color: 'var(--spoken)' } }, 'Puhe'),
                    e('span', { style: { fontFamily: 'var(--font-body)', fontWeight: 600, fontSize: 15 } }, w.puhe || w.fi),
                    !w.puhe && e('span', { className: 'ps-caption' }, '· sama'))),
              ),
              e('div', { style: { flex: 1, minHeight: 14 } }),
              e(Btn, { variant: 'primary', block: true, iconRight: 'arrow', onClick: () => setPhase('quiz') }, 'Testaa minua'))
          : e('div', { key: 'quiz' + idx, style: { flex: 1, display: 'flex', flexDirection: 'column', marginTop: 22 } },
              e('div', { style: { textAlign: 'center', marginTop: 10 } },
                e(Label, { color: 'var(--ink-3)' }, 'Tunnista · Recognise'),
                e('div', { style: { display: 'flex', justifyContent: 'center', margin: '18px 0 8px' } },
                  e(Orb, { size: 76, from: w.orb[0], to: w.orb[1] })),
                e('div', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 46, lineHeight: 1.05, letterSpacing: '-0.04em' } }, w.fi),
                e('div', { className: 'ps-caption', style: { marginTop: 6 } }, 'Mitä tämä tarkoittaa?')),
              e('div', { style: { flex: 1 } }),
              e('div', { style: { display: 'grid', gap: 10 } },
                options.map((opt) => {
                  const correct = opt === w.en, chosen = picked === opt;
                  let bg = 'var(--glass-2)', bd = 'var(--glass-line)', col = 'var(--ink)';
                  if (picked) {
                    if (correct) { bg = 'rgba(107,70,193,.12)'; bd = 'var(--written)'; col = 'var(--written)'; }
                    else if (chosen) { bg = 'var(--flag-bg)'; bd = 'var(--flag)'; col = 'var(--flag)'; }
                  }
                  return e('button', { key: opt, disabled: !!picked, onClick: () => setPicked(opt), className: 'ps-press', style: {
                    textAlign: 'left', padding: '16px 20px', borderRadius: 'var(--r-md)', cursor: picked ? 'default' : 'pointer',
                    border: `1.5px solid ${bd}`, background: bg, color: col,
                    fontFamily: 'var(--font-display)', fontWeight: 600, fontSize: 16,
                    display: 'flex', alignItems: 'center', justifyContent: 'space-between' } },
                    opt,
                    picked && correct && I('check', { size: 20 }),
                    picked && chosen && !correct && I('close', { size: 20 }));
                })),
              e('div', { style: { marginTop: 14, minHeight: 54 } },
                picked && e(Btn, { variant: picked === w.en ? 'accent' : 'primary', block: true, iconRight: 'arrow', onClick: next },
                  picked === w.en ? 'Hienoa — jatka' : 'Jatka')))));
  }

  window.PS.screens = Object.assign(window.PS.screens || {}, { Onboarding, DayOne });
})();
