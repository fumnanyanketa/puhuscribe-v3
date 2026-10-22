/* PuhuScribe v2 — app shell ("Lake Glass"). Exposes window.PS.shell.* */
(function () {
  const e = React.createElement;
  const { I, Orb } = window.PS;

  /* ---------- Wordmark ---------- */
  const PuhuMark = ({ size = 20, light }) =>
    e('div', { style: { display: 'flex', alignItems: 'center', gap: 9 } },
      e(Orb, { size: size * 1.15, from: 'var(--orb-magenta)', to: 'var(--orb-violet)', dots: true }),
      e('span', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: size,
        letterSpacing: '-0.03em', color: light ? 'var(--on-dark)' : 'var(--ink)' } },
        'Puhu', e('span', { style: { opacity: .55 } }, 'Scribe')));

  /* ---------- Scrollable screen body ---------- */
  const ScreenScroll = ({ children, pad = 22, bottom = 22, bg = 'var(--bg-grad)', style }) =>
    e('div', { className: 'ps-root ps-noscroll', style: {
      position: 'absolute', inset: 0, overflowY: 'auto', background: bg,
      paddingTop: 56, paddingLeft: pad, paddingRight: pad, paddingBottom: bottom,
      display: 'flex', flexDirection: 'column', ...style } }, children);

  /* ---------- Floating frosted pill nav ---------- */
  const NAV = [
    { id: 'daily', icon: 'cards' },
    { id: 'island', icon: 'island' },
    { id: 'progress', icon: 'chart' },
  ];
  const BottomNav = ({ active, onNav }) =>
    e('div', { style: { position: 'absolute', left: 0, right: 0, bottom: 0, zIndex: 40,
      paddingBottom: 26, display: 'flex', justifyContent: 'center', pointerEvents: 'none' } },
      e('div', { className: 'ps-glass', style: { display: 'flex', gap: 8, padding: 8, borderRadius: 999,
        background: 'var(--glass-2)', boxShadow: 'var(--sh-2)', pointerEvents: 'auto' } },
        NAV.map((t) => {
          const on = active === t.id;
          return e('button', { key: t.id, onClick: () => onNav(t.id), 'aria-label': t.id, className: 'ps-press', style: {
            width: 58, height: 58, borderRadius: '50%', border: 'none', cursor: 'pointer',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            background: on ? 'var(--ink)' : 'transparent', color: on ? 'var(--on-dark)' : 'var(--ink-2)',
            transition: 'background .15s, color .15s' } }, I(t.icon, { size: 24, sw: on ? 2 : 1.8 }));
        })));

  /* ---------- App shell ---------- */
  const APP_SCREENS = ['daily', 'island', 'progress'];
  function PuhuApp({ initialScreen = 'onboarding' }) {
    const [screen, setScreen] = React.useState(initialScreen);
    const go = (s) => setScreen(s);
    const S = window.PS.screens || {};
    const view = { onboarding: S.Onboarding, dayone: S.DayOne, daily: S.Daily, island: S.Island, progress: S.Progress }[screen];
    const showNav = APP_SCREENS.includes(screen);
    return e('div', { style: { position: 'absolute', inset: 0 } },
      view ? e(view, { go, screen }) : null,
      showNav && e(BottomNav, { active: screen, onNav: go }));
  }

  window.PS.shell = { PuhuMark, ScreenScroll, BottomNav, PuhuApp };
})();
