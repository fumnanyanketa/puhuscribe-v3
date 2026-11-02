// Reads the colour tokens out of the text of tokens.css. The look is light
// only (job 19-redesign, owner's call 4), so there is one set of values.
// Shared by tests/design-tokens.test.ts and the reference page, so both see
// the same values.

export interface ColourToken {
  name: string
  value: string
  /** The comment written after the value in tokens.css, if any. */
  purpose: string
}

export function colourTokens(css: string): ColourToken[] {
  const found = new Map<string, ColourToken>()
  for (const match of css.matchAll(
    /(--color-[a-z0-9-]+):\s*(#[0-9a-fA-F]{6,8})\s*;[ \t]*(?:\/\*\s*(.*?)\s*\*\/)?/g,
  )) {
    const name = match.at(1)
    const value = match.at(2)
    if (name && value) found.set(name, { name, value: value.toLowerCase(), purpose: match.at(3) ?? '' })
  }
  return [...found.values()]
}

export function asMap(tokens: ColourToken[]): Map<string, string> {
  return new Map(tokens.map((token) => [token.name, token.value]))
}
