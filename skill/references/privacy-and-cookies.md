# Privacy & cookies

Treat user data as a liability. Collect less, store shorter, leak nothing.

## Consent

- `[High]` <a id="consent"></a>**Cookie consent where legally required** (GDPR, ePrivacy, CCPA/CPRA, LGPD, …). Strict rules:
  - **Block non-essential cookies and third-party scripts until consent is given.** Loading GA on page load and asking after is the violation everyone keeps making.
  - **Reject must be as easy as accept** — no dark-pattern "Customize..." buried under big Accept.
  - **Granular choices** — separate consent for analytics, marketing, personalization. Not one global toggle.
  - **Record the consent** server-side or in a verifiable cookie (consent string + timestamp + version).
- `[Medium]` **Don't show the banner where it's not required** — many regions don't need it; geographically-aware banners reduce friction.

## Global Privacy Control

- `[Medium]` <a id="gpc"></a>**Honor `Sec-GPC: 1`** — the GPC header signals user opt-out of sale/share of personal info (CCPA/CPRA enforced in California; growing adoption elsewhere). Treat as a do-not-sell signal: skip non-essential trackers.
- **Do-not-Track** (`DNT: 1`) is dead — Safari and Chrome dropped it. Don't rely on it.

## Cookie hygiene

- `[High]` <a id="cookie-flags"></a>**Every cookie:**
  - `Secure` (HTTPS only).
  - `HttpOnly` for anything not read by JS.
  - `SameSite=Lax` default; `SameSite=Strict` for sensitive flows; `SameSite=None; Secure` only for genuinely cross-site (e.g. embedded SSO).
- `[Medium]` <a id="chips"></a>**`Partitioned` (CHIPS)** — cookies for embedded contexts (third-party iframes) must be partitioned by top-level site:
  ```
  Set-Cookie: __Host-id=abc; Path=/; Secure; HttpOnly; SameSite=None; Partitioned
  ```
  Required for cross-site cookies that survive Chrome's third-party cookie phase-out.
- `[Low]` **`__Host-` prefix** — enforces `Secure`, `Path=/`, no `Domain` attribute. Defense against subdomain cookie injection.
- `[Low]` **Sane `Max-Age`** — auth cookies short (24h-7d), non-essential prefs longer. Don't set 10-year expiries by default.
- `[Low]` **Browser limits** — ≤ 4096 bytes per cookie, ≤ 50 per domain, ≤ 180 total. Don't shove giant JSON blobs into cookies; use `localStorage` or server-side sessions.

## Storage

- `[Low]` **`localStorage` for non-sensitive prefs** — synchronous, blocks main thread on big reads. Stick to small.
- `[Low]` **IndexedDB for larger client-side data** — async. Don't cache sensitive content there; it persists.
- `[Medium]` **Don't store tokens in `localStorage`** — XSS-readable. Use HttpOnly cookies for auth tokens.

## URLs

- `[High]` <a id="no-pii-in-urls"></a>**No PII in URLs or query strings** — emails, phone numbers, names, IDs that map to people. URLs leak via:
  - `Referer` header on outbound clicks.
  - Server logs.
  - Browser history.
  - Analytics tools.
  - Bookmarks shared casually.
- `[High]` **No tokens in URLs** — magic-link tokens excepted (single-use, short-TTL); they should redirect immediately to a token-free URL.

## Forms & inputs

- `[High]` **HTTPS for any form** — never submit PII over HTTP.
- `[Medium]` **`autocomplete` discipline** — `autocomplete="email"` good; `autocomplete="off"` on real fields breaks password managers and accessibility. Default to on.
- `[Medium]` **Don't log form contents** — the temptation to log "for debugging" is how PII ends up in CloudWatch.

## Third parties

- `[High]` **Audit every third-party request** — analytics, fonts, ads, CDNs, embeds. Each one sees the user's IP, User-Agent, Referer, and any cookies they set. Know what data leaves your origin.
- `[Medium]` **Self-host where possible** — fonts (see `webfonts.md`), critical libs. Reduces tracking surface.
- `[Medium]` **Privacy-respecting analytics** — Plausible, Fathom, Umami, simple-analytics, server-side analytics. Cookie-less, no consent required in most jurisdictions.

## Privacy policy & legal

- `[High]` **Privacy policy linked in footer** — what you collect, why, how long, who you share with, user rights. Update when the data flow changes, not just at launch.
- `[Medium]` **Imprint / contact information** — required in some jurisdictions (Germany's Impressumspflicht, etc.).
- `[Medium]` **Right to access / delete** — if subject to GDPR/CCPA, have a working process. Don't promise it in policy if you don't.

## Data minimization

- `[High]` **Collect only what you need** — fewer fields, shorter retention. The data you don't have can't leak.
- `[Medium]` **Anonymize / pseudonymize where possible** — hash IPs before logging, truncate to /24 for IPv4 if you only need geographic aggregates.

## Don't

- Don't fingerprint users to bypass cookie consent. Most jurisdictions consider fingerprinting "personal data" too.
- Don't ship third-party scripts before consent in EU traffic. That's the prevailing GDPR position and it's been enforced.
- Don't log full URLs to your error tracker without scrubbing query params for PII.
- Don't use `localStorage` as a persistent identifier for non-consenting users.
- Don't ask for permissions (geolocation, notifications) on first visit. Tie them to user intent.
