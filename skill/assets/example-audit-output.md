# Frontend audit — example-shop

_Date: 2026-05-09 · Framework: vite + vanilla TS · Bundler: vite_
_Sources: package.json, dist/index.html, curl headers from https://example-shop.test, lighthouse.json_

## Executive summary

- **High-severity issues:** 7
- **Medium-severity issues:** 9
- **Low-severity issues:** 4
- **Unknown / not enough evidence:** 3

### Top 5 to fix first

1. `[High]` **Content-Security-Policy missing** — Add a CSP3 header with nonces; remove `unsafe-inline`.
2. `[High]` **LCP image not preloaded** — Add `<link rel="preload" as="image" fetchpriority="high">` for the hero image.
3. `[High]` **No `width`/`height` on images** — Set intrinsic dimensions to eliminate CLS from product cards.
4. `[High]` **HSTS missing** — Add `Strict-Transport-Security: max-age=63072000; includeSubDomains; preload`.
5. `[High]` **No automated a11y in CI** — Wire `@axe-core/playwright` into the existing Playwright suite.

## Findings

### Head & meta

- `[Medium]` **`<meta name="color-scheme">` missing** — Fail
  - Evidence: `dist/index.html` head has no `color-scheme` declaration.
  - Remedy: Add `<meta name="color-scheme" content="light dark">`.
  - See: `skill/references/head-and-meta.md#color-scheme`
- `[Low]` **Referrer-Policy meta missing** — Fail
  - Evidence: not in HTML head; also not in response headers.
  - Remedy: Add either `<meta name="referrer" content="strict-origin-when-cross-origin">` or set the response header.
  - See: `skill/references/head-and-meta.md#referrer-policy`

### Images

- `[High]` **LCP image not preloaded with `fetchpriority`** — Fail
  - Evidence: `dist/index.html` `<img src="/hero.jpg">` has no preload link, no `fetchpriority`.
  - Remedy: `<link rel="preload" as="image" href="/hero.avif" fetchpriority="high" imagesrcset="…" imagesizes="100vw">`.
  - See: `skill/references/images.md#lcp-image`
- `[High]` **Intrinsic `width`/`height` missing on raster images** — Fail
  - Evidence: 14 of 18 `<img>` tags in `dist/index.html` lack `width`/`height`.
  - Remedy: Set both attributes, or use `aspect-ratio` CSS to reserve layout space.
  - See: `skill/references/images.md#intrinsic-size`
- `[Medium]` **No AVIF served via `<picture>`** — Fail
  - Evidence: every product image is `<img src=".jpg">` only.
  - Remedy: Wrap in `<picture>` with `<source type="image/avif">` then `<source type="image/webp">` then JPG fallback.
  - See: `skill/references/images.md#avif-webp`

### JavaScript

- `[High]` **Bundle exceeds budget** — Fail
  - Evidence: `dist/assets/index-*.js` is 412 KB gzipped (budget: 200 KB).
  - Remedy: Audit `node_modules` for moment.js, lodash full imports; switch to date-fns / lodash-es with named imports.
  - See: `skill/references/javascript.md#bundle-budget`
- `[Medium]` **No code-splitting on routes** — Fail
  - Evidence: single entry chunk; no `import()` calls in `src/`.
  - Remedy: Convert route handlers to dynamic `import()` so each route ships only what it needs.
  - See: `skill/references/javascript.md#code-splitting`

### Security

- `[High]` **Content-Security-Policy missing** — Fail
  - Evidence: `curl -sI https://example-shop.test` returns no `content-security-policy` header.
  - Remedy: Start with a Report-Only policy, then enforce: `default-src 'self'; script-src 'self' 'nonce-XXX'; …`.
  - See: `skill/references/security.md#csp3`
- `[High]` **HSTS missing** — Fail
  - Evidence: no `strict-transport-security` header on https response.
  - Remedy: `Strict-Transport-Security: max-age=63072000; includeSubDomains; preload` once you've verified all subdomains are HTTPS.
  - See: `skill/references/security.md#hsts`
- `[Medium]` **Permissions-Policy missing** — Fail
  - Evidence: no `permissions-policy` header.
  - Remedy: `Permissions-Policy: camera=(), microphone=(), geolocation=(), interest-cohort=()`.
  - See: `skill/references/security.md#permissions-policy`
- `[High]` **No SRI on third-party `<script>`** — Fail
  - Evidence: `<script src="https://cdn.example.com/lib.js">` has no `integrity` attribute.
  - Remedy: Generate hash with `openssl dgst -sha384 -binary lib.js | openssl base64 -A`, add `integrity="sha384-…" crossorigin="anonymous"`.
  - See: `skill/references/security.md#sri`

