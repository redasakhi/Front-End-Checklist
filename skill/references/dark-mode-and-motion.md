# Dark mode & motion preferences

Two media queries that, ignored, ruin the experience for a lot of people. Both are cheap to support.

## `prefers-color-scheme`

- `[Medium]` <a id="prefers-color-scheme"></a>**Support `light` / `dark` / auto** — auto follows the OS. Pattern:
  ```css
  :root {
    --bg: white;
    --fg: #111;
  }
  @media (prefers-color-scheme: dark) {
    :root {
      --bg: #0b0b0b;
      --fg: #eaeaea;
    }
  }
  body { background: var(--bg); color: var(--fg); }
  ```
- `[Medium]` **Manual override** — store the user's choice in `localStorage`, apply via `<html data-theme="dark">` or `<html class="dark">`. Default to "auto" (no class) so OS pref wins.
  ```js
  const saved = localStorage.getItem("theme");
  if (saved) document.documentElement.dataset.theme = saved;
  ```
- `[Medium]` <a id="color-scheme-css"></a>**`color-scheme` CSS property** — tells the UA to render native form controls and scrollbars in the right scheme:
  ```css
  :root { color-scheme: light dark; }
  ```
  Without it, you get a dark page with white form controls.
- `[Low]` **Per-scheme `theme-color`** — see `head-and-meta.md`:
  ```html
  <meta name="theme-color" content="#ffffff" media="(prefers-color-scheme: light)">
  <meta name="theme-color" content="#0b0b0b" media="(prefers-color-scheme: dark)">
  ```

## Token discipline

- `[Medium]` <a id="theme-tokens"></a>**Theme via custom properties only** — every color, surface, border, shadow defined as a token at `:root`, overridden under `[data-theme="dark"]` and `@media (prefers-color-scheme: dark)`. Components reference tokens, never raw hex.
- `[Medium]` **Don't override per component** — once you start writing component-level dark mode CSS, the token system is broken. Fix the token, not the component.
- `[Low]` **Test contrast in both schemes** — a dark-mode page can pass contrast in light and fail in dark. Run axe in both.

## Images & media in dark mode

- `[Low]` **`prefers-color-scheme` for images** — `<picture>` with `<source media="(prefers-color-scheme: dark)" srcset="hero-dark.avif">`.
- `[Low]` **Slightly desaturate images in dark mode** — pure-saturated images on a dark background hurt eyes. `filter: brightness(0.9) contrast(0.9)` is enough.
- `[Low]` **Inline SVG with `currentColor`** — automatically adapts when text color changes.

## `prefers-reduced-motion`

- `[High]` <a id="prefers-reduced-motion"></a>**Honor on every animation, transition, parallax, scroll behavior, autoplay**. Vestibular disorders, ADHD, motion sickness — this isn't aesthetic preference, it's accessibility.
  ```css
  @media (prefers-reduced-motion: reduce) {
    *, *::before, *::after {
      animation-duration: 0.01ms !important;
      animation-iteration-count: 1 !important;
      transition-duration: 0.01ms !important;
      scroll-behavior: auto !important;
    }
  }
  ```
- `[Medium]` **Or guard motion explicitly:**
  ```css
  @media (prefers-reduced-motion: no-preference) {
    .hero { animation: fade-in 600ms ease-out; }
  }
  ```
- `[High]` **JS-driven motion** — check the same media query before kicking off animations:
  ```js
  const prefersReduced = matchMedia("(prefers-reduced-motion: reduce)").matches;
  if (!prefersReduced) startCarousel();
  ```
- `[High]` **No autoplaying video / motion in carousels** under `reduce`. Show static slides; require user click to advance.
- `[Medium]` **Respect on view transitions** — `@view-transition` and `View Transitions API` should be no-op under reduce.

## `prefers-contrast`

- `[Low]` <a id="prefers-contrast"></a>**Optional bump to higher contrast** — for users with `prefers-contrast: more`, increase border weight, raise contrast on muted text. WCAG AA at minimum even without this.

## `prefers-reduced-data`

- `[Low]` <a id="prefers-reduced-data"></a>**Skip non-essential media on `reduce`** — autoplay video, decorative animations, large hero images. Newer signal; not universally supported but easy to feature-detect.

## Forced colors (Windows High Contrast)

- `[Low]` **`forced-colors: active`** — Windows High Contrast Mode replaces your colors with system colors. Don't fight it; use `system-color` keywords (`Canvas`, `CanvasText`, `LinkText`, `ButtonFace`, `ButtonText`) for critical UI:
  ```css
  @media (forced-colors: active) {
    button { border: 1px solid ButtonText; }
  }
  ```

## Testing

- `[Medium]` **Toggle OS-level color scheme** before launch — macOS System Settings > Appearance, Windows Settings > Personalization > Colors, iOS/Android Display.
- `[Medium]` **Toggle reduce-motion at the OS** and click around the site. Carousels, modals, page transitions, scroll-snapping — all should be calm.
- `[Low]` **DevTools emulation** — Chrome DevTools > Rendering panel emulates `prefers-color-scheme`, `prefers-reduced-motion`, `prefers-contrast`, `forced-colors`. Faster iteration than OS toggles.

## Don't

- Don't ship a "dark mode" that's just inverted colors. It's nausea-inducing and breaks images.
- Don't forget `color-scheme` — your form controls will look wrong without it.
- Don't disable user preference with JS-only theme toggles that don't read the media query first.
- Don't assume motion is purely aesthetic. For some users, motion = pain.
- Don't animate things "to delight" without a `prefers-reduced-motion` guard.
