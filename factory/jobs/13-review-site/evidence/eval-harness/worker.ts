// Evaluator scratch harness only: the real handler with a local key set in place of the Access certs fetch.
import { createLocalJWKSet } from 'jose'
import { handleReviewRequest, type ReviewEnv } from '../review-site/handler.ts'
import { JWKS } from './keys.ts'
const local = createLocalJWKSet(JWKS as never)
export default { fetch: (r: Request, env: ReviewEnv) => handleReviewRequest(r, env, () => local) }
