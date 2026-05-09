# HTML

Semantic, valid, accessible markup. Ship the right element for the job — `div` and `span` are the last resort, not the default.

## Semantics

- `[High]` **Use semantic landmarks** — `<header>`, `<nav>`, `<main>`, `<aside>`, `<footer>`, `<article>`, `<section>`. Screen readers and assistive tech rely on them.
- `[High]` **Single `<main>` per page** — the primary content area. Skip-link should target it.
- `[Medium]` **Don't double-role semantic elements** — `<nav role="navigation">` is redundant. Roles are for non-semantic elements that need a role.
- `[High]` **Heading order** — one `<h1>` per page (the page title), no skipped levels (don't jump `<h1>` → `<h3>`).

## Validation & lint

- `[Medium]` **W3C valid** — run the markup through https://validator.w3.org or `html-validate` in CI. Many a11y / SEO bugs are upstream HTML errors.
- `[Low]` **HTML lint in CI** — `html-validate` or `htmlhint` for project-specific rules.

## Forms

- `[High]` **Every input has a `<label>`** — explicit (`for`/`id`) or wrapping. `aria-label` only when a visible label is impossible.
- `[High]` **Right `<input type>`** — `email`, `tel`, `url`, `number`, `date`, `search`, `password`. Drives mobile keyboards, validation, autofill.
- `[Medium]` **`autocomplete`** — set tokens like `email`, `name`, `tel`, `cc-number`, `current-password`, `one-time-code`. Critical for password managers and accessibility.
- `[Medium]` **`inputmode`** — `numeric`, `decimal`, `tel` to refine the on-screen keyboard for `<input type="text">`-style fields.
- `[Medium]` **`enterkeyhint`** — `search`, `send`, `go`, `done` to label the mobile Enter key.
- `[Medium]` **`required` + `aria-describedby`** — pair native validation with a visible error message linked by id.
- `[High]` **No password fields without `type="password"`** — and never `autocomplete="off"` on real passwords (it breaks managers).

## Modals & dialogs

- `[Medium]` <a id="dialog-and-inert"></a>**Use `<dialog>` for modals** — it gets focus management, Escape-to-close, and `::backdrop` for free. Use `showModal()` not `show()` for blocking modals.
- `[Medium]` **`inert` for stuff behind a modal** — apply to background content so AT and tab order skip it.

## Iframes & embeds

- `[Medium]` **`loading="lazy"` on off-screen iframes** — same native lazy-load as images.
- `[High]` **`title` on every iframe** — required for a11y. Describes the embedded content.
- `[High]` **`sandbox` for untrusted embeds** — restrict capabilities; only re-enable what you need.
- `[Medium]` **`<a target="_blank">` always paired with `rel="noopener"`** — prevents the new tab from manipulating `window.opener`. Modern browsers default to `noopener` but be explicit. Add `noreferrer` if you also want to strip the Referer.

## Pictures, video, audio

- `[High]` **`<picture>` for art-direction or format negotiation** — see `images.md`. Plain `<img>` is fine when neither is needed.
- `[High]` **`<video>`/`<audio>`** — include `<track kind="captions">` for any non-decorative media. Use `preload="metadata"` (or `none` for off-screen) to avoid surprise downloads.
- `[Medium]` **`poster` attribute on `<video>`** — gives a stable LCP candidate before playback.

## Misc

- `[Medium]` **404 and 500 pages** — branded, useful, server-side (return correct status codes).
- `[Low]` **`<details>` / `<summary>`** — for accordions; native, accessible, no JS needed.
- `[Low]` **Avoid `<br>` for spacing** — that's CSS's job.
- `[Low]` **Avoid `<table>` for layout** — only for tabular data.

## What NOT to ship

- Generic `<div onclick>` — use `<button>`. Buttons are focusable, keyboard-activatable, screen-reader-announced.
- Modernizr-style feature detection for things every modern browser supports (e.g. flexbox, grid, ES modules).
- "Best viewed in Chrome" splash. Test in Firefox and Safari before launch.
