---
description: Run a 2026 frontend production-readiness audit on the current project
argument-hint: [optional URL to probe live response headers]
---

Invoke the `frontend-checklist` skill in **audit mode**. Follow the workflow in `skill/SKILL.md` § Audit workflow:

1. Discover the project via `Glob` and read `package.json` + a representative entry HTML.
2. If `$ARGUMENTS` contains a URL, probe it with `curl -sI` for response headers and `curl -s` for the rendered head.
3. If `lighthouse*.json` exists in the working directory, parse it via `skill/scripts/parse-lighthouse.sh`.
4. Evaluate each `skill/references/*.md` against gathered signals — classify Pass / Fail / Unknown / N/A.
5. Produce a structured findings report matching the format in `skill/assets/example-audit-output.md`: executive summary, per-section Fail/Unknown items sorted by severity, and a prioritized "Suggested next actions" list.

Do not auto-fix. Report only — the user decides what to act on.
