# Accessibility

WCAG 2.2 AA is the legal/practical bar in 2026. Most violations are mechanical and catchable by automated tests; the rest need human review.

## Targets

- `[High]` **WCAG 2.2 AA** — including the new SCs since 2.1: focus-not-obscured, target size (24×24 minimum), dragging movements (alternative for non-pointer users), accessible authentication (no cognitive function tests like CAPTCHA-only).

## Color & contrast

- `[High]` <a id="contrast"></a>**Contrast** — body text 4.5:1, large text (≥ 18 pt or 14 pt bold) 3:1. UI components and graphical objects 3:1.
- `[Medium]` **Don't rely on color alone** — pair color with icon, label, or pattern. Red error text needs an icon for color-blind users.
- `[Medium]` **Test in dark mode too** — contrast ratios change. See `dark-mode-and-motion.md`.

## Structure

- `[High]` **Heading order** — single `<h1>`, no skipped levels. Headings communicate page structure to screen reader users.
- `[High]` **Landmarks** — `<header>`, `<nav>`, `<main>`, `<aside>`, `<footer>`. AT users navigate by landmark.
- `[Medium]` <a id="skip-link"></a>**Skip link** — first focusable element, jumps to `<main>`:
  ```html
  <a href="#main" class="skip-link">Skip to content</a>
  ```
  Visible on focus.

## Forms

- `[High]` **Every input has a label** — explicit `<label for>` or wrapping. `aria-label` only when no visible label is possible.
- `[High]` **Error messages programmatically associated** — `aria-describedby` linking input to its error message id. `aria-invalid="true"` on the field.
- `[Medium]` **Group related fields** with `<fieldset>` and `<legend>`.
- `[Medium]` **`autocomplete` tokens** — see `html.md` § forms.

## Focus

- `[High]` <a id="focus-visible"></a>**`:focus-visible` for visible focus rings** — preferred over `:focus`. Shows the ring for keyboard nav, hides it for mouse:
  ```css
  :focus { outline: none; }
  :focus-visible { outline: 2px solid var(--focus); outline-offset: 2px; }
  ```
- `[High]` **Visible, high-contrast focus indicator** — minimum 3:1 contrast against adjacent colors. Don't remove it; restyle it.
- `[High]` **Focus trap modals** — `<dialog>` does this for free. Custom modals must trap Tab/Shift+Tab inside and restore focus to the trigger on close.
- `[High]` **Don't move focus unexpectedly** — autofocus only when it's the user's clear intent (search field on a search page).

## Keyboard

- `[High]` **Every interactive element keyboard-operable** — Tab to reach, Enter/Space to activate. `<button>` and `<a>` get this for free; custom widgets need work.
- `[High]` **No keyboard traps** — user can always Tab out.
- `[Medium]` **Logical tab order** — usually DOM order. Avoid `tabindex` > 0 (creates an unmaintainable parallel order).
- `[Low]` **`tabindex="-1"`** for elements you want to focus programmatically but not in tab order.

## ARIA

- `[High]` **Use semantic HTML first** — `<button>`, `<a href>`, `<details>`, `<dialog>` come accessible. Reach for ARIA only when no semantic option exists.
- `[Medium]` <a id="aria-live"></a>**`aria-live` regions for dynamic content** — `aria-live="polite"` for non-urgent announcements (results loaded, item added to cart). `aria-live="assertive"` only for genuinely interrupting messages (errors, critical alerts).
- `[Medium]` **`aria-current="page"`** for the current item in nav.
- `[High]` **No conflicting roles** — don't `role="button"` a `<button>`. Don't `role="navigation"` a `<nav>`. The implicit role is correct.
- `[Medium]` **Always pair `aria-expanded` with the trigger that controls it** — for disclosure widgets, dropdowns.

## Motion

- `[High]` <a id="reduced-motion"></a>**Honor `prefers-reduced-motion`** on every animation, transition, parallax, auto-play, scroll behavior:
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
  See `dark-mode-and-motion.md`.

## Media

- `[High]` **Captions for video** — `<track kind="captions" src="…" srclang="en" label="English">`.
- `[Medium]` **Transcripts for audio-only** content.
- `[High]` **Don't autoplay sound** — infringes WCAG 1.4.2; also broken UX.

## Target size (WCAG 2.2)

- `[High]` **Touch targets ≥ 24×24 CSS px** — buttons, links, controls. `padding` is an easy fix; visual size can be smaller if hit area meets the minimum.

## Lang & i18n

- `[High]` **`<html lang="…">`** — see `head-and-meta.md`.
- `[Low]` **`lang` on inline foreign-language phrases** — `<span lang="fr">tête-à-tête</span>` so screen readers pronounce it correctly.

## Automated testing

- `[High]` <a id="automated-testing"></a>**Run axe in CI** — `@axe-core/playwright` or `@axe-core/cli`:
  ```js
  import { test } from "@playwright/test";
  import AxeBuilder from "@axe-core/playwright";
  test("home is a11y-clean", async ({ page }) => {
    await page.goto("/");
    const r = await new AxeBuilder({ page }).analyze();
    if (r.violations.length) throw new Error(JSON.stringify(r.violations, null, 2));
  });
  ```
- `[Medium]` **pa11y for sitewide crawls** — `pa11y-ci` against a sitemap of routes.
- `[Medium]` **Lighthouse a11y audit** — overlap with axe but catches some additional things.

## Manual testing

- `[Medium]` **Keyboard-only smoke test** — unplug the mouse, navigate the whole site. Tab order, focus visibility, keyboard activation.
- `[Medium]` **Screen reader smoke test** — VoiceOver (macOS/iOS), NVDA (Windows), TalkBack (Android). Listen to your home + a key flow.
- `[Low]` **Zoom to 200%** — text must reflow without horizontal scrolling (WCAG 1.4.10).
- `[Low]` **High-contrast OS mode** — test in Windows High Contrast or macOS Increase Contrast.

## Don't

- Don't rely on automated tests alone — they catch ~30-40% of issues.
- Don't `tabindex="0"` a `<div>` to fake a button. Use `<button>`.
- Don't `aria-hidden="true"` interactive content. AT users still need it.
- Don't ship "accessibility overlay" widgets (UserWay, AccessiBe). They don't fix the underlying issues and have been the subject of lawsuits.
- Don't write alt text for decorative images. `alt=""` is correct.
