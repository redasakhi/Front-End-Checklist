# Head & meta

The `<head>` is the first ~14 KB the browser parses and decides everything from charset to which image to preload. Get it right.

## Document basics

- `[High]` **Doctype** — `<!doctype html>` on the very first line.
- `[High]` **Charset** — `<meta charset="utf-8">` first thing inside `<head>`.
- `[High]` **Viewport** — `<meta name="viewport" content="width=device-width, initial-scale=1">`. Don't disable user scaling (`user-scalable=no` and `maximum-scale=1` break a11y).
- `[High]` **`<html lang="…">`** — required for screen readers, browser hyphenation, locale-aware features.
- `[Medium]` **`<html dir="ltr|rtl">`** — set when content is in an RTL script or app supports both.

## Title and description

- `[High]` **`<title>`** — present on every page, unique per route, ≤ 60 chars (Google truncates around there).
- `[High]` **`<meta name="description">`** — unique per route, ≤ 155 chars. Don't keyword-stuff.
- `[Medium]` **Per-route titles in SPAs** — set them via your router or framework helmet equivalent. Don't ship one global title.

## Canonical & alternates

- `[High]` **`<link rel="canonical" href="…">`** — absolute URL, on every indexable page. Prevents duplicate-content and parameter-noise issues.
- `[Medium]` **`hreflang`** — for multi-locale sites: `<link rel="alternate" hreflang="en-US" href="…">` for each variant plus `x-default`.

## Open Graph & Twitter Card

- `[Medium]` **OG tags** — `og:title`, `og:description`, `og:image`, `og:url`, `og:type` at minimum.
- `[Low]` <a id="og-image-sizing"></a>**OG image sized 1.91:1** — recommended 1200×630, ≤ 5 MB. Validate via the social platform's debugger.
- `[Low]` **Twitter Card** — `<meta name="twitter:card" content="summary_large_image">` plus `twitter:title`, `twitter:description`, `twitter:image`.

## Favicons & icons

- `[Medium]` **Favicons** — at minimum a 32×32 PNG `<link rel="icon">`. SVG favicon as a progressive enhancement.
- `[Low]` **Apple touch icon** — `<link rel="apple-touch-icon" href="/apple-touch-icon.png">` (180×180).
- `[Medium]` **Maskable icons** — for PWA, ship 192×192 and 512×512 maskable PNGs in the manifest.

## Manifest (web app / PWA)

- `[Medium]` **Web app manifest** — `<link rel="manifest" href="/site.webmanifest">`. See `pwa.md` for required fields.

## Theme & color scheme

- `[Medium]` <a id="color-scheme"></a>**`<meta name="color-scheme" content="light dark">`** — tells the browser to render UA controls (form fields, scrollbars) appropriate for both themes. See `dark-mode-and-motion.md`.
- `[Low]` **`<meta name="theme-color">`** — set per scheme using `media`:
  ```html
  <meta name="theme-color" content="#ffffff" media="(prefers-color-scheme: light)">
  <meta name="theme-color" content="#0b0b0b" media="(prefers-color-scheme: dark)">
  ```

## Referrer policy

- `[Low]` <a id="referrer-policy"></a>**Referrer policy** — prefer the response header (see `security.md`), but a meta fallback works:
  ```html
  <meta name="referrer" content="strict-origin-when-cross-origin">
  ```

## Resource hints in `<head>`

- `[Medium]` **`preconnect`** — for critical third-party origins (CDN, fonts, analytics).
- `[Low]` **`dns-prefetch`** — fallback for older browsers / non-critical origins.
- `[Medium]` **`preload`** — fonts, critical CSS, LCP image. Use sparingly: every preload competes for bandwidth.
- See `performance.md` for full guidance on resource hints.

## What NOT to ship

- Don't include `<meta http-equiv="X-UA-Compatible">` — IE is dead.
- Don't include `<meta name="apple-mobile-web-app-capable">` for general sites — it's a PWA-era hack; use the manifest.
- Don't put `<title>` or `<meta description>` AFTER scripts/styles — they should be near the top of `<head>`.
- Don't ship an empty `<meta name="keywords">` — Google ignores it; harmless but noise.
