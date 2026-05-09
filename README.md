# Frontend Checklist Skill

A Claude Code [skill](https://docs.anthropic.com/en/docs/claude-code/skills) for production-ready web frontends in 2026. Vanilla and framework-agnostic — focuses on rendered output (HTML, CSS, JS bundles, response headers, Core Web Vitals) regardless of stack.

## What it does

Two modes:

- **Reference mode (default)** — Claude consults the skill while reviewing or building frontend code. Ask "what's INP and how do I fix it?" or "review my index.html head" and the skill engages automatically.
- **Audit mode** — run `/frontend-audit` (optionally with a URL) to produce a prioritized findings report against the full checklist, with severity-tagged Pass / Fail / Unknown classifications and a "next actions" list.

## Coverage

16 topical reference files, all tagged with `[High]` / `[Medium]` / `[Low]` priorities:

| Topic | Highlights |
|---|---|
| Head & meta | Doctype, viewport, OG, Twitter Card, manifest, `color-scheme`, `theme-color` |
| HTML | Semantic landmarks, modern forms, `<dialog>` + `inert`, iframe hygiene |
| Webfonts | WOFF2, variable fonts, `font-display`, preload, `size-adjust` fallback metrics |
| CSS | Container queries, `:has()`, `@layer`, subgrid, view transitions, OKLCH, logical properties |
| Images | AVIF + `<picture>`, `srcset`/`sizes`, `fetchpriority` for LCP, `aspect-ratio` for CLS |
| JavaScript | ESM, TypeScript, tree-shaking, code-splitting, bundle budgets, no `eval` |
| Security | CSP3 with nonces, Trusted Types, COOP/COEP/CORP, SRI, Permissions-Policy, cookie hardening |
| Performance | HTTP/2-3, Brotli, `Cache-Control: immutable`, resource hints, render-blocking audit |
| Core Web Vitals | LCP, INP (replaces FID), CLS, TTFB, RUM via `web-vitals` |
| Accessibility | WCAG 2.2 AA, `prefers-reduced-motion`, `:focus-visible`, axe in CI |
| SEO | Per-route titles, JSON-LD, sitemap, hreflang, SSR for indexability |
| PWA | Manifest, service worker caching strategies, push permissions, install UX |
| Privacy & cookies | GDPR consent, GPC, `SameSite`, CHIPS, no PII in URLs |
| Dependencies | `npm audit`, lockfile, Renovate, SRI, supply-chain hygiene |
| Observability | `web-vitals` + Sentry, source maps, performance budgets in CI |
| Dark mode & motion | `prefers-color-scheme`, `color-scheme` CSS, `prefers-reduced-motion` |

## Install

Copy the `skill/` directory into your Claude Code skills folder:

```sh
# Project-local (only loads in this project)
cp -r skill .claude/skills/frontend-checklist

# Or user-global (loads in every project)
cp -r skill ~/.claude/skills/frontend-checklist
```

For the slash command, copy `commands/frontend-audit.md` into the matching `.claude/commands/` or `~/.claude/commands/`:

```sh
mkdir -p ~/.claude/commands
cp commands/frontend-audit.md ~/.claude/commands/
```

You can also clone this repo and point Claude Code at it directly without copying.

## Use

### As reference

Just ask Claude a frontend question while the skill is installed:

```
> What's INP and how do I fix a slow handler?
> Review my <head> for production-readiness.
> Is my CSP strict enough?
> What's the right cookie config for a GDPR site?
```

The skill auto-engages on frontend review / build / audit topics and pulls in the relevant reference file.

### As audit

```
/frontend-audit
/frontend-audit https://your-site.example
```

What it does:

1. Reads `package.json`, framework/bundler config, and a representative entry HTML.
2. If you pass a URL, runs `curl -sI` for response headers (HSTS, CSP, COOP, …) and `curl -s` for the rendered head.
3. If a `lighthouse*.json` exists in the working directory, parses it for LCP / INP / CLS / TTFB / score.
4. Evaluates every checklist item and produces a structured report — see `skill/assets/example-audit-output.md` for the format.

The skill is **read-only**. It reports findings; it never auto-fixes.

## Layout

```
skill/
├── SKILL.md                       # Entrypoint with progressive disclosure
├── references/                    # 16 per-topic reference files
├── assets/
│   ├── audit-prompt-template.md   # Output structure used in audit mode
│   └── example-audit-output.md    # Fully worked example
└── scripts/
    ├── collect-signals.sh         # Probes headers via curl, parses package.json
    └── parse-lighthouse.sh        # Extracts CWV from a Lighthouse JSON

commands/
└── frontend-audit.md              # /frontend-audit slash command
```

## Author

Reda SAKHI — `redasakhi@gmail.com`
