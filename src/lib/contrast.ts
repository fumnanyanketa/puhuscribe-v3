// The WCAG 2 contrast ratio of two opaque colours given as #rrggbb.
// Used by tests/design-tokens.test.ts and by the reference page, so both
// report the same numbers (factory/jobs/5-design-system/spec.md, "Done when" 4).

function channel(hex: string, at: number): number {
  const value = parseInt(hex.slice(at, at + 2), 16) / 255
  return value <= 0.03928 ? value / 12.92 : ((value + 0.055) / 1.055) ** 2.4
}

export function luminance(hex: string): number {
  return 0.2126 * channel(hex, 1) + 0.7152 * channel(hex, 3) + 0.0722 * channel(hex, 5)
}

export function contrast(a: string, b: string): number {
  const first = luminance(a)
  const second = luminance(b)
  const light = Math.max(first, second)
  const dark = Math.min(first, second)
  return (light + 0.05) / (dark + 0.05)
}

/** True for an opaque colour written as #rrggbb. */
export function isOpaqueHex(value: string): boolean {
  return /^#[0-9a-f]{6}$/i.test(value)
}
