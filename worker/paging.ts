// Reading every row of a list, page by page (factory/jobs/20-a1-road/spec.md, "Done when" 23).
//
// The database API returns at most max_rows rows for one read (1,000 in supabase/config.toml; the
// hosted setting was not checked) and says nothing when it cuts an answer short. A learner who has
// met all 108 dialogues has about 14,000 words in their lines and up to about 1,500 cards, so a read
// that selects them in one go would silently lose rows. readAll asks for pages of 500 and goes on
// until a page comes back short, so it is complete while the cap is at least the page size. Lists in
// a request address (an `in` filter) are cut into chunks so the address stays short.

export const PAGE_SIZE = 500
export const LIST_CHUNK = 150

type Page<T> = PromiseLike<{ data: T[] | null; error: unknown }>

/** Every row of a read. `page` asks for the rows from the first to the last index, with a stable order. */
export async function readAll<T>(
  page: (from: number, to: number) => Page<T>,
  fail: () => Error,
): Promise<T[]> {
  const rows: T[] = []
  for (;;) {
    const { data, error } = await page(rows.length, rows.length + PAGE_SIZE - 1)
    if (error || data === null) throw fail()
    rows.push(...data)
    // A page shorter than the page size is the last one. This holds while the API's own cap is at
    // least the page size; the cap is 1,000 here and its hosted value is an open point.
    if (data.length < PAGE_SIZE) return rows
  }
}

export function chunks<T>(items: readonly T[], size = LIST_CHUNK): T[][] {
  const parts: T[][] = []
  for (let i = 0; i < items.length; i += size) parts.push(items.slice(i, i + size))
  return parts
}

/** Every row of a read that filters on a long list of values, one chunk of the list at a time. */
export async function readAllIn<K, T>(
  keys: readonly K[],
  read: (chunk: K[]) => (from: number, to: number) => Page<T>,
  fail: () => Error,
): Promise<T[]> {
  const rows: T[] = []
  for (const chunk of chunks(keys)) rows.push(...(await readAll(read(chunk), fail)))
  return rows
}
