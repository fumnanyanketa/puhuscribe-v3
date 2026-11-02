import { useId, type CSSProperties } from 'react'
import {
  bandPines,
  dashPolygons,
  edge,
  FELLS,
  HORIZON,
  horizonPines,
  pointsText,
  roadPolygon,
  SCENE_HEIGHT,
  SCENE_WIDTH,
  travelledPolygons,
} from './landscape-geometry.ts'
import styles from './Landscape.module.css'

// The landscape (job 19-redesign, statement 4): inline SVG drawn from fixed
// shapes and numbers, with no image file, no request and no third party. Its
// colours are the --land-* tokens, so the evening set swaps in through
// data-land="evening". The drawing is aria-hidden: it carries no meaning.
//
// Two uses. The band sits behind the top of every screen except the road and
// fades into the wash (the fade is drawn inside the SVG, because CSS gradients
// are refused). The road scene is the home screen's picture, in two layers of
// the same 280 x 620 box: the backdrop (sky, fells, sun, ridge, ground) and the
// road on top, so the opening animation can draw the road on its own.

const fill = (name: string, opacity?: string): CSSProperties => ({
  fill: `var(--land-${name})`,
  ...(opacity ? { fillOpacity: `var(--land-${opacity})` } : {}),
})
const stop = (name: string): CSSProperties => ({ stopColor: `var(--land-${name})` })
const strokeOf = (name: string, opacity?: string): CSSProperties => ({
  stroke: `var(--land-${name})`,
  ...(opacity ? { strokeOpacity: `var(--land-${opacity})` } : {}),
})

/** The band behind the top of a screen. */
export function Landscape({ className }: { className?: string }) {
  const id = useId().replace(/\W/g, '')
  const sky = `${id}sky`
  const sun = `${id}sun`
  const fade = `${id}fade`
  const mask = `${id}mask`
  return (
    <div className={className ? `${styles.band} ${className}` : styles.band} aria-hidden="true">
      <svg viewBox="0 0 280 170" preserveAspectRatio="xMidYMax slice" focusable="false">
        <defs>
          <linearGradient id={sky} x1="0" y1="0" x2="0" y2="1">
            <stop offset="0" style={stop('sky-top')} />
            <stop offset="1" style={stop('sky-middle')} />
          </linearGradient>
          <radialGradient id={sun} cx=".5" cy=".45" r=".55">
            <stop offset="0" style={stop('sun-core')} />
            <stop offset=".6" style={stop('sun-mid')} />
            <stop offset="1" style={stop('sun-edge')} />
          </radialGradient>
          <linearGradient id={fade} x1="0" y1="0" x2="0" y2="1">
            <stop offset="0.7" stopColor="white" />
            <stop offset="1" stopColor="black" />
          </linearGradient>
          <mask id={mask}>
            <rect width="280" height="170" fill={`url(#${fade})`} />
          </mask>
        </defs>
        <g mask={`url(#${mask})`}>
          <rect width="280" height="170" fill={`url(#${sky})`} />
          <path
            d="M0 96 C 50 70, 90 80, 130 60 C 160 48, 200 72, 240 66 C 260 62, 275 74, 280 78 L280 170 L0 170 Z"
            style={fill('hill-band-1')}
          />
          <circle
            cx="214"
            cy="98"
            r="17"
            fill={`url(#${sun})`}
            strokeWidth="1"
            style={strokeOf('sun-ring')}
          />
          <path
            d="M0 110 C 40 92, 80 96, 112 110 C 140 120, 175 102, 205 106 C 235 110, 260 98, 280 102 L280 170 L0 170 Z"
            style={fill('hill-band-2')}
          />
          {bandPines().map((pine) => (
            <path key={pine.key} d={pine.d} style={fill('pine-band')} />
          ))}
          <path
            d="M0 124 C 60 112, 120 126, 170 118 C 210 112, 250 120, 280 116 L280 170 L0 170 Z"
            style={fill('hill-band-3')}
          />
        </g>
      </svg>
    </div>
  )
}

interface RoadPartProps {
  /** The evening set, for Done for today. */
  evening?: boolean
  /** Lets the road screen animate this layer (the opening animation). */
  className?: string
  /** Lets the road screen animate the sun's rise. */
  sunClassName?: string
}

const SCENE_BOX = `0 0 ${String(SCENE_WIDTH)} ${String(SCENE_HEIGHT)}`

