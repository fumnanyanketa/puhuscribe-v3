/* PuhuScribe v2 — Home hub (returning users). window.SCREENS.Home / HomeSprint */
(function () {
  const e = React.createElement;
  const PS = window.PS, A = window.APP;
  const { I, Bar, Ring, OrbCluster } = PS;
  const { Screen, TabBar, MiniMark, Eyebrow, Gloss, CTA, IconTile, HubHeader } = A;
  const S = (window.SCREENS = window.SCREENS || {});
  const BODY_BOTTOM = 96;

  /* Shared top row: wordmark + streak/day chip */
  const TopRow = ({ chipIcon = 'flame', chipText, chipLabel }) =>
    e('div', { style: { display: 'flex', alignItems: 'center', justifyContent: 'space-between' } },
      e(MiniMark, { size: 20 }),
      e('span', { style: { display: 'inline-flex', alignItems: 'center', gap: 7, padding: '8px 13px', borderRadius: 999, background: 'var(--written-bg)' } },
        e('span', { style: { color: 'var(--written)' } }, I(chipIcon, { size: 17, sw: 1.9 })),
        e('span', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 14.9, color: 'var(--written)' } }, chipText),
        chipLabel && e('span', { className: 'ps-label', style: { color: 'var(--written)', fontSize: 9.5 } }, chipLabel)));

  const Greeting = ({ fi, en }) =>
    e('div', { style: { marginTop: 16 } },
      e('h1', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 23, letterSpacing: '-0.03em', color: 'var(--ink)', margin: 0 } }, fi),
      e('div', { style: { fontFamily: 'var(--font-body)', fontStyle: 'italic', fontWeight: 500, fontSize: 13, color: 'var(--ink-3)', marginTop: 1 } }, en));

  /* =====================================================================
     STATE 1 · FIRST SPRINT NOT YET COMPLETE — lead with resume, minimal else
     ===================================================================== */
  S.HomeSprint = () => e('div', { style: { position: 'absolute', inset: 0 } },
    e(Screen, { bottom: BODY_BOTTOM, style: { paddingTop: 10 } },
      e(TopRow, { chipIcon: 'flame', chipText: '1', chipLabel: 'PÄIVÄ' }),
      e(Greeting, { fi: 'Tervetuloa takaisin!', en: 'Welcome back!' }),
      // resume hero
      e('div', { style: { marginTop: 16, borderRadius: 'var(--r-xl)', overflow: 'hidden',
        background: 'linear-gradient(155deg, var(--orb-violet), var(--orb-deep))',
        boxShadow: '0 22px 44px -20px rgba(56,53,131,.6)', color: '#fff', padding: 20, position: 'relative' } },
        e('div', { style: { position: 'absolute', bottom: -26, right: -22, opacity: .16, pointerEvents: 'none' } }, e(OrbCluster, { size: 104 })),
        e('span', { className: 'ps-label', style: { color: 'rgba(255,255,255,.85)' } }, 'ENSIMMÄINEN SPRINT',
          e('span', { style: { display: 'block', fontFamily: 'var(--font-body)', fontStyle: 'italic', fontWeight: 500, fontSize: 10.5, color: 'rgba(255,255,255,.7)', marginTop: 1, letterSpacing: 0, textTransform: 'none' } }, 'Your first sprint')),
        e('h2', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 19.5, lineHeight: 1.05, letterSpacing: '-0.02em', margin: '12px 0 0', position: 'relative' } }, 'Jatka siitä mihin jäit'),
        e('p', { style: { fontFamily: 'var(--font-body)', fontWeight: 500, fontSize: 14, color: 'rgba(255,255,255,.8)', margin: '5px 0 0' } }, 'Continue where you left off'),
        // progress
        e('div', { style: { marginTop: 18, display: 'flex', alignItems: 'baseline', justifyContent: 'space-between' } },
          e('span', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 14 } }, '90',
            e('span', { style: { color: 'rgba(255,255,255,.65)' } }, ' / 150 sanaa')),
          e('span', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 14 } }, '60%')),
        e('div', { style: { marginTop: 10 } }, e(Bar, { value: 60, color: '#fff', track: 'rgba(255,255,255,.22)', h: 9 }))),
      e('button', { className: 'ps-press', style: { marginTop: 14, width: '100%', border: 'none', cursor: 'pointer',
        background: 'var(--ink)', color: 'var(--on-dark)', boxShadow: '0 10px 24px -8px rgba(27,26,32,.45)', borderRadius: 999,
        padding: '13px 22px', minHeight: 56, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 12 } },
        I('sparkle', { size: 21, sw: 2 }),
        e('span', { style: { display: 'flex', flexDirection: 'column', alignItems: 'center', lineHeight: 1.05 } },
          e('span', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 15.5 } }, 'Jatka sprinttiä'),
          e('span', { style: { fontFamily: 'var(--font-body)', fontWeight: 500, fontSize: 13, color: 'rgba(255,255,255,.6)', marginTop: 1 } }, 'Continue sprint · 60 left'))),
      // goal note
      e('div', { className: 'ps-card', style: { marginTop: 14, padding: '13px 16px', borderRadius: 'var(--r-lg)', display: 'flex', alignItems: 'center', gap: 11 } },
        e('span', { style: { color: 'var(--written)', flexShrink: 0 } }, I('star', { size: 20, sw: 1.9 })),
        e('div', { style: { fontFamily: 'var(--font-body)', fontWeight: 600, fontSize: 13.5, color: 'var(--ink-2)', lineHeight: 1.35 } }, 'Tavoite: 150 yleisintä sanaa ',
          e('span', { style: { color: 'var(--ink-3)' } }, 'the 150 most common words')))),
    e(TabBar, { active: 'home' }));

  /* =====================================================================
     STATE 2 · SPRINT COMPLETE — the normal daily hub
     ===================================================================== */
  S.Home = () => e('div', { style: { position: 'absolute', inset: 0 } },
    e(Screen, { bottom: BODY_BOTTOM, style: { paddingTop: 10 } },
      e(TopRow, { chipIcon: 'flame', chipText: '12' }),
      e(Greeting, { fi: 'Hyvää huomenta', en: 'Good morning' }),
      // today's plan hero
      e('div', { className: 'ps-card', style: { marginTop: 20, padding: 20, borderRadius: 'var(--r-xl)' } },
        e(Eyebrow, { fi: 'PÄIVÄN SUUNNITELMA', en: "Today's plan", color: 'var(--written)', style: { marginBottom: 16 } }),
        e(PlanRow, { icon: 'sparkle', tone: 'var(--written)', toneBg: 'var(--written-bg)', fi: 'Uudet sanat', en: 'New words', n: 15, unit: 'sanaa' }),
        e('hr', { className: 'ps-rule', style: { margin: '14px 0' } }),
        e(PlanRow, { icon: 'review', tone: 'var(--spoken)', toneBg: 'var(--spoken-bg)', fi: 'Kertaus', en: 'Reviews due', n: 12, unit: 'vuorossa' }),
        e('div', { style: { marginTop: 18 } },
          e('button', { className: 'ps-press', style: { width: '100%', border: 'none', cursor: 'pointer',
            background: 'var(--ink)', color: 'var(--on-dark)', boxShadow: '0 10px 24px -8px rgba(27,26,32,.45)', borderRadius: 999,
            padding: '14px 22px', minHeight: 58, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10 } },
            e('span', { style: { display: 'flex', flexDirection: 'column', alignItems: 'center', lineHeight: 1.05 } },
              e('span', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 15.5 } }, 'Aloita päivä'),
              e('span', { style: { fontFamily: 'var(--font-body)', fontWeight: 500, fontSize: 12.5, color: 'rgba(255,255,255,.6)' } }, 'Start today · ~15 min')),
            I('arrow', { size: 20, sw: 2 })))),
      // progress snapshot
      e('button', { className: 'ps-card ps-press', style: { marginTop: 16, padding: 16, borderRadius: 'var(--r-xl)', display: 'flex', alignItems: 'center', gap: 16, width: '100%', cursor: 'pointer', textAlign: 'left', border: 'none' } },
        e(Ring, { value: 60, max: 100, size: 64, stroke: 8, color: 'var(--written)', track: 'var(--glass-deep)' },
          e('span', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 15.5, color: 'var(--ink)' } }, 'A1')),
        e('div', { style: { flex: 1, minWidth: 0 } },
          e('div', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 14.9, color: 'var(--ink)' } }, 'Taso A1 · 60%'),
          e('div', { style: { fontFamily: 'var(--font-body)', fontWeight: 500, fontSize: 13, color: 'var(--ink-2)', marginTop: 2 } }, '240 sanaa tasoon A2 ',
            e('span', { style: { color: 'var(--ink-3)' } }, 'to A2'))),
        e('span', { style: { flexShrink: 0, display: 'flex', alignItems: 'center', gap: 4, color: 'var(--ink-3)' } },
          e('span', { className: 'ps-label', style: { color: 'var(--ink-3)' } }, 'EDISTYMINEN'), I('arrow', { size: 18, sw: 2 }))),
      // quick actions
      e(Eyebrow, { fi: 'PIKAVALINNAT', en: 'Jump back in', color: 'var(--ink-3)', style: { marginTop: 24, marginBottom: 14 } }),
      e('div', { style: { display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 } },
        e(QuickCard, { icon: 'book', tone: 'var(--written)', toneBg: 'var(--written-bg)', fi: 'Sanasto', en: 'Vocabulary', badge: '15 uutta' }),
        e(QuickCard, { icon: 'review', tone: 'var(--spoken)', toneBg: 'var(--spoken-bg)', fi: 'Kertaus', en: 'Review', badge: '12 vuorossa' }),
        e(QuickCard, { icon: 'lines', tone: 'var(--flag)', toneBg: 'var(--flag-bg)', fi: 'Omat lauseet', en: 'Sentences', badge: '4 settiä' }),
        e(QuickCard, { icon: 'mic', tone: '#C2603F', toneBg: 'rgba(194,96,63,.12)', fi: 'Harjoittele', en: 'Practice', badge: '4 taitoa' }))),
    e(TabBar, { active: 'home' }));

  const PlanRow = ({ icon, tone, toneBg, fi, en, n, unit }) =>
    e('div', { style: { display: 'flex', alignItems: 'center', gap: 13 } },
      e(IconTile, { icon, color: tone, bg: toneBg, size: 44, r: 13 }),
      e('div', { style: { flex: 1, minWidth: 0 } },
        e('div', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 15.8, color: 'var(--ink)' } }, fi),
        e('div', { style: { fontFamily: 'var(--font-body)', fontStyle: 'italic', fontSize: 11.5, color: 'var(--ink-3)' } }, en)),
      e('span', { style: { textAlign: 'right' } },
        e('span', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 17.2, color: tone } }, n),
        e('span', { style: { fontFamily: 'var(--font-body)', fontWeight: 600, fontSize: 12.5, color: 'var(--ink-3)', display: 'block', marginTop: -2 } }, unit)));

  const QuickCard = ({ icon, tone, toneBg, fi, en, badge }) =>
    e('div', { className: 'ps-card ps-press', style: { padding: 16, borderRadius: 'var(--r-lg)', cursor: 'pointer' } },
      e(IconTile, { icon, color: tone, bg: toneBg, size: 42, r: 13 }),
      e('div', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 15.3, color: 'var(--ink)', marginTop: 12 } }, fi),
      e('div', { style: { fontFamily: 'var(--font-body)', fontStyle: 'italic', fontSize: 11, color: 'var(--ink-3)' } }, en),
      e('div', { style: { marginTop: 10, display: 'inline-flex', padding: '4px 10px', borderRadius: 999, background: toneBg } },
        e('span', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 11.5, color: tone } }, badge)));
})();
