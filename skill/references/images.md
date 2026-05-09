# Images

Images are the single biggest perf lever and the #1 source of CLS. Get format, sizing, loading, and prioritization right.

## Format

- `[High]` <a id="avif-webp"></a>**AVIF + WebP via `<picture>`** — AVIF where supported (best compression), WebP for older browsers, JPEG/PNG fallback:
  ```html
  <picture>
    <source type="image/avif" srcset="hero.avif">
    <source type="image/webp" srcset="hero.webp">
    <img src="hero.jpg" alt="…" width="1200" height="630">
  </picture>
  ```
- `[Medium]` **Image CDN with format negotiation** — Cloudinary, imgix, Cloudflare Images, Vercel Image, Netlify Image CDN. Negotiate format from `Accept` header so you don't ship `<picture>` plumbing for every image.
- `[Medium]` **SVG for vector and icons** — optimize with SVGO. Inline small SVGs to avoid a request; `<img>` for medium ones; sprite sheets for large icon sets.
- `[Low]` **Inline SVG vs `<img>`** — inline gives you CSS control (`fill`, `stroke`, hover) but bloats HTML; `<img>` caches across pages but is opaque to CSS.

## Responsive sizing

- `[High]` <a id="srcset-and-sizes"></a>**`srcset` + `sizes`** — let the browser pick the right resolution:
  ```html
  <img
    src="photo-800.jpg"
    srcset="photo-400.jpg 400w, photo-800.jpg 800w, photo-1600.jpg 1600w"
    sizes="(min-width: 768px) 50vw, 100vw"
    width="800" height="600" alt="…">
  ```
- `[Medium]` **`<picture>` for art-direction** — different crops per breakpoint, not just resolution.
- `[High]` <a id="intrinsic-size"></a>**Intrinsic `width` and `height` attributes** — required to reserve layout space and prevent CLS. Use the source pixel dimensions; CSS will scale.
- `[High]` **`aspect-ratio` CSS** — when `width`/`height` doesn't fit (e.g. fluid hero), use `aspect-ratio: 16 / 9` to reserve space.

## Loading

- `[High]` **`loading="lazy"`** for below-the-fold images. Native, universal, no JS needed.
- `[Medium]` **`decoding="async"`** to keep image decode off the main thread.
- `[High]` <a id="lcp-image"></a>**The LCP image gets `fetchpriority="high"`** — and ideally a preload:
  ```html
  <link rel="preload" as="image" href="/hero.avif"
        imagesrcset="/hero-800.avif 800w, /hero-1600.avif 1600w"
        imagesizes="100vw" fetchpriority="high">
  ```
  Don't use `loading="lazy"` on the LCP image — it can defer it.
- `[Medium]` **`loading="eager"`** is the implicit default for `<img>` — only set it explicitly to override a lazy default in a framework component.

## Alt text

- `[High]` **Alt text on every `<img>`** — describe what the image conveys, not what it looks like. Decorative images get `alt=""` (still required), so AT skips them.
- `[Medium]` **No alt-text-as-caption** — alt is for screen readers; visible captions go in `<figcaption>`.

## Optimization

- `[High]` **Compress every raster** — ImageOptim, Squoosh, sharp, AVIF/WebP at quality 70-85 for photos. Aim for ≤ 200 KB per image, ≤ 100 KB for above-the-fold.
- `[Medium]` <a id="svg-optimization"></a>**SVG optimization** — SVGO with default plugins. Strip metadata, comments, default attrs. Minify on build.
- `[Low]` **Avoid `image-rendering: pixelated`** unless you're showing pixel art.
- `[Low]` **Don't use `background-image` for content images** — they're invisible to AT and to image lazy-loading.

## Don't

- Don't ship 4 KB hero PNGs as JPGs.
- Don't ship retina-2x as the only size; use `srcset` so 1x devices get the cheap file.
- Don't `loading="lazy"` the LCP image.
- Don't `width="100%"` in HTML attribute — that means 100 pixels. Use CSS for sizing, HTML attributes for intrinsic dimensions.
- Don't transform/scale images in the browser (server-side or CDN-side resize is what you want).