/**
 * The sky, the fells, the A1 sun, the pine ridge and the ground, in the 280 x
 * 620 box. The road is drawn on top of it by RoadWay, a second layer with the
 * same box.
 */
export function RoadBackdrop({ evening = false, className, sunClassName }: RoadPartProps) {
  const id = useId().replace(/\W/g, '')
  const horizon = HORIZON
  const h = (offset: number) => String(horizon + offset)
  return (
    <svg
      className={className ? `${styles.scene} ${className}` : styles.scene}
      viewBox={SCENE_BOX}
      preserveAspectRatio="none"
      aria-hidden="true"
      focusable="false"
      data-land={evening ? 'evening' : undefined}
    >
      <defs>
        <linearGradient id={`${id}sky`} x1="0" y1="0" x2="0" y2="1">
          <stop offset="0" style={stop('sky-top')} />
          <stop offset=".75" style={stop('sky-middle')} />
          <stop offset="1" style={stop('sky-bottom')} />
        </linearGradient>
        <linearGradient id={`${id}ground`} x1="0" y1="0" x2="0" y2="1">
          <stop offset="0" style={stop('ground-top')} />
          <stop offset=".45" style={stop('ground-middle')} />
          <stop offset="1" style={stop('ground-bottom')} />
        </linearGradient>
        <radialGradient id={`${id}sun`} cx=".5" cy=".45" r=".55">
          <stop offset="0" style={stop('sun-core')} />
          <stop offset=".6" style={stop('sun-mid')} />
          <stop offset="1" style={stop('sun-edge')} />
        </radialGradient>
        <clipPath id={`${id}above`}>
          <rect x="0" y="0" width={SCENE_WIDTH} height={horizon + 2} />
        </clipPath>
      </defs>
      <rect width={SCENE_WIDTH} height={SCENE_HEIGHT} fill={`url(#${id}sky)`} />
      <g style={fill('star', 'star-opacity')}>
        <circle cx="64" cy="120" r="1.2" />
        <circle cx="210" cy="96" r="1" />
        <circle cx="160" cy="140" r="1.1" />
        <circle cx="40" cy="180" r=".9" />
      </g>
      <path
        d={`M66 ${h(0)} C 104 ${h(-52)}, 136 ${h(-92)}, 160 ${h(-94)} C 184 ${h(-92)}, 216 ${h(-52)}, 254 ${h(0)} Z`}
        style={fill('fell-far')}
      />
      <path
        d={`M146 ${h(-86)} C 152 ${h(-93)}, 168 ${h(-93)}, 174 ${h(-86)} C 168 ${h(-83)}, 164 ${h(-86)}, 160 ${h(-82)} C 156 ${h(-86)}, 151 ${h(-83)}, 146 ${h(-86)} Z`}
        style={fill('snow', 'snow-opacity')}
      />
      <path
        d={`M-4 ${h(0)} C 30 ${h(-42)}, 62 ${h(-70)}, 86 ${h(-72)} C 110 ${h(-70)}, 140 ${h(-42)}, 172 ${h(0)} Z`}
        style={fill('fell-left')}
      />
      <path
        d={`M156 ${h(0)} C 182 ${h(-30)}, 204 ${h(-50)}, 222 ${h(-52)} C 240 ${h(-50)}, 262 ${h(-30)}, 288 ${h(0)} Z`}
        style={fill('fell-right')}
      />
      <path
        d={`M150 ${h(-34)} C 175 ${h(-38)}, 208 ${h(-44)}, 222 ${h(-51)} C 186 ${h(-58)}, 118 ${h(-60)}, 86 ${h(-71)} C 108 ${h(-80)}, 146 ${h(-86)}, 160 ${h(-93)}`}
        fill="none"
        strokeWidth="2"
        strokeDasharray="2 4"
        strokeLinecap="round"
        style={strokeOf('trail', 'trail-opacity')}
      />
      <g clipPath={`url(#${id}above)`}>
        <g className={styles.sunDrop}>
          <g className={sunClassName}>
            <circle
              cx="150"
              cy={horizon - 6}
              r="44"
              style={{ ...fill('sun-halo'), fillOpacity: 'var(--land-halo-opacity)' }}
            />
            <circle
              cx="150"
              cy={horizon - 6}
              r="30"
              fill={`url(#${id}sun)`}
              strokeWidth="1.5"
              style={strokeOf('sun-ring')}
            />
            <text
              x="150"
              y={horizon - 12}
              textAnchor="middle"
              fontFamily="Poppins, sans-serif"
              fontSize="12"
              fontWeight="600"
              style={fill('sun-text')}
            >
              A1
            </text>
          </g>
        </g>
      </g>
      <path
        d={`M0 ${h(-14)} C 40 ${h(-30)}, 80 ${h(-26)}, 110 ${h(-8)} C 130 ${h(2)}, 170 ${h(2)}, 190 ${h(-10)} C 220 ${h(-30)}, 255 ${h(-26)}, 280 ${h(-16)} L 280 ${h(6)} L 0 ${h(6)} Z`}
        style={fill('ridge')}
      />
      <g style={fill('pine')}>
        {horizonPines().map((pine) => (
          <path key={pine.key} d={pine.d} />
        ))}
      </g>
      <rect
        x="0"
        y={horizon}
        width={SCENE_WIDTH}
        height={SCENE_HEIGHT - horizon}
        fill={`url(#${id}ground)`}
      />
    </svg>
  )
}

