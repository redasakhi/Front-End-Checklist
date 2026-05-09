# Audit prompt template

Internal template used by the `frontend-checklist` skill in audit mode to compose a findings report. The skill loads this when running `/frontend-audit` so output shape stays consistent across invocations.

## Inputs gathered

- `project.framework` — detected from `package.json` (vanilla, react, vue, svelte, astro, next, nuxt, sveltekit, solid, qwik, …) or `unknown`.
- `project.bundler` — detected from config files (vite, webpack, rollup, esbuild, turbopack, parcel, …) or `unknown`.
- `project.entryHtml` — path to the representative HTML inspected.
- `project.distPresent` — whether `dist/` or `build/` exists.
- `live.url` — present if the user supplied a URL.
- `live.headers` — `curl -sI` output, parsed.
- `live.html` — `curl -s` body, head section parsed.
- `lighthouse.metrics` — `{ lcp, inp, cls, ttfb, fcp, score }` if a Lighthouse JSON was parsed.
- `axe.violations` / `pa11y.issues` — if the corresponding JSON outputs are present.

## Classification rules

For each checklist item in `skill/references/*.md`:

- **Pass** — evidence exists and confirms the item is satisfied.
- **Fail** — evidence exists and confirms the item is violated.
- **Unknown** — no evidence available (e.g. CSP check without live headers, INP check without RUM data). State explicitly what evidence is missing.
- **N/A** — item does not apply (e.g. webfonts checks for a project with system fonts only; PWA checks if no manifest is intended).

Never invent evidence. If a check requires data we don't have, mark Unknown — do not guess Pass.

## Report structure

```markdown
# Frontend audit — <project name or path>

_Date: <YYYY-MM-DD> · Framework: <detected> · Bundler: <detected>_
_Sources: <list of inputs used: package.json, dist/index.html, curl headers from <url>, lighthouse.json, …>_

## Executive summary

- **High-severity issues:** <n>
- **Medium-severity issues:** <n>
- **Low-severity issues:** <n>
- **Unknown / not enough evidence:** <n>

### Top 5 to fix first

1. `[High]` <one-line title> — <one-line remedy>
2. …

## Findings

### <Section name (matches reference file)>

- `[High]` **<Item name>** — Fail
  - Evidence: <one line>
  - Remedy: <one line, actionable>
  - See: `skill/references/<file>.md#<anchor>`
- `[Medium]` **<Item name>** — Unknown
  - Evidence: missing — <what to provide>
  - See: `skill/references/<file>.md#<anchor>`

(repeat per section; omit sections with no Fail/Unknown items)

## Suggested next actions

Prioritized, concrete steps:

1. <Action> — addresses <n> findings.
2. <Action> — addresses <n> findings.
…

## Not evaluated

Items that need data we don't have. To complete the audit, supply:

- `lighthouse.json` for Core Web Vitals (run `npx lighthouse <url> --output=json --output-path=./lighthouse.json`).
- `axe-results.json` for automated a11y violations.
- A live URL to probe response headers via `curl -sI`.
```

## Style guidance

- Brief. One-line evidence, one-line remedy. The user wants a punch list, not an essay.
- Severity tags as `[High]` / `[Medium]` / `[Low]` exactly — keep them greppable.
- Group findings under the same section heading as the reference file, in the same order as the reference index in `SKILL.md`.
- Always include the cross-reference link so the user can read more.
- Don't recommend fixes that contradict the project's stack. If `package.json` shows React, don't suggest `<Vue>` patterns.
- Don't auto-fix. Report only.
