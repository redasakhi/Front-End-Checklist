# Webfonts

Webfonts are LCP poison if mishandled. Be ruthless about format, weight, swap behavior, and metrics.

## Format

- `[High]` **WOFF2 only** — every modern browser supports it. WOFF1, TTF, OTF, EOT have no place in production.
- `[High]` **Variable fonts when feasible** — one file covers many weights/widths/optical sizes. Often smaller than 2-3 static cuts.

## Weight budget

- `[Medium]` **Total webfont payload ≤ 150 KB compressed** — for a typical site with one variable font (or 2-3 static cuts) plus an italic.
- `[Medium]` **Subset by `unicode-range`** — split Latin / Latin-Ext / Cyrillic / Greek into separate `@font-face` blocks. Browsers download only the ranges actually used.
- `[Low]` **Subset further by glyph** — for icon fonts or display fonts where you know the exact characters used.

## `font-display`

- `[High]` **`font-display: swap`** — show fallback text immediately, swap to webfont when ready. No invisible text (FOIT) means no LCP delay.
- `[Low]` **`font-display: optional`** — for body fonts on slow connections; the browser may decide not to swap. Eliminates layout shift entirely at the cost of consistent typography.

```css
@font-face {
  font-family: "Inter";
  src: url("/fonts/Inter.woff2") format("woff2-variations");
  font-weight: 100 900;
  font-style: normal;
  font-display: swap;
}
```

## Preloading critical fonts

- `[Medium]` **Preload the first webfont rendered above the fold:**
  ```html
  <link rel="preload" as="font" type="font/woff2"
        href="/fonts/Inter.woff2" crossorigin>
  ```
  Mandatory `crossorigin` even for same-origin (font requests are CORS-flagged).
- `[Low]` **Don't preload secondary cuts** — italic, display weights for headings only — they don't gate LCP.

## Fallback metric matching

- `[Low]` **`size-adjust` / `ascent-override` / `descent-override` / `line-gap-override`** — make the system fallback occupy the same space as the webfont. Eliminates CLS on swap.
  ```css
  @font-face {
    font-family: "Inter Fallback";
    src: local("Arial");
    size-adjust: 107%;
    ascent-override: 90%;
    descent-override: 22%;
    line-gap-override: 0%;
  }
  body { font-family: "Inter", "Inter Fallback", system-ui, sans-serif; }
  ```
  Tools: https://screenspan.net/fallback , https://meowni.ca/font-style-matcher

## System font fallback

- `[Medium]` **Always declare a system fallback chain** — `system-ui, -apple-system, "Segoe UI", Roboto, sans-serif` for sans, `Georgia, "Times New Roman", serif` for serif, `ui-monospace, "Cascadia Code", "Source Code Pro", monospace` for mono.
- `[Low]` **System-font-only stack** — perfectly valid for many UIs. Zero font payload, instant render.

## Hosting

- `[Medium]` **Self-host fonts** — Google Fonts CSS forces a separate origin connection (`fonts.googleapis.com` for the CSS, `fonts.gstatic.com` for the file). Bundling the font with your origin saves a connection and avoids the privacy concerns. Tools like https://google-webfonts-helper.herokuapp.com generate self-hostable bundles.
- `[Medium]` **Privacy** — Google Fonts has been ruled GDPR-problematic in some EU jurisdictions. Self-hosting eliminates the issue.
- `[Low]` **Use a font CDN's WOFF2 directly** — if you must, use `<link rel="preconnect" crossorigin>` to the CDN host.

## Don't

- Don't load 5+ static cuts — switch to a variable font.
- Don't ship `font-display: block` (the default before `swap` was widely supported) — it causes invisible text up to 3s.
- Don't `@import` webfonts in CSS — that adds a serial round-trip. Use `<link rel="stylesheet">` or inline the `@font-face` rules.
- Don't preload more than 2 fonts. Each preload is a real network request that competes with critical resources.
