# Security

Defense in depth at the response-header layer. Most of these are one-line server config changes that close major vulnerability classes.

## Transport

- `[High]` <a id="https"></a>**HTTPS everywhere** — no plain HTTP, even for assets. Redirect `http://` → `https://` at the edge. Auto-renew certs (Let's Encrypt, ACME).
- `[High]` <a id="hsts"></a>**HSTS** — `Strict-Transport-Security: max-age=63072000; includeSubDomains; preload`. Only set `preload` once you've verified all subdomains are HTTPS-ready, then submit at https://hstspreload.org. Hard to undo.

## Content Security Policy (CSP3)

- `[High]` <a id="csp3"></a>**CSP with nonces or hashes, no `unsafe-inline`**. Start in Report-Only mode, gather violations, then enforce.
  ```
  Content-Security-Policy:
    default-src 'self';
    script-src 'self' 'nonce-RANDOM_PER_REQUEST' 'strict-dynamic';
    style-src 'self' 'nonce-RANDOM_PER_REQUEST';
    img-src 'self' data: https:;
    font-src 'self';
    connect-src 'self' https://api.example.com;
    frame-ancestors 'none';
    base-uri 'self';
    form-action 'self';
    object-src 'none';
    upgrade-insecure-requests;
    report-uri /csp-report;
  ```
- `[High]` **`frame-ancestors`** — replaces `X-Frame-Options` for clickjacking defense. `'none'` for non-embeddable sites.
- `[Medium]` <a id="trusted-types"></a>**Trusted Types** — opt in via `Content-Security-Policy: require-trusted-types-for 'script'`. Blocks DOM XSS at the API surface (`innerHTML`, `eval`, etc.). Pair with a policy that sanitizes via DOMPurify.
- `[Low]` **`script-src 'strict-dynamic'`** — once your initial scripts are CSP-allowed, any scripts they create dynamically inherit trust. Reduces nonce plumbing.

## Cross-origin isolation (for `SharedArrayBuffer`, precise timers)

- `[High]` <a id="coop"></a>**COOP** — `Cross-Origin-Opener-Policy: same-origin`. Isolates your top-level browsing context.
- `[Medium]` <a id="coep"></a>**COEP** — `Cross-Origin-Embedder-Policy: require-corp`. Required (with COOP) to enable `crossOriginIsolated` and access `SharedArrayBuffer`. Be aware: `require-corp` breaks any cross-origin asset that doesn't return CORP/CORS headers.
- `[Medium]` <a id="corp"></a>**CORP** — `Cross-Origin-Resource-Policy: same-origin` on assets you don't want hotlinked.

## Permissions Policy

- `[Medium]` <a id="permissions-policy"></a>**Permissions-Policy** (replaces Feature-Policy). Disable powerful APIs you don't use:
  ```
  Permissions-Policy: camera=(), microphone=(), geolocation=(), interest-cohort=(), browsing-topics=()
  ```

## Subresource Integrity

- `[High]` <a id="sri"></a>**SRI for any third-party `<script>` or `<link rel="stylesheet">`**:
  ```html
  <script src="https://cdn.example.com/lib.js"
          integrity="sha384-…"
          crossorigin="anonymous"></script>
  ```
  Generate with `openssl dgst -sha384 -binary lib.js | openssl base64 -A`. CDN gets compromised → script doesn't load, doesn't run a poisoned version.

## Referrer policy

- `[Medium]` <a id="referrer-policy-header"></a>**Referrer-Policy** — `strict-origin-when-cross-origin` is a sane default. Sends full URL same-origin, only the origin cross-origin, nothing on downgrade.

## MIME / sniffing

- `[High]` <a id="x-content-type-options"></a>**`X-Content-Type-Options: nosniff`** — prevents browsers from re-interpreting `Content-Type`. One-line fix that closes a class of XSS.

## Cookies

- `[High]` <a id="cookie-hardening"></a>**Cookie hardening** — for every cookie:
  - `Secure` — HTTPS only.
  - `HttpOnly` — JS can't read it (CSRF / XSS hardening).
  - `SameSite=Lax` (default) or `SameSite=Strict` for state-changing flows.
  - `Path=/` and a sane `Max-Age`.
- `[Medium]` <a id="chips"></a>**`Partitioned` cookies (CHIPS)** — for embedded contexts (iframes), partition by top-level site. Required for cross-site cookies in 2026.

## CSRF

- `[High]` **CSRF tokens for state-changing requests** — synchronizer token in a hidden field or custom header. `SameSite=Strict` cookies cover most cases for same-origin SPAs but not all.
- `[Medium]` **Origin / Referer validation** server-side as defense in depth.

## XSS

- `[High]` **Escape every output boundary** — template engine auto-escaping ON; review every `innerHTML` / `dangerouslySetInnerHTML` / `v-html`. See `javascript.md` § eval.
- `[Medium]` **Sanitize rich-text inputs** with DOMPurify (server-side preferably). Whitelist tags; never blacklist.

## Bundles & secrets

- `[High]` **No secrets in client bundles** — anything in shipped JS is public. API keys with broad scopes leak. Use a backend proxy for sensitive APIs.
- `[Medium]` **Audit bundles for committed secrets** — `gitleaks` / `trufflehog` in CI.

## Legacy headers (still set, but understand they're not the primary defense)

- `[Medium]` **`X-Frame-Options: DENY`** or `SAMEORIGIN` — covered by CSP `frame-ancestors`, but set both for older clients.
- `[Low]` **`X-XSS-Protection`** — DEPRECATED. Either omit or set `0` to disable buggy browser XSS filters.

## Don't

- Don't ship CSP with `unsafe-inline` and `unsafe-eval` "to make it work." That defeats the point.
- Don't roll your own sanitizer. Use DOMPurify.
- Don't trust client-side validation alone. Always validate server-side.
- Don't include sensitive query params in URLs (they leak via Referer, server logs, analytics). See `privacy-and-cookies.md`.
- Don't hotlink third-party JS without SRI.
