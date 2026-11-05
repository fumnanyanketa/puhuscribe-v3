// The stop pictures (fast route road-stops, owner approved 5 November 2026): one free unDraw illustration
// per stop of the A1 road, in public/stops/01.svg to 36.svg (source and licence in design/stop-pictures/README.md;
// public/ holds images only).
// The road shows each sign's picture just above its board; the stop screen shows it large.
//
// Each picture's width divided by its height, from the file's viewBox, so the browser keeps the right room
// for a picture before it has loaded and the sign fitting on the road never jumps.
// src/road/stop-pictures.test.ts checks every ratio against its file.

export const STOP_PICTURE_RATIOS: Readonly<Record<number, number>> = {
  1: 0.913,
  2: 0.811,
  3: 0.966,
  4: 2.276,
  5: 1.39,
  6: 0.473,
  7: 1.243,
  8: 1.109,
  9: 0.753,
  10: 1.208,
  11: 1.973,
  12: 1.152,
  13: 0.947,
  14: 0.873,
  15: 0.815,
  16: 0.988,
  17: 1.404,
  18: 1.355,
  19: 1.476,
  20: 0.895,
  21: 1.726,
  22: 0.911,
  23: 1.155,
  24: 0.959,
  25: 1.091,
  26: 0.774,
  27: 1.178,
  28: 1.23,
  29: 1.06,
  30: 1.206,
  31: 0.595,
  32: 1.088,
  33: 0.816,
  34: 1.01,
  35: 1.261,
  36: 1.139,
}

/** The address of a stop's picture, or undefined for a stop that has none. */
export function stopPicture(stop: number): string | undefined {
  if (!(stop in STOP_PICTURE_RATIOS)) return undefined
  return `/stops/${String(stop).padStart(2, '0')}.svg`
}

/** A stop picture's width divided by its height (1 for a stop without one). */
export function stopPictureRatio(stop: number): number {
  return STOP_PICTURE_RATIOS[stop] ?? 1
}
