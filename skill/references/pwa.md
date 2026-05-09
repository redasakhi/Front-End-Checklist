# PWA & service workers

PWA in 2026 is a pragmatic toolset, not a marketing pitch. Use it when you need installability, offline support, or push — not because Lighthouse has a section for it.

## When you actually need a PWA

- App-like installable experience on mobile and desktop (`A2HS`).
- Offline or unreliable-network use case (transit, field tools, in-store).
- Push notifications for re-engagement (with explicit user consent).
- Background sync (queue actions while offline, replay when back online).

If none of those apply, ship a fast website and skip the PWA layer.

## Web app manifest

- `[Medium]` <a id="manifest"></a>**`/site.webmanifest`** linked from `<head>`:
  ```html
  <link rel="manifest" href="/site.webmanifest">
  ```
- `[Medium]` **Required fields:**
  ```json
  {
    "name": "Example",
    "short_name": "Example",
    "start_url": "/?utm_source=pwa",
    "display": "standalone",
    "theme_color": "#0b0b0b",
    "background_color": "#ffffff",
    "icons": [
      { "src": "/icon-192.png", "sizes": "192x192", "type": "image/png" },
      { "src": "/icon-512.png", "sizes": "512x512", "type": "image/png" },
      { "src": "/icon-maskable-192.png", "sizes": "192x192", "type": "image/png", "purpose": "maskable" },
      { "src": "/icon-maskable-512.png", "sizes": "512x512", "type": "image/png", "purpose": "maskable" }
    ]
  }
  ```
- `[Low]` **`screenshots`** — for richer install prompts in Chrome's "Install app" UI.
- `[Low]` **`shortcuts`** — context-menu shortcuts on the installed app icon.

## Service worker registration

- `[Medium]` **Register SW only after first paint** — don't block the LCP race:
  ```js
  if ("serviceWorker" in navigator) {
    window.addEventListener("load", () => {
      navigator.serviceWorker.register("/sw.js");
    });
  }
  ```
- `[Medium]` **Use Workbox** — hand-rolling caching strategies is error-prone. Workbox is battle-tested.
- `[High]` **HTTPS only** — service workers don't run on `http://` (except `localhost`).
- `[Medium]` **Scope** — register at root unless you're carving out a sub-app.

## Caching strategies

Match the strategy to the resource type:

- `[Medium]` <a id="caching-strategies"></a>**Cache-first for static, hashed assets** — JS, CSS, images with content hashes. Long TTL, never revalidate.
- `[Medium]` **Network-first for HTML** — always try network, fall back to cache when offline. Avoids serving stale HTML on deploy.
- `[Medium]` **Stale-while-revalidate for API responses** — show stale immediately, refresh in background. Good for tolerant content (lists, feeds).
- `[Low]` **Network-only with offline fallback** — for things that must be fresh; show a custom offline page on failure.

## Offline UX

- `[Low]` **Offline fallback page** — pre-cached `/offline.html` shown when navigation fails. Branded, with retry button.
- `[Low]` **Detect online status** — `navigator.onLine` and `online`/`offline` events to show a "you're offline" banner. Don't block actions; queue them.

## Updates

- `[Medium]` <a id="sw-updates"></a>**SW versioning + skipWaiting strategy** — decide carefully:
  - **Update on next navigation** (default) — safe; user gets new version on next page load.
  - **`skipWaiting` + `clients.claim`** — instant takeover; risk of inconsistent state if the user has tabs open.
- `[Medium]` **Notify the user when an update is ready** — show a "New version available, refresh" toast. Don't auto-refresh; that loses form state.

## Install prompt UX

- `[Low]` <a id="install-prompt"></a>**`beforeinstallprompt`** — capture the event, show a custom install button at a relevant moment. Don't fire it on first page view; that gets dismissed.
  ```js
  let deferredPrompt;
  window.addEventListener("beforeinstallprompt", (e) => {
    e.preventDefault();
    deferredPrompt = e;
    showInstallButton();
  });
  installBtn.addEventListener("click", async () => {
    deferredPrompt?.prompt();
    deferredPrompt = null;
  });
  ```

## Push notifications

- `[High]` <a id="push"></a>**Permission request behind a clear, in-context rationale** — never fire `Notification.requestPermission()` on page load. Show a UI ("Get notified when your order ships?") with an explicit user click that triggers it.
- `[High]` **Don't spam** — opt-in is one click, opt-out is harder. Respect frequency limits.
- `[Medium]` **Server-side: use VAPID** — modern Web Push standard. Key pair stays on the server.
- `[Low]` **Test denial UX** — what does your app do when permission is denied or dismissed? Don't keep asking.

## Background sync

- `[Low]` <a id="background-sync"></a>**Background Sync API** — queue failed POSTs while offline, replay when connectivity returns. Niche but powerful for forms and chat.

## Testing

- `[Medium]` **Test in the Application panel** — DevTools > Application: Manifest, Service Workers, Storage, Cache. Use "Update on reload" while developing.
- `[Medium]` **Lighthouse PWA audit** — covers manifest correctness, HTTPS, SW registration, basic offline. Use as a smoke test, not a ceiling.

## Don't

- Don't register a service worker just to "tick the PWA box." Inactive caches make debugging miserable.
- Don't auto-prompt for notifications on first visit. Browsers throttle and users block.
- Don't cache HTML aggressively unless you have a fast invalidation story — stale HTML loads stale chunks and breaks deploys.
- Don't use `display: fullscreen` for sites without a fullscreen use case — it removes browser chrome and surprises users.
