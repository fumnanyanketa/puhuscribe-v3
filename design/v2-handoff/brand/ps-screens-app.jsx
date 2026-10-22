/* PuhuScribe v2 — Daily / Island / Progress ("Lake Glass"). window.PS.screens.{Daily,Island,Progress} */
(function () {
  const e = React.createElement;
  const { I, Label, Btn, RegisterCard, OrbCluster, Orb, IconBtn, Ring, Bar, Steps, SpeakerBtn, Sentence, RegDot } = window.PS;
  const { ScreenScroll, PuhuMark } = window.PS.shell;

  const PHRASES = [
    { gloss: 'I am at home',
      kirja: [{ t: 'Minä', hot: true }, { t: 'olen', hot: true }, { t: 'kotona' }],
      puhe:  [{ t: 'Mä', hot: true }, { t: 'oon', hot: true }, { t: 'kotona' }] },
    { gloss: 'Do you want to come along?',
      kirja: [{ t: 'Haluatko', hot: true }, { t: 'tulla' }, { t: 'mukaan?' }],
      puhe:  [{ t: 'Haluuks', hot: true }, { t: 'sä', hot: true }, { t: 'tulla' }, { t: 'mukaan?' }] },
    { gloss: 'He / she goes to the shop',
      kirja: [{ t: 'Hän', hot: true }, { t: 'menee' }, { t: 'kauppaan' }],
      puhe:  [{ t: 'Se', hot: true }, { t: 'menee' }, { t: 'kauppaan' }] },
    { gloss: 'Are you hungry?',
      kirja: [{ t: 'Onko', hot: true }, { t: 'sinulla', hot: true }, { t: 'nälkä?' }],
      puhe:  [{ t: 'Onks', hot: true }, { t: 'sulla', hot: true }, { t: 'nälkä?' }] },
    { gloss: 'This food is good',
      kirja: [{ t: 'Tämä', hot: true }, { t: 'ruoka' }, { t: 'on' }, { t: 'hyvää' }],
      puhe:  [{ t: 'Tää', hot: true }, { t: 'ruoka' }, { t: 'on' }, { t: 'hyvää' }] },
  ];

  /* =======================================================================
     DAILY SESSION
     ===================================================================== */
  function Daily({ go }) {
    const SESSION = PHRASES.slice(0, 4);
    const [i, setI] = React.useState(0);
    const [playing, setPlaying] = React.useState(null);
    const [mastered, setMastered] = React.useState(843);
    const [done, setDone] = React.useState(false);
    const p = SESSION[i];

    const play = (reg) => { setPlaying(reg); setTimeout(() => setPlaying(null), 1100); };
    const advance = (got) => { if (got) setMastered((m) => m + 1); if (i < SESSION.length - 1) setI(i + 1); else setDone(true); };

    if (done)
      return e(ScreenScroll, { bottom: 110 },
        e('div', { style: { flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'center',
          alignItems: 'center', textAlign: 'center', gap: 24 } },
          e(OrbCluster, { size: 190 }),
          e('div', null,
            e(Label, { color: 'var(--written)', style: { display: 'block', marginBottom: 10 } }, 'Sessio valmis'),
            e('h2', { className: 'ps-title-1' }, 'Hyvää työtä.'),
            e('p', { className: 'ps-body', style: { color: 'var(--ink-2)', marginTop: 10 } },
              SESSION.length + ' phrases reviewed · ' + (mastered - 843) + ' newly mastered')),
          e('div', { className: 'ps-glass', style: { padding: '18px 24px', display: 'flex', gap: 28 } },
            e('div', null, e('div', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 32, lineHeight: 1, letterSpacing: '-0.03em' } }, mastered),
              e('div', { className: 'ps-caption', style: { marginTop: 4 } }, 'mastered')),
            e('div', { style: { width: 1, background: 'var(--glass-edge)' } }),
            e('div', null, e('div', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 32, lineHeight: 1, color: 'var(--spoken)', letterSpacing: '-0.03em' } }, '12'),
              e('div', { className: 'ps-caption', style: { marginTop: 4 } }, 'day streak'))),
          e('div', { style: { display: 'flex', gap: 10 } },
            e(Btn, { variant: 'light', onClick: () => go('island') }, 'Kielisaari'),
            e(Btn, { variant: 'primary', icon: 'chart', onClick: () => go('progress') }, 'Edistyminen'))));

    return e(ScreenScroll, { bottom: 110 },
      e('div', { style: { display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between' } },
        e('div', null,
          e(Label, { color: 'var(--written)' }, 'Huomenta · Tiistai'),
          e('h1', { className: 'ps-title-1', style: { marginTop: 8 } }, 'Päivän sessio')),
        e('div', { className: 'ps-glass', style: { padding: '10px 15px', display: 'flex', alignItems: 'center', gap: 8, borderRadius: 999 } },
          e('span', { style: { color: 'var(--spoken)' } }, I('flame', { size: 18, fill: 'var(--flag-bg)' })),
          e('span', { className: 'ps-num', style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 16 } }, '12'))),
      // mastered strip
      e('div', { className: 'ps-glass', style: { padding: 16, marginTop: 16 } },
        e('div', { style: { display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginBottom: 9 } },
          e('span', { className: 'ps-caption' }, 'Phrases mastered'),
          e('span', { className: 'ps-num', style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 18 } }, mastered)),
        e(Bar, { value: (mastered / 1200) * 100, color: 'var(--written)' })),
      // session progress
      e('div', { style: { marginTop: 20, marginBottom: 12, display: 'flex', alignItems: 'center', gap: 12 } },
        e(Steps, { total: SESSION.length, current: i }),
        e('span', { className: 'ps-label', style: { color: 'var(--ink-2)', flexShrink: 0 } }, `${i + 1}/${SESSION.length}`)),
      e('div', { style: { flex: 1, display: 'flex', flexDirection: 'column' } },
        e(RegisterCard, { key: i, glass: true, onPlay: play, playing, gloss: p.gloss, kirja: p.kirja, puhe: p.puhe, badge: 'Arki · daily' }),
        e('div', { className: 'ps-caption', style: { textAlign: 'center', marginTop: 14, display: 'flex', alignItems: 'center', gap: 6, justifyContent: 'center' } },
          I('speaker', { size: 15 }), 'Tap a register to hear it'),
        e('div', { style: { flex: 1, minHeight: 16 } }),
        e('div', { style: { display: 'flex', gap: 10 } },
          e(Btn, { variant: 'light', style: { flex: 1 }, onClick: () => advance(false) }, 'Vielä harjoittelen'),
          e(Btn, { variant: 'primary', icon: 'check', style: { flex: 1.2 }, onClick: () => advance(true) }, 'Osaan'))));
  }

  /* =======================================================================
     LANGUAGE ISLAND — shadowing
     ===================================================================== */
  function Island({ go }) {
    const ISLAND = PHRASES[1];
    const [st, setSt] = React.useState('idle');
    const [sec, setSec] = React.useState(0);
    const timer = React.useRef(null);

    const playNative = () => { setSt('playing'); clearTimeout(timer.current); timer.current = setTimeout(() => setSt('idle'), 1400); };
    const toggleRecord = () => {
      if (st === 'recording') { clearInterval(timer.current); setSt('review'); return; }
      setSt('recording'); setSec(0);
      timer.current = setInterval(() => setSec((s) => +(s + 0.1).toFixed(1)), 100);
    };
    React.useEffect(() => () => { clearTimeout(timer.current); clearInterval(timer.current); }, []);

    const Wave = ({ active, color }) => e('div', { style: { display: 'flex', alignItems: 'center', gap: 3, height: 40 } },
      Array.from({ length: 22 }).map((_, i) => {
        const base = 6 + Math.abs(Math.sin(i * 0.9)) * 28;
        return e('span', { key: i, style: { width: 3, borderRadius: 2, height: active ? base : 6 + (i % 3) * 4,
          background: color, opacity: active ? 1 : .4, transition: 'height .25s ease', transitionDelay: (i * 18) + 'ms' } });
      }));

    return e('div', { style: { position: 'absolute', inset: 0, background: 'var(--bg-grad)' } },
      // hero band with orbs
      e('div', { style: { position: 'absolute', top: 0, left: 0, right: 0, height: 230, overflow: 'hidden',
        background: 'linear-gradient(160deg, #6E4BC0, #4E2A86)' } },
        e(OrbCluster, { size: 230, style: { position: 'absolute', right: -34, top: -20, opacity: .95 } }),
        e('div', { style: { position: 'absolute', left: -40, bottom: -50, width: 160, height: 160, borderRadius: '50%',
          border: '2px solid rgba(255,255,255,.18)' } })),
      e(ScreenScroll, { bg: 'transparent', bottom: 110 },
        e('div', { style: { color: 'var(--on-dark)' } },
          e('div', { style: { display: 'flex', alignItems: 'center', justifyContent: 'space-between' } },
            e(IconBtn, { icon: 'arrowL', tone: 'solid', size: 44, onClick: () => go('daily') }),
            e('span', { className: 'ps-chip', style: { background: 'rgba(15,14,32,.36)', color: '#fff',
              border: '1px solid rgba(255,255,255,.28)', backdropFilter: 'blur(6px)' } },
              I('island', { size: 15 }), 'Saari 3 / 8')),
          e('div', { style: { marginTop: 22 } },
            e(Label, { color: 'rgba(255,255,255,.75)' }, 'Varjostus · Shadowing'),
            e('h1', { className: 'ps-title-1', style: { color: 'var(--on-dark)', marginTop: 10 } }, 'Toista ääneen'))),
        e('div', { style: { height: 26 } }),
        // shadowing card
        e('div', { className: 'ps-card', style: { padding: 20, borderRadius: 'var(--r-2xl)', boxShadow: 'var(--sh-3)' } },
          e('div', { style: { display: 'flex', alignItems: 'center', justifyContent: 'space-between',
            paddingBottom: 14, marginBottom: 16, borderBottom: '1px solid var(--glass-edge)' } },
            e('div', { style: { display: 'flex', alignItems: 'center', gap: 8 } },
              e('span', { className: 'ps-caption' }, 'You are shadowing'),
              e('span', { className: 'ps-label', style: { color: 'var(--written)', background: 'var(--written-bg)', padding: '5px 10px', borderRadius: 7 } }, 'Kirjakieli')),
            e('span', { className: 'ps-caption', style: { fontStyle: 'italic' } }, ISLAND.gloss)),
          e('div', null, e(RegDot, { reg: 'kirja' }),
            e('div', { style: { marginTop: 9 } },
              e(Sentence, { tokens: ISLAND.kirja, font: 'var(--font-display)', weight: 600, size: 26, color: 'var(--ink)' }))),
          e('div', { style: { marginTop: 14, padding: '12px 14px', background: 'var(--spoken-bg)', border: '1px solid var(--spoken-line)', borderRadius: 'var(--r-md)', opacity: .92 } },
            e(RegDot, { reg: 'puhe' }),
            e('div', { style: { marginTop: 8 } },
              e(Sentence, { tokens: ISLAND.puhe, font: 'var(--font-body)', weight: 600, size: 18, color: 'var(--ink-2)' }))),
          e('div', { style: { marginTop: 18, display: 'flex', alignItems: 'center', gap: 14 } },
            e(SpeakerBtn, { reg: 'kirja', playing: st === 'playing', onClick: playNative, size: 48 }),
            e(Wave, { active: st === 'playing', color: 'var(--written)' }),
            e('span', { className: 'ps-caption ps-num', style: { marginLeft: 'auto' } }, '0:03'))),
        e('div', { style: { flex: 1, minHeight: 18 } }),
        // record control
        e('div', { style: { display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 14 } },
          st === 'review' ? RecordReview() : RecordIdle())));

    function RecordIdle() {
      return e(React.Fragment, null,
        e('button', { onClick: toggleRecord, className: 'ps-press', 'aria-label': 'Record', style: {
          width: 80, height: 80, borderRadius: '50%', border: 'none', cursor: 'pointer',
          background: st === 'recording' ? 'var(--spoken)' : 'var(--ink)', color: '#fff',
          boxShadow: st === 'recording' ? '0 0 0 8px var(--spoken-bg), var(--sh-2)' : 'var(--sh-2)',
          display: 'flex', alignItems: 'center', justifyContent: 'center' } },
          st === 'recording'
            ? e('span', { style: { width: 24, height: 24, borderRadius: 7, background: 'currentColor' } })
            : I('mic', { size: 32, sw: 1.9 })),
        e('span', { className: 'ps-caption ps-num', style: { color: st === 'recording' ? 'var(--spoken)' : 'var(--ink-2)', fontWeight: 600 } },
          st === 'recording' ? `● Nauhoitetaan ${sec.toFixed(1)}s, tap to stop` : 'Tap to repeat the written form'));
    }

    function RecordReview() {
      return e('div', { style: { width: '100%' } },
        e('div', { className: 'ps-glass', style: { padding: 16, display: 'flex', alignItems: 'center', gap: 14,
          background: 'var(--written-bg)', border: '1px solid var(--written)' } },
          e('span', { style: { color: 'var(--written)' } }, I('check', { size: 26 })),
          e('div', { style: { flex: 1 } },
            e('div', { style: { fontWeight: 700, fontSize: 15, color: 'var(--written)' } }, 'Hyvä ääntämys'),
            e('div', { className: 'ps-caption', style: { marginTop: 2 } }, 'Close match to the native clip')),
          e(SpeakerBtn, { reg: 'puhe', onClick: () => {}, size: 42 })),
        e('div', { style: { display: 'flex', gap: 10, marginTop: 14 } },
          e(Btn, { variant: 'light', icon: 'mic', style: { flex: 1 }, onClick: () => setSt('idle') }, 'Uudelleen'),
          e(Btn, { variant: 'primary', iconRight: 'arrow', style: { flex: 1.2 }, onClick: () => setSt('idle') }, 'Seuraava')));
    }
  }

  /* =======================================================================
     PROGRESS DASHBOARD — calendar row + pastel stats + register split
     ===================================================================== */
  function Progress({ go }) {
    const days = [['Mon', '11'], ['Tue', '11'], ['Wed', '12'], ['Thu', '13'], ['Fri', '14'], ['Sat', '15'], ['Sun', '16']];
    const [day, setDay] = React.useState(4);
    const week = [40, 65, 30, 80, 55, 90, 70];

    return e(ScreenScroll, { bottom: 110 },
      e('div', { style: { display: 'flex', alignItems: 'center', justifyContent: 'space-between' } },
        e('div', { style: { display: 'flex', alignItems: 'center', gap: 8 } },
          e('h1', { className: 'ps-title-1' }, 'Kesäkuu 2026'),
          e('span', { style: { color: 'var(--ink-2)' } }, I('chevD', { size: 20 }))),
        e(IconBtn, { icon: 'plus', tone: 'solid', size: 44 })),
      // calendar day row
      e('div', { className: 'ps-glass', style: { marginTop: 16, padding: 12, display: 'flex', justifyContent: 'space-between', gap: 4 } },
        days.map(([d, n], i) => {
          const on = i === day;
          return e('button', { key: i, onClick: () => setDay(i), className: 'ps-press', style: {
            flex: 1, padding: '10px 0', borderRadius: 16, border: 'none', cursor: 'pointer',
            display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 7,
            background: on ? 'var(--ink)' : 'transparent', color: on ? 'var(--on-dark)' : 'var(--ink-2)',
            transition: 'background .15s, color .15s' } },
            e('span', { className: 'ps-label', style: { fontSize: 9.5, opacity: on ? .75 : .6 } }, d),
            e('span', { style: { fontFamily: 'var(--font-display)', fontWeight: 600, fontSize: 16 } }, n));
        })),

      // hero — mastered count (orb-backed)
      e('div', { style: { marginTop: 16, padding: 20, borderRadius: 'var(--r-xl)', background: 'var(--lav)',
        border: '1px solid rgba(255,255,255,.5)', display: 'flex', alignItems: 'center', gap: 16, position: 'relative', overflow: 'hidden' } },
        e(OrbCluster, { size: 116, style: { position: 'absolute', right: -46, top: -34, opacity: .35 } }),
        e(Ring, { value: 847, max: 1200, size: 100, stroke: 9, color: 'var(--written)', track: 'rgba(255,255,255,.55)' },
          e('span', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 25, lineHeight: 1, letterSpacing: '-0.02em' } }, '847'),
          e('span', { className: 'ps-label', style: { color: 'var(--ink-3)', marginTop: 3, fontSize: 9.5 } }, 'of 1200')),
        e('div', { style: { position: 'relative', flex: 1, minWidth: 0 } },
          e(Label, { color: 'var(--lav-ink)' }, 'Phrases mastered'),
          e('div', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 18, marginTop: 8, lineHeight: 1.15, letterSpacing: '-0.01em', textWrap: 'balance', overflowWrap: 'anywhere' } },
            'Conversational foundations'),
          e('div', { className: 'ps-caption', style: { marginTop: 8 } }, '+34 this week'))),

      // register split
      e('div', { className: 'ps-glass', style: { marginTop: 14, padding: 18 } },
        e(Label, { color: 'var(--ink-3)' }, 'Register balance'),
        e('div', { style: { marginTop: 16, display: 'grid', gap: 16 } },
          [['Kirjakieli · understood', 78, 'var(--written)'], ['Puhekieli · spoken', 52, 'var(--spoken)']].map(([t, v, c]) =>
            e('div', { key: t },
              e('div', { style: { display: 'flex', justifyContent: 'space-between', marginBottom: 8 } },
                e('span', { className: 'ps-label', style: { color: c } }, t),
                e('span', { className: 'ps-num', style: { fontWeight: 700, fontSize: 14 } }, v + '%')),
              e(Bar, { value: v, color: c, h: 10 })))),
        e('div', { className: 'ps-caption', style: { marginTop: 14, lineHeight: 1.45 } },
          'You read the books well. Time on Kielisaari to close the gap with the street.')),

      // pastel stat tiles
      e('div', { style: { display: 'flex', gap: 12, marginTop: 14 } },
        [['12', 'day streak', 'flame', 'var(--blush)', 'var(--blush-ink)'],
         ['3', 'islands', 'island', 'var(--mint)', 'var(--mint-ink)'],
         ['34', 'this week', 'sparkle', 'var(--lav)', 'var(--lav-ink)']].map(([n, l, ic, bg, ink]) =>
          e('div', { key: l, style: { flex: 1, padding: '15px 12px', textAlign: 'center', borderRadius: 'var(--r-md)',
            background: bg, border: '1px solid rgba(255,255,255,.5)' } },
            e('span', { style: { color: ink } }, I(ic, { size: 20 })),
            e('div', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 24, marginTop: 6, lineHeight: 1, letterSpacing: '-0.03em' } }, n),
            e('div', { className: 'ps-caption', style: { marginTop: 3, fontSize: 11.5 } }, l))),
      ),

      // weekly activity
      e('div', { className: 'ps-glass', style: { marginTop: 14, padding: 18 } },
        e('div', { style: { display: 'flex', justifyContent: 'space-between', alignItems: 'baseline' } },
          e(Label, { color: 'var(--ink-3)' }, 'This week'),
          e('span', { className: 'ps-caption' }, 'min / day')),
        e('div', { style: { display: 'flex', alignItems: 'flex-end', justifyContent: 'space-between', gap: 8, height: 86, marginTop: 14 } },
          week.map((v, i) => e('div', { key: i, style: { flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 7 } },
            e('div', { style: { width: '100%', maxWidth: 22, height: `${v}%`, borderRadius: 7,
              background: i === day ? 'var(--ink)' : 'rgba(107,70,193,.3)' } }),
            e('span', { className: 'ps-label', style: { color: 'var(--ink-3)', fontSize: 10 } }, days[i][0][0]))))),

      // recently mastered
      e('div', { style: { marginTop: 16 } },
        e(Label, { color: 'var(--ink-3)', style: { marginLeft: 2 } }, 'Recently mastered'),
        e('div', { style: { marginTop: 10, display: 'grid', gap: 10 } },
          PHRASES.slice(0, 2).map((p, i) =>
            e('div', { key: i, className: 'ps-glass', style: { padding: '13px 15px', display: 'flex', alignItems: 'center', gap: 12 } },
              e('span', { style: { color: 'var(--written)', flexShrink: 0 } }, I('check', { size: 18 })),
              e('div', { style: { flex: 1, minWidth: 0 } },
                e('div', { style: { fontFamily: 'var(--font-display)', fontWeight: 600, fontSize: 15, lineHeight: 1.15 } }, p.kirja.map((t) => t.t).join(' ')),
                e('div', { style: { fontFamily: 'var(--font-body)', fontWeight: 600, fontSize: 13.5, color: 'var(--spoken)', marginTop: 3 } }, p.puhe.map((t) => t.t).join(' '))),
              e('span', { className: 'ps-caption', style: { fontStyle: 'italic', flexShrink: 0, maxWidth: 92, textAlign: 'right' } }, p.gloss))))));
  }

  window.PS.screens = Object.assign(window.PS.screens || {}, { Daily, Island, Progress });
})();
