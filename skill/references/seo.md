# SEO

Make pages crawlable, indexable, and unambiguous about what they're for. Server-render anything you want ranked.

## Per-route metadata

- `[High]` **Unique `<title>` per route** — ≤ 60 chars (Google truncates). Include the page topic and brand.
- `[High]` **Unique `<meta name="description">`** — ≤ 155 chars. Compelling, factual, route-specific. Don't duplicate across pages.
- `[High]` **Set them programmatically in SPAs** — via your router or framework helmet. A single global title is an anti-pattern.

## Canonicalization

- `[High]` <a id="canonical"></a>**`<link rel="canonical" href="https://example.com/page">`** — absolute URL on every indexable page. Resolves duplicate content from query params, trailing slashes, paginated archives.
- `[High]` **Pick one canonical host** — `www.example.com` or `example.com`, not both. Redirect 301 the other.
- `[High]` **HTTPS is canonical** — redirect HTTP to HTTPS.

## Robots & sitemap

- `[High]` **`/robots.txt`** at the root. Reference the sitemap:
  ```
  User-agent: *
  Allow: /
  Disallow: /admin/
  Sitemap: https://example.com/sitemap.xml
  ```
- `[High]` **`/sitemap.xml`** — auto-generated, includes only canonical URLs, updated on deploy. Submit to Search Console + Bing Webmaster.
- `[Medium]` **`<meta name="robots">`** — per-page directives (`noindex`, `nofollow`) when needed. Default is implicit "index, follow."

## Structured data (JSON-LD)

- `[Medium]` <a id="json-ld"></a>**JSON-LD over microdata or RDFa** — Google's preferred format. Inline a `<script type="application/ld+json">` per page.
  - `Organization` on every page (brand, logo, sameAs).
  - `WebSite` with `SearchAction` if you have site search.
  - `BreadcrumbList` on category/detail pages.
  - `Article` / `Product` / `Recipe` / `Event` / `FAQPage` etc. as applicable.
- `[Medium]` **Validate** with Google's Rich Results Test and Schema.org validator. Don't ship structured data that doesn't validate — it does nothing.
- `[Low]` **Don't ship `FAQPage` markup if you're not actually showing FAQs** — Google has cracked down on spammy structured data.

## Open Graph & Twitter

- `[Medium]` **OG and Twitter Card tags** — see `head-and-meta.md`. Validate via the Facebook Sharing Debugger and Twitter Card Validator.
- `[Medium]` **Per-page OG image** — homogeneous brand images on every share kill engagement. Programmatic OG images (Vercel OG, Cloudinary transformations) per page.

## Indexability — the SSR/SSG question

- `[High]` <a id="ssr-for-indexability"></a>**Don't render indexable content client-side only** — Google can render JS, but slowly and incompletely. Bing, social crawlers, AI scrapers often can't. SSR / SSG / prerender any page that needs to rank.
- `[Medium]` **Hydration must not change content** — what the SSR HTML says must match what the rendered SPA says. Mismatches cause CLS and confuse crawlers.

## Multi-locale

- `[Medium]` <a id="hreflang"></a>**`hreflang`** — `<link rel="alternate" hreflang="en-US" href="…">` for each locale variant + `<link rel="alternate" hreflang="x-default" href="…">` for the fallback. Self-referencing entries required (each variant lists itself plus all others).
- `[Medium]` **Locale-specific URLs** — `/fr/`, `/es/`, or subdomain. Avoid query params (`?lang=fr`) for locale.

## Verification

- `[Medium]` **Search Console** — verify property, submit sitemap, monitor coverage and CWV.
- `[Medium]` **Bing Webmaster Tools** — same. Bing's market share isn't zero, and many regional engines syndicate Bing's index.

## URL hygiene

- `[Medium]` **Stable, readable URLs** — `/blog/article-slug` not `/blog?id=42`.
- `[Medium]` **No tracking params on canonical pages** — strip UTM/`fbclid` server-side before rendering canonical.
- `[Low]` **Trailing slashes consistent** — pick one (`/page/` or `/page`), 301 the other.

## Breadcrumbs

- `[Medium]` <a id="breadcrumbs"></a>**Breadcrumb UI + `BreadcrumbList` JSON-LD** — improves rich results in SERPs.

## Pagination

- **Note:** Google deprecated `rel="next"`/`rel="prev"` in 2019. Don't bother. Instead, ensure each paginated page is self-contained, has a unique title (`Articles — Page 3`), and is reachable via internal links.

## Crawl budget

- `[Low]` **Don't waste crawl on infinite-scroll-only feeds** — provide paginated equivalents in the sitemap, or use the History API to expose stable URLs per page.
- `[Low]` **Avoid `?param` proliferation** — facet combinations create exponential URL space. Use canonical to fold them.

## Speed

- `[Medium]` **Core Web Vitals affect ranking** — see `core-web-vitals.md`. Slow site = lower placement.

## Don't

- Don't keyword-stuff `<title>` or `<meta description>`.
- Don't `noindex` then expect the page to rank — it won't.
- Don't ship hidden text (white-on-white) — that's a manual penalty.
- Don't auto-translate with machine translation as the sole content for indexable pages — Google considers that low quality.
- Don't ship a sitemap with broken or non-canonical URLs.
