# Dependencies & supply chain

A modern frontend ships hundreds of transitive dependencies. Each one is an attack surface. Pin, audit, lockfile, automate.

## Lockfiles

- `[High]` <a id="lockfile"></a>**Lockfile committed** — `package-lock.json`, `pnpm-lock.yaml`, or `yarn.lock`. Never `.gitignore` it. Without a lockfile, every `npm install` can pull a different transitive version.
- `[High]` **CI installs from lockfile** — `npm ci`, `pnpm install --frozen-lockfile`, `yarn install --frozen-lockfile`. Fails the build if lockfile is out of sync with `package.json`.
- `[Medium]` **Single package manager per repo** — pick one (pnpm preferred for monorepos and disk usage; npm for the path of least resistance). Conflicting lockfiles are a footgun.

## Audit

- `[High]` <a id="audit"></a>**`npm audit` / `pnpm audit` clean or triaged** — run in CI. Block PRs on new High/Critical vulnerabilities. Document accepted Mediums with a date and rationale.
- `[Medium]` **`npm audit fix` carefully** — `--force` upgrades majors, breaks things. Review the diff before merging.
- `[Medium]` **Snyk / Socket / OSV-Scanner / GitHub Advanced Security** — beyond the basic registry advisory database. Catches typosquats, malicious updates, license issues.

## Automation

- `[Medium]` <a id="renovate"></a>**Renovate or Dependabot enabled** — automated PRs for dependency updates. Group minor/patch into one weekly PR; majors as separate PRs for review.
- `[Medium]` **Auto-merge patch updates after CI passes** — only if your test suite is solid. Otherwise just queue for human review.

## Pinning

- `[Medium]` **Pin major versions** — `"react": "^18.0.0"` is fine; `"react": "*"` or `"react": "latest"` is not. Prefer `^` over `~` over `=` depending on trust.
- `[Medium]` **Pin everything in lockfile** — that's what lockfiles do. The `package.json` range is a hint; the lockfile is reality.
- `[Low]` **`engines` field** — declare Node version in `package.json` so contributors and CI agree:
  ```json
  { "engines": { "node": ">=20.0.0" } }
  ```

## Supply-chain hardening

- `[Medium]` <a id="postinstall"></a>**Watch out for `postinstall` scripts** — packages can run arbitrary code when installed. `npm install --ignore-scripts` for risky environments; review postinstalls in audit.
- `[Medium]` **Pin dev deps too** — they run on developer machines and CI runners with broad access. A poisoned dev dep is as bad as a poisoned runtime dep.
- `[Low]` **Avoid wildcard scope installs** — `npm install @suspicious-org/*` is rare but bad pattern.
- `[Low]` **`overrides` for transitive vulnerabilities** — when a direct dep won't bump:
  ```json
  { "overrides": { "lodash": "^4.17.21" } }
  ```

## Bundle hygiene

- `[Medium]` <a id="bundle-analyzer"></a>**Bundle analyzer reviewed** — `rollup-plugin-visualizer`, `source-map-explorer`, `vite-bundle-visualizer`. Surprises (moment.js full locales, lodash whole package, unused polyfills) often surface here.
- `[Medium]` **Tree-shaking verified** — see `javascript.md`. ESM-friendly libs (`lodash-es`, `date-fns`) tree-shake; CJS-only libs often don't.
- `[Low]` **Bundle phobia / Bundlejs** — check the cost of a candidate dep before adding it. https://bundlephobia.com.

## SRI

- `[High]` **SRI for any CDN-loaded asset** — see `security.md` § sri. Don't `<script src="https://cdn.example.com/lib.js">` without `integrity`.

## License compliance

- `[Low]` **`license-checker` or `license-compatibility-checker`** in CI — flags GPL/AGPL deps that may conflict with proprietary use, or unknown licenses that need legal review.
- `[Low]` **Don't use deps with no license** — they're technically all-rights-reserved.

## Provenance (newer)

- `[Low]` <a id="provenance"></a>**npm provenance / sigstore** — for libs you publish, generate provenance. For libs you consume, prefer ones that publish with provenance. Verifies the package was built from a specific git source by a specific CI job.

## Don't

- Don't `rm -rf node_modules && npm install` to "fix" something without understanding what changed.
- Don't `npm install` something just to try a snippet from a tutorial. It stays in your dep graph.
- Don't accept a Renovate PR that bumps 50 packages without a glance at the changelogs.
- Don't ship dev deps to production — `dependencies` vs `devDependencies` matters.
- Don't trust a green CI as a substitute for reading dep release notes on majors.
