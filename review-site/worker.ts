import { handleReviewRequest, type ReviewEnv } from './handler.ts'

// The review site's Worker, puhuscribe-review (job 13-review-site). It runs
// before every file and passes each request to review-site/handler.ts, which
// checks the method, the Cloudflare Access token and the path, and sets the
// headers. A Worker's entry may export only handlers, so the rest lives there.
export default {
  fetch(request, env) {
    return handleReviewRequest(request, env)
  },
} satisfies ExportedHandler<ReviewEnv>
