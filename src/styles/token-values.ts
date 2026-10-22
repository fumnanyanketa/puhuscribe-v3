// Reads the colour tokens out of the text of tokens.css, for light and dark.
// Shared by tests/design-tokens.test.ts and the reference page, so both see
// the same values (factory/jobs/5-design-system/spec.md, "Done when" 3 and 4).

export interface ColourToken {
  name: string
  value: string
  /** The comment written after the value in tokens.css, if any. */
  purpose: string
}

function read(block: string): ColourToken[] {
  const found = new Map<string, ColourToken>()
  for (const match of block.matchAll(
    /(--color-[a-z0-9-]+):\s*(#[0-9a-fA-F]{6,8})\s*;[ \t]*(?:\/\*\s*(.*?)\s*\*\/)?/g,
  )) {
    const name = match.at(1)
    const value = match.at(2)
    if (name && value) found.set(name, { name, value: value.toLowerCase(), purpose: match.at(3) ?? '' })
  }
  return [...found.values()]
}

export function colourTokens(css: string): { light: ColourToken[]; dark: ColourToken[] } {
  const darkStart = css.indexOf('@media (prefers-color-scheme: dark) {')
  return { light: read(css.slice(0, darkStart)), dark: read(css.slice(darkStart)) }
}

export function asMap(tokens: ColourToken[]): Map<string, string> {
  return new Map(tokens.map((token) => [token.name, token.value]))
}
