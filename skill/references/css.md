# CSS

Modern CSS in 2026 can do most of what we used to need JavaScript or preprocessors for. Lean into the platform.

## Layout

- `[High]` **Mobile-first** — design for narrow first, expand with `min-width` media queries. Use `clamp()` for fluid sizing instead of stepped breakpoints where possible.
- `[Medium]` <a id="container-queries"></a>**Container queries** — `@container` to style components based on their parent's size, not the viewport. Critical for reusable component libraries.
  ```css
  .card-container { container-type: inline-size; }
  @container (min-width: 480px) { .card { display: grid; grid-template-columns: 1fr 2fr; } }
  ```
- `[Low]` **Subgrid** — `grid-template-columns: subgrid` lets nested grids inherit tracks from their parent. Solves long-standing "card grid alignment" pain.
- `[Medium]` **Flexbox vs Grid** — Grid for 2D layout (rows AND columns matter), Flexbox for 1D (a row OR a column).

## Modern selectors

- `[Low]` <a id="has-selector"></a>**`:has()`** — parent selector. `.card:has(img)` styles cards that contain an image. Replaces a lot of legacy JS class-toggling.
- `[Low]` **`:is()` / `:where()`** — group selectors and control specificity. `:where()` has 0 specificity, useful for resets and theme defaults.
- `[Low]` **`@scope`** — scope rules to a component without CSS-in-JS. Still nascent — check support before relying on it.

## Cascade & layers

- `[Medium]` <a id="layer"></a>**`@layer`** — declare cascade order explicitly. Tame third-party CSS by putting it in a low-priority layer:
  ```css
  @layer reset, theme, components, utilities;
  @layer reset { /* normalize / preflight */ }
  ```
- `[Medium]` **Avoid `!important`** — use layers and specificity discipline. `!important` is reserved for utility classes and overriding third-party styles you can't otherwise touch.

## Logical properties

- `[Medium]` <a id="logical-properties"></a>**Logical properties for spacing and sizing** — `margin-inline`, `padding-block`, `inset-inline-start`, `border-block-end`. RTL/LTR support comes free.
  ```css
  /* instead of margin-left: 16px; */
  margin-inline-start: 1rem;
  ```

## Color & theming

- `[Medium]` <a id="custom-properties"></a>**CSS custom properties for theming** — define design tokens at `:root` and reference them everywhere. Override at `[data-theme="dark"]` or under `@media (prefers-color-scheme: dark)`.
- `[Low]` **`color-mix()`** — generate variants without preprocessor color functions:
  ```css
  background: color-mix(in oklch, var(--brand) 80%, white);
  ```
- `[Low]` **OKLCH / wide-gamut color** — `color: oklch(70% 0.15 250)` for perceptually uniform color, optional `display-p3` for wider gamut on supporting hardware.
- `[Low]` **`accent-color`** — `accent-color: var(--brand)` styles native form controls (checkbox, radio, range, progress) without rebuilding them.

## Animations & view transitions

- `[Low]` <a id="view-transitions"></a>**View transitions** — `document.startViewTransition(() => …)` plus `view-transition-name: hero` for cross-route or list-item animations. Cheap, declarative, accessible.
- `[High]` **Honor `prefers-reduced-motion`** — wrap motion in `@media (prefers-reduced-motion: no-preference)` or zero out durations under `(prefers-reduced-motion: reduce)`. See `dark-mode-and-motion.md`.

## CSS nesting

- `[Low]` **Native CSS nesting** — Sass-style nesting works in plain CSS now. Don't go more than 2 levels deep — it gets unreadable fast.

## Build hygiene

- `[High]` <a id="minify-and-purge"></a>**Minify** — emit min'd CSS in production builds. Remove unused selectors with PurgeCSS / Tailwind's JIT / framework-specific tools.
- `[Medium]` **Autoprefixer or browserslist-driven prefixes** — implicit in any modern toolchain. Don't hand-author `-webkit-`/`-moz-` prefixes.
- `[Medium]` <a id="stylelint"></a>**stylelint in CI** — `stylelint-config-standard` plus `stylelint-order` for property-order discipline.
- `[Medium]` **No inline styles** — except critical above-the-fold CSS inlined in `<head>` for LCP. CSP `style-src` should not need `unsafe-inline`.

## Print

- `[Low]` **Print stylesheet** — `@media print` to hide nav, expand link URLs (`a[href]::after { content: " (" attr(href) ")"; }`), use serif fonts. Skip if the site has no print use case.

## RTL / i18n

- `[Medium]` **RTL-ready** — use logical properties, test with `<html dir="rtl">`. Validate icon directions (arrows, search-fields), text-align flips, padding side flips.

## What NOT to ship

- Vendor prefixes you hand-wrote (autoprefixer handles it).
- `clearfix` for floats (use flexbox/grid).
- `box-sizing: border-box` per element (set it in your reset on `*`).
- `position: absolute` for centering (use `display: grid; place-items: center`).
- ID selectors in production CSS (`#main { … }`) — too high specificity. Keep IDs for JS hooks.