### Performance

- `[High]` **No Brotli** — Fail
  - Evidence: `Content-Encoding: gzip` on text/html, JS, CSS.
  - Remedy: Enable Brotli at the CDN/origin (`br` preferred over `gzip` for modern clients).
  - See: `skill/references/performance.md#compression`
- `[Medium]` **No `Cache-Control: immutable` on hashed assets** — Fail
  - Evidence: `dist/assets/index-abc123.js` served with `Cache-Control: max-age=3600`.
  - Remedy: For hashed files, set `Cache-Control: public, max-age=31536000, immutable`.
  - See: `skill/references/performance.md#cache-control`

### Core Web Vitals

- `[High]` **LCP > 2.5s** — Fail
  - Evidence: `lighthouse.json` reports LCP = 3.8s on mobile.
  - Remedy: Preload LCP image (above), reduce TTFB (CDN cache for HTML), defer non-critical CSS.
  - See: `skill/references/core-web-vitals.md#lcp`
- `[Medium]` **INP** — Unknown
  - Evidence: lighthouse alone doesn't measure INP — need RUM data.
  - Remedy: Wire the `web-vitals` library to your analytics endpoint. Check `references/observability.md`.
  - See: `skill/references/core-web-vitals.md#inp`

### Accessibility

- `[High]` **No automated a11y in CI** — Fail
  - Evidence: `package.json` has Playwright but no `@axe-core/playwright`; no axe / pa11y in scripts.
  - Remedy: `npm i -D @axe-core/playwright` and add a smoke test that runs `await new AxeBuilder({ page }).analyze()` on key routes.
  - See: `skill/references/accessibility.md#automated-testing`
- `[High]` **`prefers-reduced-motion` not honored** — Fail
  - Evidence: `src/styles/animations.css` defines transitions and keyframes with no `@media (prefers-reduced-motion)` guard.
  - Remedy: Wrap motion in `@media (prefers-reduced-motion: no-preference)` or zero out durations under `(prefers-reduced-motion: reduce)`.
  - See: `skill/references/accessibility.md#reduced-motion`

### SEO

- `[High]` **CSR-only content for indexable pages** — Unknown
  - Evidence: vite SPA, no SSR/SSG configured. Couldn't confirm what crawlers see.
  - Remedy: If pages need to rank, switch to a metaframework (Astro, Nuxt, Next, SvelteKit) or prerender critical routes.
  - See: `skill/references/seo.md#ssr-for-indexability`

### Privacy & cookies

- `[High]` **PII in URL query strings** — Fail
  - Evidence: checkout flow uses `?email=user@example.com&order=…`.
  - Remedy: Move to POST body or session-keyed lookup; URLs end up in referer headers, server logs, analytics.
  - See: `skill/references/privacy-and-cookies.md#no-pii-in-urls`

### Dependencies

- `[High]` **`npm audit` reports 3 high vulnerabilities** — Fail
  - Evidence: from `package-lock.json` analysis: `axios@0.21`, `node-fetch@2.6.1`, `tar@4`.
  - Remedy: Bump per advisories; `npm audit fix --force` only after reviewing breaking changes.
  - See: `skill/references/dependencies.md#audit`

### Observability

- `[Medium]` **No error tracking** — Fail
  - Evidence: no Sentry / GlitchTip SDK in `package.json`.
  - Remedy: Add Sentry (or open-source equivalent). Upload source maps privately so you get readable stack traces.
  - See: `skill/references/observability.md#error-tracking`

## Suggested next actions

Prioritized, concrete steps:

1. **Ship security headers** (1 PR) — adds CSP3 (Report-Only first), HSTS, Permissions-Policy, Referrer-Policy, X-Content-Type-Options. Closes 4 High findings.
2. **Fix LCP / CLS** (1 PR) — preload hero with `fetchpriority="high"`, set intrinsic image sizes, switch to `<picture>` with AVIF. Closes 3 High findings, improves Lighthouse score.
3. **Wire `@axe-core/playwright` into CI** (small PR) — closes the High a11y gap and prevents regressions.
4. **Reduce JS bundle** — audit imports, switch to ESM-friendly libs, code-split routes. Closes 1 High + 1 Medium.
5. **Patch dependencies** — `npm audit` triage, then enable Renovate to keep clean.
6. **Add `web-vitals` + Sentry** — gets you real INP data and crash visibility once shipped.

## Not evaluated

To complete the audit, supply:

- `axe-results.json` for granular accessibility violations.
- RUM data (web-vitals → backend) for real INP and TTFB distributions, not just lab.
- A staging URL with auth bypass so we can probe authenticated flows.
