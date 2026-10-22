// Evaluator scratch harness: makes a local Access-like key and test tokens.
import { generateKeyPair, exportJWK, SignJWT, base64url } from 'jose'
import { writeFileSync } from 'node:fs'
const TEAM = 'https://eval-team.cloudflareaccess.com'
const AUD = 'b'.repeat(64)
const { publicKey, privateKey } = await generateKeyPair('RS256', { extractable: true })
const other = (await generateKeyPair('RS256')).privateKey
const ec = (await generateKeyPair('ES256')).privateKey
const jwk = { ...(await exportJWK(publicKey)), kid: 'k1', alg: 'RS256', use: 'sig' }
writeFileSync('keys.ts', `export const JWKS = ${JSON.stringify({ keys: [jwk] })}\n`)
const mk = (o = {}) => {
  let j = new SignJWT({ type: 'app', email: 'not-an-address' // the run used a made up .invalid address here }).setProtectedHeader({ alg: o.alg ?? 'RS256', kid: 'k1' })
    .setIssuer(o.iss ?? TEAM).setAudience(o.aud ?? AUD).setIssuedAt(o.iat ?? Math.floor(Date.now()/1000))
  if (o.nbf) j = j.setNotBefore(o.nbf)
  if (!o.noexp) j = j.setExpirationTime(o.exp ?? '1h')
  return j.sign(o.key ?? privateKey)
}
const now = Math.floor(Date.now()/1000)
const valid = await mk()
const [h, p] = valid.split('.')
const tokens = {
  valid,
  wrong_signature: await mk({ key: other }),
  wrong_aud: await mk({ aud: 'c'.repeat(64) }),
  wrong_iss: await mk({ iss: 'https://other-team.cloudflareaccess.com' }),
  expired: await mk({ exp: now - 60, iat: now - 3600 }),
  no_exp: await mk({ noexp: true }),
  not_yet_valid: await mk({ nbf: now + 3600 }),
  alg_es256_other_key: await new SignJWT({}).setProtectedHeader({ alg: 'ES256', kid: 'k1' }).setIssuer(TEAM).setAudience(AUD).setExpirationTime('1h').sign(ec),
  alg_none: `${base64url.encode(JSON.stringify({ alg: 'none', kid: 'k1' }))}.${p}.`,
  alg_hs256: `${base64url.encode(JSON.stringify({ alg: 'HS256', kid: 'k1' }))}.${p}.${base64url.encode('x')}`,
  tampered_payload: `${h}.${base64url.encode(JSON.stringify({ iss: TEAM, aud: AUD, exp: now + 99999, type: 'app', email: 'x' }))}.${valid.split('.')[2]}`,
  malformed: 'not.a.token',
  empty_string: '',
}
writeFileSync('tokens.json', JSON.stringify(tokens))
console.log(Object.keys(tokens).join(' '))
