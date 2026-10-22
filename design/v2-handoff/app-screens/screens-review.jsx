/* PuhuScribe v2 — Daily Review flow (9-11). window.SCREENS.* */
(function () {
  const e = React.createElement;
  const PS = window.PS, A = window.APP;
  const { I, Bar, OrbCluster, Orb } = PS;
  const { Screen, ExBar, CenterLabel, Counter, TabBar, HubHeader, CTA, IconTile, Field } = A;
  const S = (window.SCREENS = window.SCREENS || {});
  const BODY_BOTTOM = 96;

  /* ---- 9 · REVIEW HUB ---- */
  S.ReviewHub = () => e('div', { style: { position: 'absolute', inset: 0 } },
    e(Screen, { bottom: BODY_BOTTOM, style: { paddingTop: 12 } },
      e(HubHeader, { eyebrowFi: 'DAILY REVIEW', title: 'Päivän kertaus',
        sub: "Type each one from memory. That's what makes it stick." }),
      e('div', { style: { display: 'flex', justifyContent: 'center', margin: '16px 0 4px' } }, e(OrbCluster, { size: 110 })),
      e(ReviewCard, { icon: 'review', tone: 'var(--written)', toneBg: 'var(--written-bg)',
        title: 'Sanasto', en: 'Vocabulary', count: '60 / 1000 sanaa', countEn: 'words', pct: 6, due: 7 }),
      e('div', { style: { height: 16 } }),
      e(ReviewCard, { icon: 'sprout', tone: 'var(--spoken)', toneBg: 'var(--spoken-bg)',
        title: 'Omat lauseet', en: 'Your sentences', count: '12 / 1000 lausetta', countEn: 'sentences', pct: 1.5, due: 5 })),
    e(TabBar, { active: 'home' }));

  const ReviewCard = ({ icon, tone, toneBg, title, en, count, countEn, pct, due }) =>
    e('div', { className: 'ps-card', style: { padding: 18, borderRadius: 'var(--r-xl)' } },
      e('div', { style: { display: 'flex', alignItems: 'flex-start', gap: 14 } },
        e(IconTile, { icon, color: tone, bg: toneBg }),
        e('div', { style: { flex: 1, minWidth: 0 } },
          e('div', { style: { display: 'flex', alignItems: 'baseline', gap: 8, flexWrap: 'wrap' } },
            e('span', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 17.2, color: 'var(--ink)' } }, title),
            e('span', { style: { fontFamily: 'var(--font-body)', fontSize: 13, color: 'var(--ink-3)' } }, en)),
          e('div', { style: { fontFamily: 'var(--font-body)', fontWeight: 500, fontSize: 14.5, color: 'var(--ink-2)', marginTop: 4 } }, count,
            e('span', { style: { fontSize: 12.5, color: 'var(--ink-3)', display: 'block' } }, countEn))),
        e('span', { style: { flexShrink: 0, background: toneBg, borderRadius: 14, padding: '9px 12px', textAlign: 'center' } },
          e('span', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 15.8, color: tone, display: 'block' } }, due),
          e('span', { className: 'ps-label', style: { color: tone, fontSize: 9.5 } }, 'vuorossa'),
          e('span', { style: { display: 'block', fontFamily: 'var(--font-body)', fontSize: 10.5, color: 'var(--ink-3)' } }, 'due'))),
      e('div', { style: { marginTop: 16, marginBottom: 16 } }, e(Bar, { value: pct, color: tone, track: 'var(--glass-deep)', h: 8 })),
      e(CTA, { fi: 'Kertaa', en: 'Review', iconRight: 'arrow', variant: 'ink', style: { minHeight: 58 } }));

  /* ---- 10 · VOCAB RECALL (typing prompt) ---- */
  S.Recall = () => e(Screen, { bottom: 26, style: { paddingTop: 8 } },
      e(ExBar, { nav: 'back',
        center: e(CenterLabel, { fi: 'KERTAUS · SANASTO', en: 'Review · Vocabulary' }),
        right: e(Counter, { a: 1, b: 7 }) },
        e(Bar, { value: 14, color: 'var(--written)', track: 'var(--glass-deep)', h: 7 })),
      e('div', { style: { textAlign: 'center', marginTop: 26 } },
        e('span', { className: 'ps-label', style: { color: 'var(--ink-3)' } }, 'KIRJOITA SUOMEKSI',
          e('span', { style: { fontFamily: 'var(--font-body)', fontStyle: 'italic', fontWeight: 500, fontSize: 10.5, color: 'var(--ink-3)', display: 'block', marginTop: 1, letterSpacing: 0, textTransform: 'none' } }, 'Type it in Finnish')),
        e('div', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 30.2, letterSpacing: '-0.035em', color: 'var(--ink)', marginTop: 24 } }, '"to be"'),
        e('div', { style: { display: 'inline-flex', alignItems: 'center', gap: 7, marginTop: 12, padding: '7px 14px', borderRadius: 999, background: 'var(--written-bg)' } },
          e('span', { style: { width: 7, height: 7, borderRadius: '50%', background: 'var(--written)' } }),
          e('span', { className: 'ps-label', style: { color: 'var(--written)' } }, 'KIRJAKIELI'))),
      e('div', { style: { marginTop: 30 } }, e(Field, { placeholder: 'Kirjoita tähän…', focus: true })),
      e('div', { style: { flex: 1, minHeight: 16 } }),
      e(CTA, { fi: 'Tarkista', en: 'Check', variant: 'ink' }));

  /* ---- 11 · RECALL GRADED (correct state) ---- */
  S.RecallGraded = () => e(Screen, { bottom: 26, bg: 'var(--spoken-bg)', style: { paddingTop: 8 } },
      e(ExBar, { nav: 'back',
        center: e(CenterLabel, { fi: 'KERTAUS · SANASTO', en: 'Review · Vocabulary', color: 'var(--spoken)' }),
        right: e(Counter, { a: 1, b: 7 }) },
        e(Bar, { value: 28, color: 'var(--spoken)', track: 'rgba(31,124,142,.18)', h: 7 })),
      e('div', { style: { textAlign: 'center', marginTop: 26 } },
        e('div', { style: { display: 'flex', justifyContent: 'center', marginBottom: 14 } },
          e('span', { style: { width: 64, height: 64, borderRadius: '50%', background: 'var(--spoken)', color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center' } }, I('check', { size: 34, sw: 2.6 }))),
        e('span', { className: 'ps-label', style: { color: 'var(--spoken)' } }, 'OIKEIN!',
          e('span', { style: { fontFamily: 'var(--font-body)', fontStyle: 'italic', fontWeight: 500, fontSize: 10.5, color: 'var(--ink-3)', display: 'block', marginTop: 1, letterSpacing: 0, textTransform: 'none' } }, 'Correct!'))),
      e('div', { className: 'ps-card', style: { marginTop: 22, padding: '24px', borderRadius: 'var(--r-xl)', textAlign: 'center', border: '1.5px solid var(--spoken)' } },
        e('div', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 31.7, letterSpacing: '-0.04em', color: 'var(--ink)' } }, 'olla'),
        e('div', { style: { fontFamily: 'var(--font-body)', fontWeight: 500, fontSize: 15.8, color: 'var(--ink-2)', marginTop: 6 } }, '"to be"'),
        e('hr', { className: 'ps-rule', style: { margin: '18px 0' } }),
        e('div', { style: { fontFamily: 'var(--font-body)', fontWeight: 500, fontSize: 14, color: 'var(--ink-2)', lineHeight: 1.5 } },
          'Seuraava kertaus ',
          e('strong', { style: { color: 'var(--spoken)', fontWeight: 700 } }, '4 päivän päästä'),
          e('span', { style: { color: 'var(--ink-3)', display: 'block', marginTop: 2 } }, 'Next review in 4 days'))),
      e('div', { style: { flex: 1, minHeight: 16 } }),
      e(CTA, { fi: 'Jatka', en: 'Continue', iconRight: 'arrow', variant: 'spoken' }));
})();
