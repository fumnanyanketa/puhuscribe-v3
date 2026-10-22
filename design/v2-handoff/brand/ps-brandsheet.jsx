/* PuhuScribe v2 — Brand sheet panels ("Lake Glass"). window.PS.brand.* */
(function () {
  const e = React.createElement;
  const { Label, Btn, RegisterCard, Bar, Orb, OrbCluster, IconBtn, Tabs, RegDot } = window.PS;

  const Panel = ({ title, kicker, children, w = 360, style }) =>
    e('div', { className: 'ps-root ps-theme-snow', style: { width: w, background: 'var(--bg-grad)',
      padding: 26, borderRadius: 'var(--r-xl)', boxShadow: 'var(--sh-2)', ...style } },
      e('div', { style: { marginBottom: 20 } },
        kicker && e('div', { style: { marginBottom: 9 } }, e(Label, { color: 'var(--written)' }, kicker)),
        e('div', { className: 'ps-title-2' }, title)),
      children);

  /* ---------- Colors ---------- */
  const Swatch = ({ name, hex, role, ring }) =>
    e('div', { style: { display: 'flex', alignItems: 'center', gap: 14 } },
      e('div', { style: { width: 50, height: 50, borderRadius: 16, background: hex, flexShrink: 0,
        border: '1px solid rgba(255,255,255,.6)', boxShadow: ring ? `0 0 0 3px ${ring}` : 'var(--sh-1)' } }),
      e('div', { style: { flex: 1, minWidth: 0 } },
        e('div', { style: { display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', gap: 8 } },
          e('div', { style: { fontFamily: 'var(--font-display)', fontWeight: 600, fontSize: 16 } }, name),
          e('div', { className: 'ps-label ps-num', style: { color: 'var(--ink-3)' } }, hex)),
        e('div', { className: 'ps-caption', style: { marginTop: 4 } }, role)));

  const Colors = () => e(Panel, { title: 'Colour tokens', kicker: 'Palette · Lake Glass' },
    e('div', { className: 'ps-glass', style: { padding: 18, display: 'grid', gap: 16 } },
      e(Swatch, { name: 'Snow white', hex: '#FFFFFF', role: 'App background · primary' }),
      e(Swatch, { name: 'Lilac mist', hex: '#B7AFD6', role: 'Lake Glass variant background' }),
      e(Swatch, { name: 'Ink', hex: '#1B1A20', role: 'Text · pills · active states' }),
      e(Swatch, { name: 'Violet', hex: '#6B46C1', role: 'Kirjakieli — written register' }),
      e(Swatch, { name: 'Teal', hex: '#1F7C8E', role: 'Puhekieli — spoken register' }),
      e(Swatch, { name: 'Azure flag', hex: '#2F5AD6', role: 'The words that change', ring: 'var(--flag-bg)' }),
      e(Swatch, { name: 'Steel · Mint · Lav', hex: 'linear-gradient(90deg,#C4D2E6 0 34%,#CCDFD3 34% 67%,#D6D0E8 67%)', role: 'Pastel color-block cards' })),
    e('div', { className: 'ps-caption', style: { marginTop: 16, lineHeight: 1.5 } },
      'Snow white is the ground. Azure is reserved for exactly one thing — the tokens that morph between written and spoken Finnish.'));

  /* ---------- Register coding ---------- */
  const RegisterKey = () => e(Panel, { title: 'Register coding', kicker: 'The core idea' },
    e('div', { className: 'ps-glass', style: { padding: 18, display: 'grid', gap: 14, marginBottom: 16 } },
      [['kirja', 'Kirjakieli — written', 'Violet dot · Poppins · the book form'],
       ['puhe', 'Puhekieli — spoken', 'Teal band · Switzer · how people really talk']].map(([r, t, d]) =>
        e('div', { key: r, style: { display: 'flex', gap: 12, alignItems: 'flex-start' } },
          e('span', { style: { width: 11, height: 11, borderRadius: '50%', marginTop: 3, flexShrink: 0,
            background: r === 'kirja' ? 'var(--written)' : 'var(--spoken)' } }),
          e('div', null, e('div', { style: { fontWeight: 700, fontSize: 14.5 } }, t),
            e('div', { className: 'ps-caption', style: { marginTop: 2 } }, d)))),
      e('div', { style: { display: 'flex', gap: 12, alignItems: 'flex-start' } },
        e('span', { className: 'ps-hot', style: { fontWeight: 700, fontSize: 14.5, marginTop: 0 } }, 'oon'),
        e('div', null, e('div', { style: { fontWeight: 700, fontSize: 14.5 } }, 'Azure flag'),
          e('div', { className: 'ps-caption', style: { marginTop: 2 } }, 'The exact tokens that change between registers')))),
    e(RegisterCard, { glass: true, compact: true, gloss: 'I am at home',
      kirja: [{ t: 'Minä', hot: true }, { t: 'olen', hot: true }, { t: 'kotona' }],
      puhe: [{ t: 'Mä', hot: true }, { t: 'oon', hot: true }, { t: 'kotona' }] }));

  /* ---------- Type ---------- */
  const TypeRow = ({ spec, sample, cls }) =>
    e('div', { style: { paddingBottom: 14, borderBottom: '1px solid var(--glass-edge)' } },
      e('div', { className: 'ps-label', style: { color: 'var(--ink-3)', marginBottom: 7 } }, spec),
      e('div', { className: cls }, sample));

  const Type = () => e(Panel, { title: 'Type scale', kicker: 'General Sans + Switzer', w: 380 },
    e('div', { className: 'ps-glass', style: { padding: 20, display: 'grid', gap: 14 } },
      e('div', { style: { display: 'flex', gap: 22, marginBottom: 2 } },
        e('div', null, e('div', { style: { fontFamily: 'var(--font-display)', fontSize: 44, fontWeight: 700, lineHeight: 1, letterSpacing: '-0.03em' } }, 'Aa'),
          e('div', { className: 'ps-caption', style: { marginTop: 6 } }, 'General Sans · display')),
        e('div', null, e('div', { style: { fontFamily: 'var(--font-body)', fontSize: 44, fontWeight: 600, lineHeight: 1 } }, 'Aa'),
          e('div', { className: 'ps-caption', style: { marginTop: 6 } }, 'Switzer · body & UI'))),
      e('hr', { className: 'ps-rule' }),
      e(TypeRow, { spec: 'Display · 44 / 700', cls: 'ps-display', sample: 'Puhu kuin paikallinen' }),
      e(TypeRow, { spec: 'Title 1 · 33 / 700', cls: 'ps-title-1', sample: 'Päivän sessio' }),
      e(TypeRow, { spec: 'Title 2 · 24 / 600', cls: 'ps-title-2', sample: 'Kielisaari' }),
      e(TypeRow, { spec: 'Body · 15 / 500', cls: 'ps-body', sample: 'Jokainen kortti näyttää sekä kirja- että puhekielen.' }),
      e(TypeRow, { spec: 'Label · 11 / 600 · +0.09em', cls: 'ps-label', sample: 'KIRJA · PUHE · ARKI' })));

  /* ---------- Buttons ---------- */
  const ButtonsPanel = () => e(Panel, { title: 'Buttons & controls', kicker: 'States', w: 360 },
    e('div', { className: 'ps-glass', style: { padding: 20, display: 'grid', gap: 12 } },
      e(Btn, { variant: 'primary', block: true, iconRight: 'arrow' }, 'Aloita — Start'),
      e('div', { style: { display: 'flex', gap: 10 } },
        e(Btn, { variant: 'light', style: { flex: 1 } }, 'Toista'),
        e(Btn, { variant: 'accent', icon: 'check', style: { flex: 1 } }, 'Osaan')),
      e(Btn, { variant: 'rose', block: true, icon: 'mic' }, 'Nauhoita — Record'),
      e('div', { style: { display: 'flex', gap: 10, alignItems: 'center' } },
        e(IconBtn, { icon: 'arrowL', tone: 'glass' }),
        e(IconBtn, { icon: 'more', tone: 'solid' }),
        e(IconBtn, { icon: 'mic', tone: 'ink' }),
        e(Btn, { variant: 'primary', sm: true, disabled: true, style: { flex: 1 } }, 'Disabled')),
      e(Tabs, { items: ['Kirja', 'Puhe', 'Audio'], value: 'Puhe', onChange: () => {} })),
    e('div', { className: 'ps-caption', style: { marginTop: 14, lineHeight: 1.5 } },
      'Pills everywhere · solid black for primary & active · frosted glass for secondary. Quiet 150 ms motion, no bounce.'));

  /* ---------- Cards ---------- */
  const CardsPanel = () => e(Panel, { title: 'Card patterns', kicker: 'Surfaces', w: 380 },
    e('div', { style: { display: 'grid', gap: 14 } },
      e(RegisterCard, { glass: true, compact: true, gloss: 'Do you want to come along?', onPlay: () => {},
        kirja: [{ t: 'Haluatko', hot: true }, { t: 'tulla' }, { t: 'mukaan?' }],
        puhe: [{ t: 'Haluuks', hot: true }, { t: 'sä', hot: true }, { t: 'tulla' }, { t: 'mukaan?' }] }),
      e('div', { style: { display: 'flex', gap: 12 } },
        // pastel stat card
        e('div', { style: { flex: 1, padding: 18, borderRadius: 'var(--r-lg)', background: 'var(--blush)',
          border: '1px solid rgba(255,255,255,.5)' } },
          e(Label, { color: 'var(--blush-ink)' }, 'Mastered'),
          e('div', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 38, marginTop: 6, lineHeight: 1, letterSpacing: '-0.03em' } }, '847'),
          e(Bar, { value: 70, color: 'var(--blush-ink)', track: 'rgba(255,255,255,.5)', style: { marginTop: 12 } })),
        // orb tile
        e('div', { style: { width: 120, borderRadius: 'var(--r-lg)', background: 'var(--lav)',
          border: '1px solid rgba(255,255,255,.5)', display: 'flex', alignItems: 'center', justifyContent: 'center' } },
          e(OrbCluster, { size: 96 }))),
      e('div', { className: 'ps-caption', style: { lineHeight: 1.5 } },
        'Radii 14–38 px · glass + pastel color-blocks · glossy orbs as hero imagery. The Marimekko energy lives in the colour blocks; the glass keeps it calm.')));

  /* ---------- Orbs / imagery ---------- */
  const MotifsPanel = () => e(Panel, { title: 'Speech-bubble imagery', kicker: 'Rebuilt in SVG', w: 360 },
    e('div', { className: 'ps-glass', style: { padding: 22, display: 'flex', justifyContent: 'center' } },
      e(OrbCluster, { size: 200 })),
    e('div', { style: { display: 'flex', gap: 12, marginTop: 14, justifyContent: 'center' } },
      [['var(--orb-magenta)', 'var(--orb-pink)'], ['var(--orb-violet)', 'var(--orb-magenta)'],
       ['var(--orb-deep)', 'var(--orb-violet)']].map(([f, t], i) =>
        e(Orb, { key: i, size: 64, from: f, to: t, dots: i === 1 }))),
    e('div', { className: 'ps-caption', style: { marginTop: 16, lineHeight: 1.5 } },
      'Glossy 3D speech bubbles — one motif for a language app, and a nod to the two registers in conversation. Built from layered SVG gradients so they stay crisp at any size.'));

  window.PS.brand = { Colors, RegisterKey, Type, ButtonsPanel, CardsPanel, MotifsPanel, Panel };
})();
