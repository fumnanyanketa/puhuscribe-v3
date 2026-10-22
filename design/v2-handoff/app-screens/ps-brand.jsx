/* PuhuScribe v2 — Brand marks. Replaces the speech-bubble logo.
   Loads AFTER ps-components (to override PS.Orb / PS.OrbCluster) and BEFORE
   ps-kit + screens (so they pick up the new versions when they destructure PS).
   window.APP.BrandMark / Disc / LogoCard ; window.APP.BRAND = active concept. */
(function () {
  const e = React.createElement;
  const PS = window.PS;
  const A = (window.APP = window.APP || {});

  // Active logo direction, applied across every screen. Swap to preview another.
  A.BRAND = A.BRAND || 'sprout';

  /* ---- one concept's silhouette, drawn into a 0..100 box ---- */
  function concept(name, ids) {
    const { gV, gT, gl, cp } = ids;
    const meridian = { fill: 'none', stroke: 'rgba(255,255,255,.55)', strokeWidth: 2.4, strokeLinecap: 'round' };
    switch (name) {
      case 'globe':
        return [
          e('clipPath', { id: cp, key: 'cp' }, e('circle', { cx: 50, cy: 50, r: 42 })),
          e('circle', { key: 'b', cx: 50, cy: 50, r: 42, fill: `url(#${gV})` }),
          e('g', { key: 'm', clipPath: `url(#${cp})`, ...meridian },
            e('line', { x1: 8, y1: 50, x2: 92, y2: 50 }),
            e('line', { x1: 50, y1: 8, x2: 50, y2: 92 }),
            e('ellipse', { cx: 50, cy: 50, rx: 20, ry: 42 }),
            e('ellipse', { cx: 50, cy: 50, rx: 42, ry: 20 })),
          e('ellipse', { key: 'g', cx: 37, cy: 31, rx: 19, ry: 13, fill: `url(#${gl})` }),
        ];
      case 'twin':
        return [
          e('circle', { key: 'l', cx: 37, cy: 50, r: 28, fill: `url(#${gV})` }),
          e('circle', { key: 'r', cx: 63, cy: 50, r: 28, fill: `url(#${gT})`, opacity: 0.92, style: { mixBlendMode: 'multiply' } }),
          e('ellipse', { key: 'g', cx: 30, cy: 32, rx: 18, ry: 12, fill: `url(#${gl})` }),
        ];
      case 'sprout':
        return [
          e('rect', { key: 't', x: 8, y: 8, width: 84, height: 84, rx: 26, fill: `url(#${gV})` }),
          e('path', { key: 'stem', d: 'M50 78 L50 50', stroke: '#fff', strokeWidth: 5, strokeLinecap: 'round', fill: 'none' }),
          e('path', { key: 'lf', d: 'M50 62 C 50 45 37 39 23 41 C 25 58 40 65 50 62 Z', fill: 'rgba(255,255,255,.96)' }),
          e('path', { key: 'rf', d: 'M50 55 C 50 41 63 36 77 38 C 75 53 60 59 50 55 Z', fill: 'rgba(255,255,255,.80)' }),
          e('rect', { key: 'g', x: 14, y: 14, width: 46, height: 30, rx: 16, fill: `url(#${gl})` }),
        ];
      case 'mono':
      default:
        return [
          e('rect', { key: 't', x: 8, y: 8, width: 84, height: 84, rx: 26, fill: `url(#${gT})` }),
          e('text', { key: 'p', x: 51, y: 55, textAnchor: 'middle', dominantBaseline: 'central',
            fontFamily: 'var(--font-display)', fontWeight: 800, fontSize: 62, fill: '#fff', letterSpacing: '-0.04em' }, 'P'),
          e('rect', { key: 'g', x: 14, y: 14, width: 46, height: 30, rx: 16, fill: `url(#${gl})` }),
        ];
    }
  }

  const BrandMark = ({ size = 80, concept: c, style }) => {
    const name = c || (window.APP && window.APP.BRAND) || 'twin';
    const uid = React.useId().replace(/[:]/g, '');
    const ids = { gV: 'gv' + uid, gT: 'gt' + uid, gl: 'gl' + uid, cp: 'cp' + uid };
    return e('svg', { width: size, height: size, viewBox: '0 0 100 100', 'aria-hidden': true, style: { display: 'block', flexShrink: 0, ...style } },
      e('defs', null,
        e('linearGradient', { id: ids.gV, x1: '12%', y1: '4%', x2: '82%', y2: '96%' },
          e('stop', { offset: '0%', stopColor: 'var(--orb-violet)' }),
          e('stop', { offset: '100%', stopColor: 'var(--orb-deep)' })),
        e('linearGradient', { id: ids.gT, x1: '12%', y1: '4%', x2: '82%', y2: '96%' },
          e('stop', { offset: '0%', stopColor: 'var(--orb-pink)' }),
          e('stop', { offset: '100%', stopColor: 'var(--orb-magenta)' })),
        e('radialGradient', { id: ids.gl, cx: '34%', cy: '26%', r: '58%' },
          e('stop', { offset: '0%', stopColor: 'rgba(255,255,255,.6)' }),
          e('stop', { offset: '62%', stopColor: 'rgba(255,255,255,0)' }))),
      concept(name, ids));
  };

  /* Neutral glossy disc — decorative accent (replaces the old bubble Orb). */
  const Disc = ({ size = 80, from = 'var(--orb-pink)', to = 'var(--orb-violet)', style }) => {
    const uid = React.useId().replace(/[:]/g, '');
    const gd = 'd' + uid, gl = 'dl' + uid;
    return e('svg', { width: size, height: size, viewBox: '0 0 100 100', 'aria-hidden': true, style: { display: 'block', flexShrink: 0, ...style } },
      e('defs', null,
        e('linearGradient', { id: gd, x1: '15%', y1: '8%', x2: '85%', y2: '92%' },
          e('stop', { offset: '0%', stopColor: from }),
          e('stop', { offset: '100%', stopColor: to })),
        e('radialGradient', { id: gl, cx: '34%', cy: '26%', r: '58%' },
          e('stop', { offset: '0%', stopColor: 'rgba(255,255,255,.6)' }),
          e('stop', { offset: '62%', stopColor: 'rgba(255,255,255,0)' }))),
      e('circle', { cx: 50, cy: 50, r: 44, fill: `url(#${gd})` }),
      e('ellipse', { cx: 37, cy: 31, rx: 20, ry: 13, fill: `url(#${gl})` }));
  };

  /* Override the brand primitives so all existing screens update automatically. */
  PS.OrbCluster = ({ size = 64, style }) => e(BrandMark, { size, style });
  PS.Orb = ({ size = 80, from, to, style }) => e(Disc, { size, from, to, style });

  /* Logo-direction option card for the design-canvas brand section. */
  const LogoCard = ({ concept: c, name, fi }) => {
    const isDef = (window.APP.BRAND === c);
    return e('div', { style: { width: 320, background: '#fff', borderRadius: 28, padding: '36px 28px 30px',
      boxShadow: 'var(--sh-2)', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 20,
      border: isDef ? '2px solid var(--written)' : '1px solid var(--glass-line)', position: 'relative' } },
      isDef && e('span', { style: { position: 'absolute', top: 14, right: 14, padding: '6px 11px', borderRadius: 999,
        background: 'var(--written-bg)', color: 'var(--written)', fontFamily: 'var(--font-display)', fontWeight: 700,
        fontSize: 10.5, letterSpacing: '0.07em' } }, 'NYKYINEN'),
      e(BrandMark, { concept: c, size: 104 }),
      e('div', { style: { display: 'flex', alignItems: 'center', gap: 10 } },
        e(BrandMark, { concept: c, size: 28 }),
        e('span', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 25, letterSpacing: '-0.03em', color: 'var(--ink)' } },
          'Puhu', e('span', { style: { color: 'var(--ink-3)' } }, 'Scribe'))),
      e('div', { style: { textAlign: 'center' } },
        e('div', { style: { fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: 17, color: 'var(--ink)' } }, name),
        e('div', { style: { fontFamily: 'var(--font-body)', fontWeight: 500, fontSize: 14, color: 'var(--ink-3)', marginTop: 3 } }, fi)));
  };

  Object.assign(A, { BrandMark, Disc, LogoCard });
})();
