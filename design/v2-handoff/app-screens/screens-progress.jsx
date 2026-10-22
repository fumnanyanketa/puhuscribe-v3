/* PuhuScribe v2 — Progress (21). window.SCREENS.* */
(function () {
  const e = React.createElement;
  const PS = window.PS, A = window.APP;
  const { I, Bar, Ring, OrbCluster } = PS;
  const { Screen, TabBar, HubHeader, Eyebrow, Gloss, SkillChip, IconTile } = A;
  const S = (window.SCREENS = window.SCREENS || {});
  const BODY_BOTTOM = 96;

  S.Progress = () => e('div', { style: { position: 'absolute', inset: 0 } },
    e(Screen, { bottom: BODY_BOTTOM, style: { paddingTop: 12 } },
      e('div', { style: { display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', gap: 12 } },
        e(HubHeader, { eyebrowFi: 'PROGRESS', title: 'Edistyminen', titleSize: 33 }),
        e('span', { style: { flexShrink: 0, display: 'inline-flex', alignItems: 'center', gap: 7, padding: '9px 14px', borderRadius: 999, background: 'var(--written-bg)', marginTop: 18 } },
          e('span', { style: { color: 'var(--written)' } }, I('flame', { size: 18, sw: 1.8 })),
          e('span', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 15.8, color: 'var(--written)' } }, '12'))),
      // current level ring
      e('div', { className: 'ps-card', style: { marginTop: 20, padding: 22, borderRadius: 'var(--r-xl)', display: 'flex', alignItems: 'center', gap: 20 } },
        e(Ring, { value: 60, max: 100, size: 108, stroke: 11, color: 'var(--written)', track: 'var(--glass-deep)' },
          e('div', { style: { textAlign: 'center' } },
            e('div', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 21.6, letterSpacing: '-0.03em', color: 'var(--ink)', lineHeight: 1 } }, 'A1'),
            e('div', { style: { fontFamily: 'var(--font-body)', fontWeight: 600, fontSize: 11.5, color: 'var(--ink-3)', marginTop: 2 } }, '60%'))),
        e('div', { style: { flex: 1, minWidth: 0 } },
          e('div', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 16.3, color: 'var(--ink)' } }, 'Kasvata sanavarastoa'),
          e(Gloss, null, 'Grow your word bank'),
          e('p', { style: { fontFamily: 'var(--font-body)', fontWeight: 500, fontSize: 13.5, lineHeight: 1.4, color: 'var(--ink-2)', margin: '8px 0 0' } }, '240 sanaa seuraavaan tasoon ',
            e('span', { style: { color: 'var(--ink-3)' } }, 'to A2')))),
      // 3 stat tiles
      e('div', { style: { marginTop: 16, display: 'grid', gridTemplateColumns: 'repeat(3,1fr)', gap: 12 } },
        e(StatTile, { n: '60', fi: 'sanaa', en: 'words', tone: 'var(--written)' }),
        e(StatTile, { n: '47', fi: 'lausetta', en: 'sentences', tone: 'var(--spoken)' }),
        e(StatTile, { n: '12', fi: 'päivää', en: 'day streak', tone: 'var(--flag)' })),
      // skills breakdown
      e(Eyebrow, { fi: 'TAIDOT', en: 'Skills', color: 'var(--ink-3)', style: { marginTop: 24, marginBottom: 14 } }),
      e('div', { className: 'ps-card', style: { padding: 18, borderRadius: 'var(--r-xl)', display: 'flex', flexDirection: 'column', gap: 16 } },
        [['reading', 'Lukeminen', 72], ['listening', 'Kuunteleminen', 64], ['speaking', 'Puhuminen', 40], ['writing', 'Kirjoittaminen', 28]].map(([skill, fi, pct]) => {
          const c = A.SKILL[skill];
          return e('div', { key: skill },
            e('div', { style: { display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 8 } },
              e('span', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 14, color: 'var(--ink)' } }, fi),
              e('span', { className: 'ps-num', style: { fontFamily: 'var(--font-body)', fontWeight: 600, fontSize: 13, color: c.c } }, pct + '%')),
            e(Bar, { value: pct, color: c.c, track: 'var(--glass-deep)', h: 8 }));
        })),
      // weekly activity
      e(Eyebrow, { fi: 'TÄMÄ VIIKKO', en: 'This week', color: 'var(--ink-3)', style: { marginTop: 24, marginBottom: 14 } }),
      e('div', { className: 'ps-card', style: { padding: 18, borderRadius: 'var(--r-xl)' } },
        e('div', { style: { display: 'flex', alignItems: 'flex-end', justifyContent: 'space-between', height: 90, gap: 8 } },
          [['ma', 60], ['ti', 85], ['ke', 40], ['to', 100], ['pe', 70], ['la', 30], ['su', 55]].map(([d, h], i) =>
            e('div', { key: d, style: { flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8 } },
              e('div', { style: { width: '100%', height: 70, display: 'flex', alignItems: 'flex-end' } },
                e('div', { style: { width: '100%', height: h + '%', borderRadius: 7, background: i === 3 ? 'var(--written)' : 'var(--written-bg)' } })),
              e('span', { style: { fontFamily: 'var(--font-body)', fontWeight: 600, fontSize: 11.5, color: 'var(--ink-3)' } }, d)))))),
    e(TabBar, { active: 'progress' }));

  const StatTile = ({ n, fi, en, tone }) => e('div', { className: 'ps-card', style: { padding: '16px 8px', borderRadius: 'var(--r-lg)', textAlign: 'center' } },
    e('div', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 21.8, letterSpacing: '-0.03em', color: tone } }, n),
    e('div', { style: { fontFamily: 'var(--font-body)', fontWeight: 600, fontSize: 12.5, color: 'var(--ink-2)', marginTop: 2 } }, fi),
    e('div', { style: { fontFamily: 'var(--font-body)', fontSize: 11, color: 'var(--ink-3)' } }, en));
})();
