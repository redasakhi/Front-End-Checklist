---
name: frontend-checklist
description: Use when reviewing, auditing, or building production-ready frontend code (HTML, CSS, JS/TS, web performance, accessibility, security headers, SEO). Covers Core Web Vitals (LCP/INP/CLS), CSP3, WCAG 2.2, responsive images (AVIF), variable fonts, supply-chain hygiene, and observability. Invoke explicitly via `/frontend-audit` to run a full project audit; otherwise consulted as reference during frontend code review or implementation.
allowed-tools: Read, Glob, Grep, Bash(curl:*), Bash(cat:*), Bash(jq:*), Bash(node:*)
---

# Frontend Checklist (2026)

A pre-launch and code-review knowledge pack for production-grade web frontends. Vanilla / framework-agnostic — focused on rendered output (HTML, CSS, JS bundles, response headers, Core Web Vitals) regardless of stack.

## When to use

Engage this skill when the user is:

- Reviewing HTML, CSS, JS, or TS for production readiness.
- Asking about Core Web Vitals (LCP, INP, CLS, TTFB), web performance budgets, or Lighthouse scores.
- Asking about web security headers (CSP, HSTS, COOP, COEP, CORP, Permissions-Policy, SRI, Referrer-Policy).
- Asking about accessibility (WCAG 2.2, axe, pa11y, keyboard nav, screen readers, `prefers-reduced-motion`).
- Asking about responsive images (AVIF, `srcset`, `<picture>`, `fetchpriority`), webfonts (variable fonts, `font-display`), or CSS modernization (container queries, `:has()`, `@layer`, view transitions).
- Asking about SEO (meta tags, JSON-LD, sitemap, hreflang, SSR for indexability).
- Asking about PWA, dark mode, dependency security, observability, or cookie / privacy compliance.
- Asking "is this site production-ready?" / "pre-launch checklist" / "audit my frontend."

Do **not** engage for backend-only, devops, mobile-native, or non-web code.

## Two modes

### Reference mode (default)

The user asks a frontend question. Don't read every reference file — pick the ones whose topic matches the question, read those, and answer with cited checklist items including their `[High]` / `[Medium]` / `[Low]` priority.

### Audit mode

Triggered by the `/frontend-audit` slash command, or natural language like "audit my frontend", "pre-launch review", "production-readiness check". Follow the workflow in [§ Audit workflow](#audit-workflow) below.

## Reference index

| Topic | File |
|---|---|
| `<head>`, meta tags, OG, manifest, favicons | `references/head-and-meta.md` |
| Semantic HTML, forms, dialogs, iframes | `references/html.md` |
| Webfonts, variable fonts, `font-display` | `references/webfonts.md` |
| Modern CSS (container queries, `:has`, layers, view transitions) | `references/css.md` |
| Responsive images, AVIF, `srcset`, LCP image | `references/images.md` |
| ESM, TypeScript, bundling, code-splitting | `references/javascript.md` |
| HTTPS, CSP3, COOP/COEP, SRI, cookies | `references/security.md` |
| HTTP/2-3, Brotli, caching, preload, budgets | `references/performance.md` |
| LCP, INP, CLS, TTFB, RUM | `references/core-web-vitals.md` |
| WCAG 2.2, ARIA, keyboard, automated a11y in CI | `references/accessibility.md` |
| Titles, descriptions, sitemap, JSON-LD, SSR | `references/seo.md` |
| Manifest, service worker, install UX, push | `references/pwa.md` |
| GDPR, GPC, SameSite, CHIPS, no PII in URLs | `references/privacy-and-cookies.md` |
| `npm audit`, lockfiles, Renovate, SRI | `references/dependencies.md` |
| `web-vitals`, error tracking, source maps, perf budgets | `references/observability.md` |
| `prefers-color-scheme`, `prefers-reduced-motion` | `references/dark-mode-and-motion.md` |

## Severity legend

Every checklist item is tagged with one of:

- `[High]` — required for a production-grade launch. Omission causes user-facing breakage, accessibility failure, security risk, or significant regression.
- `[Medium]` — strongly recommended. Omission causes measurable degradation in UX, SEO, perf, or maintainability.
- `[Low]` — nice to have. Omission is acceptable for many projects.

Plain text only — no image badges, no network deps, greppable.

## Audit workflow

When invoked in audit mode:

1. **Discover the project** (read-only):
   - `Glob` for `package.json`, `vite.config.*`, `next.config.*`, `astro.config.*`, `webpack.config.*`, `rollup.config.*`, `index.html`, `public/`, `dist/`, `build/`, `lighthouse*.json`, `axe-results*.json`, `pa11y*.json`.
   - Read `package.json` to identify framework, bundler, declared deps.
   - Read one representative entry HTML (or an SSR/SSG output if present in `dist/` / `build/`).
2. **Optional live signals** — if the user supplies a URL:
   - `curl -sI <url>` to capture response headers (HSTS, CSP, COOP, COEP, Permissions-Policy, X-Content-Type-Options, Referrer-Policy, Cache-Control, Content-Encoding).
   - `curl -s <url>` to inspect rendered head.
   - `scripts/collect-signals.sh <url>` is a convenience wrapper.
3. **Optional Lighthouse parsing** — if a `lighthouse*.json` exists in cwd:
   - Run `scripts/parse-lighthouse.sh <file>` to extract LCP, INP, CLS, TTFB, performance score.
4. **Evaluate per section** — for each `references/*.md`, classify each item against gathered evidence as **Pass / Fail / Unknown / N/A**. Don't fabricate signals; mark Unknown when evidence is missing.
5. **Output a report** — single markdown document, structured exactly like `assets/example-audit-output.md`:
   - Executive summary: counts by severity, top 5 high-severity issues.
   - One section per reference file. List only Fail and Unknown items, sorted by severity.
   - Each finding: severity tag, one-line evidence, one-line remedy, link to the reference file anchor.
   - Final "Suggested next actions" — prioritized, concrete.

The skill is self-contained: it does **not** shell out to `lighthouse`, `axe`, or `pa11y`. It documents how the user can run those externally and parses their JSON output if present.

See `assets/audit-prompt-template.md` for the structure Claude uses to compose the report and `assets/example-audit-output.md` for a fully-worked example.
