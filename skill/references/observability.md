# Observability

Lab numbers lie. Field data tells you what real users actually experience. Wire it up before launch, not after the first incident.

## RUM: Real User Monitoring

- `[Medium]` <a id="web-vitals"></a>**`web-vitals` library** — official Google package. Reports LCP, INP, CLS, TTFB, FCP from real sessions:
  ```js
  import { onLCP, onINP, onCLS, onTTFB, onFCP } from "web-vitals";

  function send(metric) {
    const body = JSON.stringify({
      name: metric.name,
      value: metric.value,
      id: metric.id,
      page: location.pathname,
    });
    (navigator.sendBeacon && navigator.sendBeacon("/rum", body))
      || fetch("/rum", { body, method: "POST", keepalive: true });
  }

  onLCP(send); onINP(send); onCLS(send); onTTFB(send); onFCP(send);
  ```
- `[Medium]` **Use `sendBeacon` or `fetch keepalive`** — survives page unload, doesn't block navigation.
- `[Medium]` **Sample, don't drop** — high traffic? Sample at 1-10%. Don't take a fixed-size set; you'll miss tails. Stratified sampling (more for slow sessions) is even better.
- `[Low]` **Pair with attribution** — `web-vitals/attribution` exposes which element caused the LCP, what task blocked INP. Critical for debugging.

## Error tracking

- `[Medium]` <a id="error-tracking"></a>**Capture client exceptions** — Sentry, GlitchTip (open-source Sentry-compatible), Bugsnag, Rollbar, Datadog RUM. Sentry is the de-facto default.
  ```js
  import * as Sentry from "@sentry/browser";
  Sentry.init({
    dsn: "https://…@sentry.io/…",
    tracesSampleRate: 0.1,
    environment: "production",
    release: process.env.GIT_SHA,
  });
  ```
- `[Medium]` **Capture unhandled promise rejections** — most error-tracking SDKs do this; verify in setup.
- `[Medium]` **Tag releases / git SHA** — so you can correlate spikes to a specific deploy.

## Source maps

- `[High]` <a id="source-maps"></a>**Generated, but private** — production source maps must exist (otherwise stack traces are useless), but never publicly served. Upload to your error tracker (Sentry CLI, Datadog), serve `.js` only.
  ```js
  // vite.config.js
  export default { build: { sourcemap: "hidden" } };
  ```
- `[Medium]` **Verify upload in CI** — the deploy is incomplete if source maps didn't make it to the error tracker. A failing test would be ideal.
- `[High]` **Don't reference public source maps from production JS** — strip `//# sourceMappingURL=` or point it at a non-public path the tracker reads server-side.

## Performance budgets in CI

- `[Medium]` <a id="ci-budgets"></a>**Block PRs on regression** — pick at least one:
  - **Lighthouse CI** — Lighthouse on every PR; thresholds for performance/a11y/SEO/best-practices.
  - **`size-limit`** — JS/CSS bundle sizes; runs in tens of seconds.
  - **`bundlewatch`** — same idea, GitHub-integrated.
- `[Medium]` **Define budgets per-route, not per-bundle** — what matters is what users download per page, not how the bundles split.

## Synthetic monitoring

- `[Low]` **Checkly, Pingdom, Datadog Synthetic** — periodic Lighthouse / scripted-flow runs from outside. Catches "site is down" before users tweet at you.
- `[Low]` **Status page** — public or private. Even a `/status.json` polled by your monitoring beats nothing.

## Logging

- `[Low]` **Structured client logs** — when you do log from the browser (warnings, soft errors), use a structured shape (`{ level, msg, context }`), not freeform `console.log`. Easier to query.
- `[Medium]` **Don't log PII** — no emails, no auth tokens, no full URLs with query params. Strip before sending.

## Privacy

- `[Medium]` **Respect `Sec-GPC`** — see `privacy-and-cookies.md`. Treat as a "no non-essential analytics" signal.
- `[Medium]` **Anonymize IPs** server-side before persisting. Most analytics tools have a flag for this.
- `[Medium]` **Disclose RUM in your privacy policy** — what you collect, why, retention.

## What to alert on

- `[Medium]` **CWV regression** — INP > 200ms p75, LCP > 2.5s p75, CLS > 0.1 p75 sustained for > 1 hour.
- `[Medium]` **Error rate spike** — > 2x rolling baseline.
- `[Low]` **New error class** — first occurrence of a new exception, especially after a deploy.
- `[Low]` **Crash-free sessions drop** — % users with no JS exception in their session.

## Don't

- Don't ship Sentry without an environment tag — production and staging errors will mix.
- Don't sample at < 1% on low-traffic apps; you'll miss everything.
- Don't enable Sentry's session replay without consent and a privacy review — it can capture inputs.
- Don't pipe RUM data to Google Analytics for "free" — most regions consider that a third-party data flow that needs consent.
- Don't use `console.error` as your error reporting. It's not aggregated, not searchable, not alerted on.