interface RoadWayProps extends RoadPartProps {
  /** How far up the road the learner has travelled (0 to 1), for the mint centre line. */
  travelledTo: number
}

/** The road winding to the sun: verge, asphalt, edge lines, dashes, and the mint travelled stretch. */
export function RoadWay({ travelledTo, evening = false, className }: RoadWayProps) {
  const id = useId().replace(/\W/g, '')
  const doneTo = Math.max(0, Math.min(0.97, travelledTo))
  return (
    <svg
      className={className ? `${styles.scene} ${className}` : styles.scene}
      viewBox={SCENE_BOX}
      preserveAspectRatio="none"
      aria-hidden="true"
      focusable="false"
      data-land={evening ? 'evening' : undefined}
    >
      <defs>
        <linearGradient id={`${id}asphalt`} x1="0" y1="1" x2="0" y2="0">
          <stop offset="0" style={stop('asphalt-near')} />
          <stop offset=".6" style={stop('asphalt-middle')} />
          <stop offset="1" style={stop('asphalt-far')} />
        </linearGradient>
      </defs>
      <polygon points={roadPolygon(0, 1, 1.22)} style={fill('verge')} />
      <polygon points={roadPolygon(0, 1)} fill={`url(#${id}asphalt)`} />
      <polyline
        points={pointsText(edge(-1, 0, 0.97, 0.9))}
        fill="none"
        strokeWidth="1.6"
        strokeOpacity=".9"
        style={strokeOf('line-white')}
      />
      <polyline
        points={pointsText(edge(1, 0, 0.97, 0.9))}
        fill="none"
        strokeWidth="1.6"
        strokeOpacity=".9"
        style={strokeOf('line-white')}
      />
      <g style={{ ...fill('line-white'), fillOpacity: 0.95 }}>
        {dashPolygons(doneTo, 0.97).map((points) => (
          <polygon key={points} points={points} />
        ))}
      </g>
      {doneTo > 0 && (
        <g>
          <g style={fill('travelled')}>
            {travelledPolygons(doneTo).map((points) => (
              <polygon key={points} points={points} />
            ))}
          </g>
          <polyline
            points={pointsText(edge(-1, 0, doneTo, 0.9))}
            fill="none"
            strokeWidth="2.2"
            style={strokeOf('travelled')}
          />
          <polyline
            points={pointsText(edge(1, 0, doneTo, 0.9))}
            fill="none"
            strokeWidth="2.2"
            style={strokeOf('travelled')}
          />
        </g>
      )}
    </svg>
  )
}

interface RoadSceneProps {
  travelledTo: number
  evening?: boolean
}

/** The whole picture in one box, as the reference page shows it. */
export function RoadScene({ travelledTo, evening = false }: RoadSceneProps) {
  return (
    <div className={styles.sceneBox}>
      <RoadBackdrop evening={evening} />
      <RoadWay travelledTo={travelledTo} evening={evening} className={styles.layer} />
    </div>
  )
}

export const FELL_FLAGS = [
  { name: 'A2', ...FELLS.A2 },
  { name: 'B1', ...FELLS.B1 },
  { name: 'B2', ...FELLS.B2 },
] as const
