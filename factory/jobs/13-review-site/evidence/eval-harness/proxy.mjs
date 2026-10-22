// Evaluator scratch: stands in for Cloudflare Access by adding the token header, then forwards to the harness on 8788.
import http from 'node:http'
import { readFileSync } from 'node:fs'
const token = JSON.parse(readFileSync(new URL('./tokens.json', import.meta.url))).valid
http.createServer((req, res) => {
  const up = http.request({ host: '127.0.0.1', port: 8788, path: req.url, method: req.method,
    headers: { ...req.headers, host: '127.0.0.1:8788', 'cf-access-jwt-assertion': token } }, (r) => {
    res.writeHead(r.statusCode, r.headers); r.pipe(res) })
  up.on('error', (e) => { res.writeHead(502); res.end(String(e)) })
  req.pipe(up)
}).listen(8789, '127.0.0.1', () => console.log('proxy on 8789'))
