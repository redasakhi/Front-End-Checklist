# Core Web Vitals

The three metrics Google uses to rank you and the two adjacent ones you need to track. Lab tools (Lighthouse) show you potential; field data (RUM, CrUX) shows reality.

## Thresholds (75th percentile, real users)

| Metric | Good | Needs work | Poor |
|---|---|---|---|
| **LCP** Largest Contentful Paint | ≤ 2.5 s | ≤ 4.0 s | > 4.0 s |
| **INP** Interaction to Next Paint | ≤ 200 ms | ≤ 500 ms | > 500 ms |
| **CLS** Cumulative Layout Shift | ≤ 0.1 | ≤ 0.25 | > 0.25 |
| **TTFB** Time to First Byte | ≤ 800 ms | ≤ 1.8 s | > 1.8 s |
| **FCP** First Contentful Paint | ≤ 1.8 s | ≤ 3.0 s | > 3.0 s |

Pass requires all three CWV (LCP / INP / CLS) at "Good" at the 75th percentile.

## LCP

- `[High]` <a id="lcp"></a>**LCP < 2.5s on mobile**. Identify the LCP element (often a hero image or a large heading) — DevTools Performance panel labels it.
- `[High]` **Preload the LCP image** with `fetchpriority="high"` — see `images.md` § lcp-image.
- `[High]` **Server TTFB low** — slow server = slow LCP. CDN-cache the HTML if possible. SSR responses < 200 ms server-time.
- `[High]` **No `loading="lazy"` on the LCP image** — it can defer it.
- `[Medium]` **Inline critical CSS** so the LCP isn't gated by an external stylesheet round-trip.
- `[Medium]` **Avoid client-side rendering for the LCP** — if your LCP is rendered by JS, you're paying download + parse + execute before paint. Use SSR/SSG.
- `[Low]` **Don't animate the LCP** — fade-in or transform delays the actual paint.

## INP (replaces FID since March 2024)

- `[High]` <a id="inp"></a>**INP < 200ms p75**. Measures responsiveness across the whole session — the slowest interaction wins.
- `[High]` **Break up long tasks** — anything > 50 ms blocks user input. Use `scheduler.yield()` (where supported) or `setTimeout(0)` to chunk:
  ```js
  async function processChunked(items) {
    for (const item of items) {
      doWork(item);
      if (typeof scheduler !== "undefined" && scheduler.yield) await scheduler.yield();
      else await new Promise(r => setTimeout(r, 0));
    }
  }
  ```
- `[High]` **Show feedback within one frame** — even if the work isn't done, render a loading state before doing the expensive thing.
- `[Medium]` **Move heavy compute to a Web Worker** — JSON parsing, big regex, image processing, crypto. Use Comlink for ergonomic message-passing.
- `[Medium]` **Debounce input handlers** — `input` events fire per keystroke. Don't run a full search on every one.
- `[Medium]` **Avoid forced sync layout** in event handlers — read all you need first, then write. Don't interleave reads/writes.
- `[Low]` **Audit `requestAnimationFrame` callbacks** — a 30 ms `rAF` on every frame chokes interactivity.

## CLS

- `[High]` <a id="cls"></a>**CLS < 0.1 p75**.
- `[High]` **`width` and `height` attributes on images/iframes** — see `images.md` § intrinsic-size.
- `[High]` **`aspect-ratio` CSS for fluid containers** — reserve space before the asset loads.
- `[High]` **No layout-injecting ads/banners above the fold** — they push content down. If you must, reserve space with `min-height`.
- `[High]` **Webfont fallback metric matching** — CLS on font swap can be eliminated with `size-adjust`. See `webfonts.md`.
- `[Medium]` **Avoid `position: absolute` with computed positions that arrive late** — set them in CSS, not via JS measurement post-paint.
- `[Medium]` **Skeleton loaders or `min-height` placeholders** for late-arriving content.

## TTFB & FCP

- `[Medium]` <a id="ttfb"></a>**TTFB < 800ms p75** — server / edge response time. Cache HTML at the edge, optimize DB queries, use a CDN.
- `[Medium]` **FCP < 1.8s p75** — first paint of *anything*. Usually moves with TTFB and critical CSS.

## Measurement

- `[Medium]` <a id="rum"></a>**RUM via the `web-vitals` library** — install `web-vitals`, report each metric to your analytics or a dedicated endpoint:
  ```js
  import { onLCP, onINP, onCLS, onTTFB, onFCP } from "web-vitals";
  onLCP(send); onINP(send); onCLS(send); onTTFB(send); onFCP(send);
  ```
  See `observability.md` for the receiving end.
- `[Medium]` **CrUX dashboard** — public field data for every URL Chrome users visit. Look at https://crux.compare to compare against competitors.
- `[Medium]` **Lighthouse CI in PRs** — lab numbers for regression detection. Lab and field will diverge — don't chase a 100 score, chase real-user numbers.
- `[Low]` **PageSpeed Insights** — combines lab (Lighthouse) and field (CrUX). Free, public, useful as a sanity check.

## Per-route, not just home

- `[Medium]` **Measure every important route** — homepage, listing, product detail, checkout. Don't tune the home and ignore the rest. Different routes hit different bottlenecks.

## Don't

- Don't optimize for Lighthouse score over real-user metrics. Field > lab.
- Don't `loading="lazy"` the LCP image.
- Don't cargo-cult preload tags. Each one competes with the LCP.
- Don't use `requestIdleCallback` for things the user is waiting on — it can be deferred indefinitely.
