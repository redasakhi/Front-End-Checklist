# JavaScript

Modern, modular, typed, lean. Don't ship megabundles. Don't transpile to ES5 for evergreen browsers.

## Modules

- `[High]` <a id="esm"></a>**Native ESM (`<script type="module">`)** — use ES modules everywhere, top-level await is supported. Drop UMD/CommonJS in browser code.
- `[Medium]` **`<script defer>` for classic scripts** — parse in parallel, execute after HTML. `async` for independent third-party scripts (analytics).
- `[Medium]` **No inline `<script>`** in HTML — except a tiny boot script when CSP nonces aren't available. Inline scripts are blocked by a strict CSP.
- `[Low]` **Drop `<script nomodule>`** — every browser shipping in 2026 supports modules. The `module/nomodule` pattern is legacy.

## Types

- `[Medium]` <a id="typescript"></a>**TypeScript (or JSDoc types)** — even on a small project, types catch a class of bugs static analysis otherwise misses. Run `tsc --noEmit` in CI.
- `[Medium]` **`strict: true`** in `tsconfig.json` — `strictNullChecks` and `noImplicitAny` are non-negotiable.
- `[Low]` **Type-only imports** — `import type { Foo }` to keep them out of runtime bundles.

## Syntax targets

- `[Medium]` **Target ES2022+** — for evergreen browsers (Chrome/Edge ≥ 94, Firefox ≥ 93, Safari ≥ 15). Don't transpile to ES5 unless you actually have IE11 / old-Android users in your analytics.
- `[Low]` **Compile down only what your `browserslist` targets** — let the bundler decide; don't hand-pick syntax.

## Bundling & code-splitting

- `[High]` <a id="bundle-budget"></a>**Per-route bundle budget** — soft warn at 200 KB gz of JS, hard fail at 350 KB gz. Larger pages need a strong reason. Use `size-limit` or `bundlewatch` in CI.
- `[High]` <a id="tree-shaking"></a>**Tree-shaking verified** — no full-package imports of large libs. `import { debounce } from "lodash-es"`, never `import _ from "lodash"`. Audit with `rollup-plugin-visualizer` or `source-map-explorer`.
- `[Medium]` <a id="code-splitting"></a>**Code-split per route** — dynamic `import()` for routes the user may never visit:
  ```js
  const route = await import("./routes/checkout.js");
  ```
- `[Low]` **Prefetch likely next routes** during idle time (`requestIdleCallback`, or framework helpers).

## DOM APIs

- `[Medium]` **`addEventListener`, not `on*` HTML attributes** — they're CSP-incompatible (`unsafe-inline`) and harder to clean up.
- `[Low]` <a id="abort-controller"></a>**`AbortController` for listener cleanup** — pass `signal` to `addEventListener({ signal })`, abort the controller on unmount. Single-line cleanup for many listeners.
- `[Medium]` **Avoid forced sync layout** — don't read `offsetWidth`/`getBoundingClientRect()` then write style in the same handler. Batch reads then writes.

## Long tasks (INP)

- `[High]` **No long tasks > 50 ms** on user input — see `core-web-vitals.md` § INP. Break work with `scheduler.yield()` or `setTimeout(0)`.
- `[Medium]` **Web Workers** for heavy compute — JSON parsing of huge payloads, image processing, regex on big strings. Use Comlink for ergonomic message-passing.

## Security

- `[High]` <a id="no-eval"></a>**No `eval` / `new Function()`** — banned by a strict CSP, vector for DOM XSS. Use `JSON.parse` for JSON, never `eval`.
- `[High]` **Sanitize HTML insertions** — `el.textContent = …`, never `el.innerHTML = userInput`. If you must inject HTML, use `DOMPurify` or Trusted Types (see `security.md`).
- `[Medium]` **Don't store secrets in client bundles** — anything in JS shipped to the browser is public. API keys with `Authorization: Bearer …` baked in are leaked.

## Tooling

- `[High]` <a id="eslint"></a>**ESLint in CI** — `@eslint/js` recommended config, plus framework plugin. Fail PRs with new errors.
- `[High]` **Type-check in CI** — `tsc --noEmit`.
- `[Medium]` **Format with Prettier or Biome** — enforce on commit. Don't lint-debate over style.
- `[High]` **Source maps generated, but private** — upload to your error tracker, do not serve publicly. See `observability.md`.
- `[High]` **Minify** in production builds — esbuild/swc/terser.

## Polyfills

- `[Low]` **Lean on `core-js` only when measured** — most ES features are universally supported. Conditional polyfills via `<script type="module">` + dynamic `import()` based on feature detection, not blanket transpilation.

## What NOT to ship

- jQuery, on a fresh project. Native APIs cover almost everything.
- A CDN copy of Lodash. Use `lodash-es` with named imports.
- `var` — `const` / `let` only.
- `==` — `===` only.
- Polyfills for features your `browserslist` targets already support.
