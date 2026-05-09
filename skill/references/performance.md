# Performance

The non-Core-Web-Vitals side of perf: protocols, compression, caching, resource hints, budgets. Pair with `core-web-vitals.md`.

## Protocols

- `[High]` **HTTP/2 or HTTP/3** — multiplexing kills HTTP/1's head-of-line blocking. HTTP/3 (QUIC) is the new default for CDNs that support it. Verify with `curl -I --http3 https://yoursite`.
- `[Medium]` **TLS 1.3** — faster handshake than 1.2, with 0-RTT for repeat connections. Most CDNs default to 1.3.

## Compression

- `[High]` <a id="compression"></a>**Brotli (`br`) for text assets** — HTML, CSS, JS, JSON, SVG. Smaller than gzip at similar CPU cost. Verify `Content-Encoding: br` on responses.
- `[Medium]` **Static Brotli precompression** — precompile assets at build time (`brotli -q 11`), serve them at runtime. Saves CPU and gets max compression ratios.
- `[Low]` **Don't compress already-compressed formats** — JPEG, PNG, WebP, AVIF, MP4, WOFF2. They're already compressed; gzip/Brotli adds overhead.

## Caching

- `[High]` <a id="cache-control"></a>**`Cache-Control: public, max-age=31536000, immutable`** — for fingerprinted/hashed static assets. They're identified by content hash, so they never need revalidation.
- `[High]` **`Cache-Control: no-cache` for HTML** — clients revalidate; cheap with ETags. Don't `max-age=0` (still asks every load); do `no-cache` (revalidate via 304).
- `[Medium]` **CDN edge cache for static assets** — long TTLs at the edge, short TTLs at the origin. Purge on deploy.
- `[Medium]` **`stale-while-revalidate`** — serve stale, revalidate in the background. Good for API responses that can tolerate slight staleness.

## Resource hints

- `[Medium]` **`<link rel="preconnect" crossorigin>`** — for critical third-party origins (CDN, fonts.gstatic.com, analytics). Each preconnect costs a connection — 2-3 max.
- `[Low]` **`<link rel="dns-prefetch">`** — fallback for non-critical origins; just resolves DNS, doesn't open a connection.
- `[Medium]` **`<link rel="preload">`** — fonts (critical only), critical CSS, LCP image. Don't preload everything; each preload competes with critical resources.
- `[Medium]` **Prefetch likely next pages** — `<link rel="prefetch" href="/likely-next-route">` during idle. Be careful: ad blockers and metered connections punish over-prefetching.

## Budgets

- `[High]` **Per-route weight budget**:
  - HTML: ≤ 30 KB gz.
  - CSS: ≤ 75 KB gz total.
  - JS: ≤ 200 KB gz client-side per route (warn), ≤ 350 KB hard ceiling.
  - Webfonts: ≤ 150 KB compressed total. See `webfonts.md`.
  - Images per page: ≤ 1 MB above the fold.
- `[Medium]` **Enforce in CI** — `size-limit`, `bundlewatch`, or Lighthouse CI budgets. Block PRs that exceed.

## Render-blocking resources

- `[High]` **No render-blocking 3rd-party scripts above the fold** — analytics, A/B testing, chat widgets all go behind `defer` or after window load. Use `<script async>` only when execution order doesn't matter.
- `[Medium]` **Inline critical CSS** in `<head>` (≤ 14 KB), load the rest async:
  ```html
  <link rel="preload" href="/main.css" as="style" onload="this.rel='stylesheet'">
  <noscript><link rel="stylesheet" href="/main.css"></noscript>
  ```

## Lazy / on-demand

- `[High]` **`loading="lazy"` for off-screen images and iframes** — see `images.md` and `html.md`.
- `[Medium]` **`content-visibility: auto`** for off-screen sections — browser skips rendering until they scroll into view. Big perf win for long pages.
- `[Medium]` **Defer non-critical JS** — analytics, chat, third-party widgets after `load` event or user interaction.

## HTML hygiene

- `[Low]` **HTML minification** — strip whitespace and comments in production. Marginal compared to Brotli, but free.
- `[Medium]` **Server-rendered HTML for first paint** — even SPAs should ship a meaningful first paint, not a blank `<div id="root"></div>`. SSR / SSG / ISR.

## Third-party scripts

- `[High]` **Audit every third-party tag** — each one is a render-blocking, layout-shifting, privacy-impacting risk. Use a tag manager only if you genuinely need one; its own JS is heavy.
- `[Medium]` **Self-host where possible** — fonts (see `webfonts.md`), analytics, common JS libs. Reduces preconnects, removes a privacy vector.
- `[Medium]` **Facade pattern for heavy embeds** — YouTube embed → click-to-load static thumbnail; chat widget → button that loads on click. Saves megabytes for users who never engage.

## Don't

- Don't preload more than 2-3 things. Each preload is a real network request that competes with everything else.
- Don't `async` JS that other scripts depend on (race condition).
- Don't ship sourcemaps inline (`//# sourceMappingURL=data:…`) in production — bloats payload.
- Don't gzip `.png`/`.jpg`/`.woff2`. They're already compressed.
- Don't ship multi-megabyte heroes "because it's the homepage."
