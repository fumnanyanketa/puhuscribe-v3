import { handleApi, type ApiDeps, type ApiEnv } from './api.ts'

// The single Cloudflare Worker for PuhuScribe. Static files (the React app) are
// served by Cloudflare before this code runs; wrangler.jsonc sends every /api/*
// request here first, so the API always lives on the same address as the page.
export async function handleRequest(request: Request, env: ApiEnv, deps?: ApiDeps): Promise<Response> {
  const url = new URL(request.url)
  if (url.pathname === '/api' || url.pathname.startsWith('/api/')) {
    return handleApi(request, env, deps)
  }
  return new Response('Not found', { status: 404 })
}

export default {
  fetch(request, env) {
    // Secrets set on the Worker (or in .env.local locally) arrive in env.
    return handleRequest(request, env)
  },
} satisfies ExportedHandler<Env>
