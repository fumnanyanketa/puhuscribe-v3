import { spawnSync } from 'node:child_process'
import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from 'node:fs'
import { tmpdir } from 'node:os'
import { join } from 'node:path'
import { crc32, deflateRawSync } from 'node:zlib'
import { afterEach, describe, expect, it } from 'vitest'
import { zipEntries } from './check-files-for-secrets.ts'

// [12] [14] The guard that runs before every artifact upload: no file that
// holds the Access service token (or another named secret) is ever uploaded.
// Uses a made up value, never the real secret.

const CHECKER = join(import.meta.dirname, 'check-files-for-secrets.ts')
const FAKE_SECRET = ['made', 'up', 'access', 'secret', '0123456789'].join('-')
const FAKE_ID = ['made', 'up', 'client', 'id'].join('-') + '.access'
const dirs: string[] = []

afterEach(() => {
  for (const dir of dirs.splice(0)) rmSync(dir, { recursive: true, force: true })
})

function folder(files: Record<string, string | Buffer>): string {
  const dir = mkdtempSync(join(tmpdir(), 'puhuscribe-upload-'))
  dirs.push(dir)
  for (const [name, content] of Object.entries(files)) {
    mkdirSync(join(dir, name, '..'), { recursive: true })
    writeFileSync(join(dir, name), content)
  }
  return dir
}

// A minimal zip writer, enough to imitate a Playwright trace file.
function zip(entries: Record<string, string>, method: 0 | 8 = 8): Buffer {
  const locals: Buffer[] = []
  const centrals: Buffer[] = []
  let offset = 0
  for (const [name, text] of Object.entries(entries)) {
    const data = Buffer.from(text)
    const stored = method === 8 ? deflateRawSync(data) : data
    const nameBuf = Buffer.from(name)
    const local = Buffer.alloc(30)
    local.writeUInt32LE(0x04034b50, 0)
    local.writeUInt16LE(20, 4)
    local.writeUInt16LE(method, 8)
    local.writeUInt32LE(crc32(data), 14)
    local.writeUInt32LE(stored.length, 18)
    local.writeUInt32LE(data.length, 22)
    local.writeUInt16LE(nameBuf.length, 26)
    const central = Buffer.alloc(46)
    central.writeUInt32LE(0x02014b50, 0)
    central.writeUInt16LE(20, 4)
    central.writeUInt16LE(20, 6)
    central.writeUInt16LE(method, 10)
    central.writeUInt32LE(crc32(data), 16)
    central.writeUInt32LE(stored.length, 20)
    central.writeUInt32LE(data.length, 24)
    central.writeUInt16LE(nameBuf.length, 28)
    central.writeUInt32LE(offset, 42)
    locals.push(local, nameBuf, stored)
    centrals.push(central, nameBuf)
    offset += local.length + nameBuf.length + stored.length
  }
  const directory = Buffer.concat(centrals)
  const end = Buffer.alloc(22)
  end.writeUInt32LE(0x06054b50, 0)
  end.writeUInt16LE(Object.keys(entries).length, 8)
  end.writeUInt16LE(Object.keys(entries).length, 10)
  end.writeUInt32LE(directory.length, 12)
  end.writeUInt32LE(offset, 16)
  return Buffer.concat([...locals, directory, end])
}

function run(paths: string[], env: Record<string, string> = { CF_ACCESS_CLIENT_SECRET: FAKE_SECRET }) {
  const args = [CHECKER, ...Object.keys(env).flatMap((name) => ['--env', name]), ...paths]
  return spawnSync(process.execPath, args, { encoding: 'utf8', env: { ...process.env, ...env } })
}

describe('check-files-for-secrets', () => {
  it('[12] passes screenshots, videos and logs that hold no secret', () => {
    const dir = folder({
      'run/test-finished-1.png': Buffer.from([137, 80, 78, 71]),
      'run/video.webm': 'webm',
    })
    const result = run([dir])
    expect(result.status).toBe(0)
    expect(result.stdout).toContain('No secret values found in 2 files')
  })

  it('[12] fails when a plain file holds the secret, without printing it', () => {
    const dir = folder({ 'report/index.html': `<pre>cf-access-client-secret: ${FAKE_SECRET}</pre>` })
    const result = run([dir])
    expect(result.status).toBe(1)
    expect(result.stderr).toContain('CF_ACCESS_CLIENT_SECRET')
    expect(result.stdout + result.stderr).not.toContain(FAKE_SECRET)
  })

  it('[12] fails when a compressed trace inside a zip holds the secret', () => {
    const trace = zip({
      'trace.network': `{"headers":[{"name":"cf-access-client-secret","value":"${FAKE_SECRET}"}]}`,
    })
    expect(trace.includes(Buffer.from(FAKE_SECRET))).toBe(false) // only visible after unzipping
    const result = run([folder({ 'run/trace.zip': trace })])
    expect(result.status).toBe(1)
    expect(result.stderr).toContain('trace.zip!trace.network: CF_ACCESS_CLIENT_SECRET')
    expect(result.stdout + result.stderr).not.toContain(FAKE_SECRET)
  })

  it('[12] checks every named variable, here the client ID', () => {
    const dir = folder({ 'error-context.md': `CF-Access-Client-Id: ${FAKE_ID}` })
    const result = run([dir], { CF_ACCESS_CLIENT_SECRET: FAKE_SECRET, CF_ACCESS_CLIENT_ID: FAKE_ID })
    expect(result.status).toBe(1)
    expect(result.stderr).toContain('CF_ACCESS_CLIENT_ID')
    expect(result.stdout + result.stderr).not.toContain(FAKE_ID)
  })

  it('[12] fails safe on a zip it cannot read', () => {
    const broken = Buffer.concat([Buffer.from([0x50, 0x4b, 0x03, 0x04]), Buffer.from('not really a zip')])
    const result = run([folder({ 'trace.zip': broken })])
    expect(result.status).toBe(1)
    expect(result.stderr).toContain('unreadable zip file')
  })

  it('[12] refuses to run when a named secret is not set, because it would check nothing', () => {
    const result = run([folder({ 'a.txt': 'x' })], { CF_ACCESS_CLIENT_SECRET: '' })
    expect(result.status).toBe(2)
  })

  it('[12] skips folders that do not exist', () => {
    const result = run([join(tmpdir(), 'puhuscribe-no-such-folder')])
    expect(result.status).toBe(0)
  })
})

describe('zipEntries', () => {
  it('[12] reads stored and deflated entries', () => {
    expect(zipEntries(zip({ 'a.txt': 'alpha' }, 0)).map((e) => e.data.toString())).toEqual(['alpha'])
    expect(zipEntries(zip({ 'b.txt': 'beta', 'c.txt': 'gamma' })).map((e) => e.data.toString())).toEqual([
      'beta',
      'gamma',
    ])
  })
})
