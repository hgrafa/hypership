# Landing Page Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a static landing page and interactive documentation site for Hypership using Astro with MDX, featuring a Typewriter Craft aesthetic and dual-mode usecase subpages.

**Architecture:** Astro static site in `site/` subdirectory. Landing page assembled from Astro components. Usecase subpages as MDX files using custom Astro components for dialogue and split-view rendering. Tab state persisted via localStorage with no-flash inline script. Dark mode via `prefers-color-scheme`.

**Tech Stack:** Astro 5, @astrojs/mdx, @fontsource/jetbrains-mono, CSS custom properties, vanilla JS (tab toggle only)

**Deviations from spec:**
- **Fonts**: spec lists `public/fonts/` for self-hosted fonts. Plan uses `@fontsource/jetbrains-mono` (npm) instead — cleaner, auto-copies to build output, same self-hosted result.
- **CodeBlock.astro**: spec lists it separately. Plan merges its role into `CodeStep.astro` (which wraps code blocks with annotations). A standalone `CodeBlock.astro` is unnecessary since all code blocks appear inside `CodeStep`.

**Spec:** `docs/superpowers/specs/2026-03-23-landing-page-design.md`

---

### Task 1: Project Scaffold

**Files:**
- Create: `site/package.json`
- Create: `site/astro.config.mjs`
- Create: `site/tsconfig.json`
- Create: `site/.gitignore`

- [ ] **Step 1: Create site directory and package.json**

```json
{
  "name": "hypership-site",
  "type": "module",
  "private": true,
  "scripts": {
    "dev": "astro dev",
    "build": "astro build",
    "preview": "astro preview"
  }
}
```

Write to `site/package.json`.

- [ ] **Step 2: Install dependencies**

Run: `cd site && npm install astro @astrojs/mdx @fontsource/jetbrains-mono`

- [ ] **Step 3: Create astro.config.mjs**

```js
import { defineConfig } from 'astro/config';
import mdx from '@astrojs/mdx';

export default defineConfig({
  integrations: [mdx()],
  build: {
    assets: '_assets',
  },
});
```

Write to `site/astro.config.mjs`.

- [ ] **Step 4: Create tsconfig.json**

```json
{
  "extends": "astro/tsconfigs/strict"
}
```

Write to `site/tsconfig.json`.

- [ ] **Step 5: Create .gitignore**

```
node_modules/
dist/
.astro/
```

Write to `site/.gitignore`.

- [ ] **Step 6: Verify scaffold**

Run: `cd site && npx astro check 2>&1 || true`
Expected: No fatal errors (may warn about missing pages — that's fine)

- [ ] **Step 7: Commit**

```bash
git add site/
git commit -m "feat(site): scaffold Astro project with MDX integration"
```

---

### Task 2: Design Tokens + Global CSS

**Files:**
- Create: `site/src/styles/tokens.css`
- Create: `site/src/styles/global.css`

- [ ] **Step 1: Create design tokens**

Write to `site/src/styles/tokens.css`:

```css
:root {
  /* Light mode — colors */
  --bg: #f5f0e8;
  --text-primary: #2c2418;
  --text-secondary: #6b5d4f;
  --text-accent: #8a7a65;
  --surface: rgba(44, 36, 24, 0.04);
  --surface-hover: rgba(44, 36, 24, 0.06);
  --border: rgba(138, 122, 101, 0.12);
  --border-strong: rgba(138, 122, 101, 0.25);
  --success: #9a8a6e;
  --warning: #966b5a;
  --terminal-bg: #1b1b1c;

  /* Light mode — code syntax */
  --code-keyword: #6b4423;
  --code-string: #4a6b2a;
  --code-comment: #8a7a65;

  /* Typography (rem-based, 16px root) */
  --font-mono: 'JetBrains Mono', 'Fira Code', 'Cascadia Code', monospace;
  --text-xs: 0.75rem;
  --text-sm: 0.8125rem;
  --text-base: 0.9375rem;
  --text-md: 1rem;
  --text-lg: 1.25rem;
  --text-xl: 1.75rem;
  --text-hero: 2.25rem;
  --text-code: 0.875rem;

  /* Spacing scale (8px base) */
  --space-1: 0.5rem;
  --space-2: 1rem;
  --space-3: 1.5rem;
  --space-4: 2rem;
  --space-5: 3rem;
  --space-6: 4rem;

  /* Layout */
  --content-max-width: 960px;
  --content-padding: var(--space-4);
  --section-gap: var(--space-5);
  --grid-gap: var(--space-2);
  --column-gap: var(--space-3);
}

@media (prefers-color-scheme: dark) {
  :root {
    --bg: #1b1b1c;
    --text-primary: #dddad2;
    --text-secondary: #94918a;
    --text-accent: #8e8b80;
    --surface: rgba(220, 210, 195, 0.04);
    --surface-hover: rgba(220, 210, 195, 0.06);
    --border: rgba(108, 108, 98, 0.05);
    --border-strong: rgba(130, 135, 145, 0.10);
    --terminal-bg: #141415;

    --code-keyword: #c8a87a;
    --code-string: #a8c878;
    --code-comment: #636158;
  }
}
```

- [ ] **Step 2: Create global CSS with paper texture**

Write to `site/src/styles/global.css`:

```css
@import './tokens.css';

*,
*::before,
*::after {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

html {
  font-family: var(--font-mono);
  font-size: 100%;
  line-height: 1.6;
  color: var(--text-primary);
  background-color: var(--bg);
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

body {
  min-height: 100vh;
  background-color: var(--bg);
  background-image:
    repeating-linear-gradient(
      0deg,
      transparent,
      transparent 1.75rem,
      rgba(180, 160, 130, 0.13) calc(1.75rem + 1px)
    ),
    url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='200' height='200'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.65' numOctaves='4' stitchTiles='stitch'/%3E%3CfeColorMatrix type='saturate' values='0'/%3E%3C/filter%3E%3Crect width='200' height='200' filter='url(%23n)' opacity='0.04'/%3E%3C/svg%3E");
}

@media (prefers-color-scheme: dark) {
  body {
    background-image:
      repeating-linear-gradient(
        0deg,
        transparent,
        transparent 1.75rem,
        rgba(108, 108, 98, 0.05) calc(1.75rem + 1px)
      ),
      url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='200' height='200'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.65' numOctaves='4' stitchTiles='stitch'/%3E%3CfeColorMatrix type='saturate' values='0'/%3E%3C/filter%3E%3Crect width='200' height='200' filter='url(%23n)' opacity='0.05'/%3E%3C/svg%3E");
  }
}

a {
  color: var(--text-primary);
  text-decoration: none;
}

a:hover {
  color: var(--text-accent);
}

/* Utility classes */
.label {
  font-size: var(--text-xs);
  text-transform: uppercase;
  letter-spacing: 2px;
  color: var(--text-accent);
}

.container {
  max-width: var(--content-max-width);
  margin: 0 auto;
  padding: 0 var(--content-padding);
}

/* Responsive */
@media (max-width: 768px) {
  :root {
    --content-padding: var(--space-3);
    --section-gap: var(--space-4);
  }
}

@media (max-width: 480px) {
  :root {
    --content-padding: var(--space-2);
    --text-hero: 1.75rem;
    --text-xl: 1.5rem;
  }
}
```

- [ ] **Step 3: Verify build**

Run: `cd site && npm run build`
Expected: Build succeeds (CSS is included even without pages referencing it — Astro processes it on import)

- [ ] **Step 4: Commit**

```bash
git add site/src/styles/
git commit -m "feat(site): add design tokens and global CSS with paper texture"
```

---

### Task 3: Base Layout + Metadata

**Files:**
- Create: `site/src/layouts/Base.astro`
- Create: `site/public/favicon.svg`
- Create: `site/public/og-image.png` (placeholder — 1200x630 parchment-textured card with "hypership" logo text, to be replaced with a designed version later)

- [ ] **Step 1: Create favicon**

Write to `site/public/favicon.svg`:

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <rect width="32" height="32" rx="4" fill="#f5f0e8"/>
  <text x="50%" y="50%" dominant-baseline="central" text-anchor="middle"
    font-family="monospace" font-size="20" font-weight="700" fill="#2c2418">h</text>
</svg>
```

- [ ] **Step 2: Create Base layout**

Write to `site/src/layouts/Base.astro`:

```astro
---
import '@fontsource/jetbrains-mono/400.css';
import '@fontsource/jetbrains-mono/600.css';
import '@fontsource/jetbrains-mono/700.css';
import '../styles/global.css';

interface Props {
  title: string;
  description?: string;
}

const { title, description = 'A delivery-first methodology. Ship features. Kill debt. Works with whatever plugins and agents you already use.' } = Astro.props;
const canonicalURL = new URL(Astro.url.pathname, Astro.site ?? 'https://hypership.dev');
---

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <link rel="icon" type="image/svg+xml" href="/favicon.svg" />

  <title>{title}</title>
  <meta name="description" content={description} />
  <link rel="canonical" href={canonicalURL} />

  <!-- Open Graph -->
  <meta property="og:type" content="website" />
  <meta property="og:title" content={title} />
  <meta property="og:description" content={description} />
  <meta property="og:url" content={canonicalURL} />

  <!-- Open Graph image -->
  <meta property="og:image" content="/og-image.png" />

  <!-- Twitter -->
  <meta name="twitter:card" content="summary_large_image" />
  <meta name="twitter:title" content={title} />
  <meta name="twitter:description" content={description} />
  <meta name="twitter:image" content="/og-image.png" />

  <!-- Tab persistence: read localStorage before paint to avoid flash -->
  <script is:inline>
    (function() {
      var mode = localStorage.getItem('hs-mode');
      if (mode) document.documentElement.setAttribute('data-mode', mode);
    })();
  </script>
</head>
<body>
  <slot />
</body>
</html>
```

- [ ] **Step 3: Create a minimal index page to verify build**

Write to `site/src/pages/index.astro`:

```astro
---
import Base from '../layouts/Base.astro';
---
<Base title="Hypership — delivery-obsessed engineering">
  <main class="container">
    <p>Scaffold works.</p>
  </main>
</Base>
```

- [ ] **Step 4: Verify build**

Run: `cd site && npm run build`
Expected: Build succeeds, output in `site/dist/`

- [ ] **Step 5: Commit**

```bash
git add site/src/layouts/ site/src/pages/index.astro site/public/favicon.svg
git commit -m "feat(site): add Base layout with metadata, fonts, and dark mode script"
```

---

### Task 4: Nav + Footer Components

**Files:**
- Create: `site/src/components/Nav.astro`
- Create: `site/src/components/Footer.astro`

- [ ] **Step 1: Create Nav component**

Write to `site/src/components/Nav.astro`:

```astro
---
interface Props {
  breadcrumb?: string;
}
const { breadcrumb } = Astro.props;
---

<nav class="nav">
  <div class="nav-inner container">
    <div class="nav-left">
      <a href="/" class="logo">hypership</a>
      {breadcrumb && <span class="breadcrumb">/ {breadcrumb}</span>}
    </div>
    <div class="nav-right">
      {!breadcrumb && (
        <>
          <a href="/#quick-start">quick start</a>
          <a href="/#use-cases">use cases</a>
        </>
      )}
      {breadcrumb && (
        <a href="/#use-cases">← all cases</a>
      )}
      <a href="https://github.com/hgrafa/hypership" target="_blank" rel="noopener">github ↗</a>
    </div>
  </div>
</nav>

<style>
  .nav {
    border-bottom: 1px solid var(--border);
  }
  .nav-inner {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding-top: var(--space-3);
    padding-bottom: var(--space-3);
  }
  .nav-left {
    display: flex;
    align-items: center;
    gap: var(--space-2);
  }
  .logo {
    font-size: var(--text-code);
    font-weight: 700;
    letter-spacing: 1px;
  }
  .breadcrumb {
    font-size: var(--text-sm);
    color: var(--text-accent);
  }
  .nav-right {
    display: flex;
    gap: var(--space-3);
    font-size: var(--text-xs);
    text-transform: uppercase;
    letter-spacing: 1.5px;
  }
  .nav-right a {
    color: var(--text-accent);
  }
  .nav-right a:hover {
    color: var(--text-primary);
  }
</style>
```

- [ ] **Step 2: Create Footer component**

Write to `site/src/components/Footer.astro`:

```astro
<footer class="footer">
  <div class="footer-inner container">
    <div class="footer-left">
      <div class="footer-logo">hypership</div>
      <div class="footer-sub">A Claude Code plugin. Open source.</div>
    </div>
    <div class="footer-right">
      <a href="https://github.com/hgrafa/hypership" target="_blank" rel="noopener">github ↗</a>
      <a href="/#quick-start">install</a>
    </div>
  </div>
</footer>

<style>
  .footer {
    border-top: 1px solid var(--border);
  }
  .footer-inner {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding-top: var(--space-4);
    padding-bottom: var(--space-4);
  }
  .footer-logo {
    font-size: var(--text-md);
    font-weight: 600;
  }
  .footer-sub {
    font-size: var(--text-sm);
    color: var(--text-accent);
    margin-top: var(--space-1);
  }
  .footer-right {
    display: flex;
    gap: var(--space-3);
    font-size: var(--text-xs);
    text-transform: uppercase;
    letter-spacing: 1.5px;
  }
  .footer-right a {
    color: var(--text-accent);
  }
  .footer-right a:hover {
    color: var(--text-primary);
  }
</style>
```

- [ ] **Step 3: Verify build**

Run: `cd site && npm run build`
Expected: Build succeeds

- [ ] **Step 4: Commit**

```bash
git add site/src/components/Nav.astro site/src/components/Footer.astro
git commit -m "feat(site): add Nav and Footer components"
```

---

### Task 5: Landing Page Sections — Hero + QuickStart + Philosophy

**Files:**
- Create: `site/src/components/Hero.astro`
- Create: `site/src/components/QuickStart.astro`
- Create: `site/src/components/Philosophy.astro`

- [ ] **Step 1: Create Hero component**

Write to `site/src/components/Hero.astro`:

```astro
<section class="hero">
  <div class="hero-inner container">
    <span class="label">claude code plugin</span>
    <h1 class="hero-title">delivery-obsessed engineering.</h1>
    <p class="hero-subtitle">
      Ship features. Kill debt. Works with whatever
      plugins and agents you already use.
    </p>
    <div class="hero-cta">
      <span class="prompt">&gt;</span> /plugin install hgrafa/hypership
    </div>
  </div>
</section>

<style>
  .hero {
    padding: var(--space-6) 0 var(--space-5);
    text-align: center;
  }
  .hero-title {
    font-size: var(--text-hero);
    font-weight: 700;
    line-height: 1.2;
    margin-top: var(--space-3);
  }
  .hero-subtitle {
    font-size: var(--text-base);
    color: var(--text-secondary);
    line-height: 1.8;
    margin-top: var(--space-2);
  }
  .hero-cta {
    display: inline-block;
    border: 1.5px solid var(--text-accent);
    color: var(--text-primary);
    font-size: var(--text-code);
    padding: var(--space-1) var(--space-3);
    letter-spacing: 1px;
    margin-top: var(--space-4);
  }
  .prompt {
    color: var(--text-accent);
  }
</style>
```

- [ ] **Step 2: Create QuickStart component**

Write to `site/src/components/QuickStart.astro`:

```astro
<section id="quick-start" class="quick-start">
  <div class="container">
    <div class="section-header">
      <span class="label">Quick Start</span>
      <h2 class="section-title">Three commands. Zero config.</h2>
      <p class="section-subtitle">Install, deliver, consolidate. That's the whole workflow.</p>
    </div>

    <div class="columns">
      <div class="column">
        <span class="label">01 — install</span>
        <div class="command"><span class="prompt">&gt;</span> /plugin install hgrafa/hypership</div>
        <p class="column-desc">Reads your CLAUDE.md. Adapts to your stack. Done.</p>
      </div>
      <div class="column">
        <span class="label">02 — deliver</span>
        <div class="command"><span class="prompt">&gt;</span> /delivery add roles to auth</div>
        <p class="column-desc">Classifies, plans, tests, ships. Your plugins, your pipeline.</p>
      </div>
      <div class="column">
        <span class="label">03 — consolidate</span>
        <div class="command"><span class="prompt">&gt;</span> /removedebt last 3 features</div>
        <p class="column-desc">Scans real debt. You decide. Safety gates protect you.</p>
      </div>
    </div>
  </div>
</section>

<style>
  .quick-start {
    padding: var(--section-gap) 0;
    border-top: 1px solid var(--border);
  }
  .section-header {
    margin-bottom: var(--space-3);
  }
  .section-title {
    font-size: var(--text-lg);
    font-weight: 600;
    margin-top: var(--space-1);
  }
  .section-subtitle {
    font-size: var(--text-base);
    color: var(--text-secondary);
    margin-top: var(--space-1);
  }
  .columns {
    display: flex;
    gap: var(--column-gap);
    margin-top: var(--space-3);
  }
  .column {
    flex: 1;
    background: var(--surface);
    padding: var(--space-2);
    border-left: 2px solid var(--border-strong);
  }
  .command {
    background: var(--surface-hover);
    padding: var(--space-1) var(--space-2);
    font-size: var(--text-code);
    margin-top: var(--space-1);
  }
  .prompt {
    color: var(--text-accent);
  }
  .column-desc {
    font-size: var(--text-sm);
    color: var(--text-secondary);
    line-height: 1.6;
    margin-top: var(--space-1);
  }
  @media (max-width: 768px) {
    .columns {
      flex-direction: column;
    }
  }
</style>
```

- [ ] **Step 3: Create Philosophy component**

Write to `site/src/components/Philosophy.astro`:

```astro
<section class="philosophy">
  <div class="container">
    <div class="section-header">
      <span class="label">Philosophy</span>
      <h2 class="section-title">A delivery-first methodology.</h2>
    </div>

    <div class="principles">
      <div class="principle">
        <h3 class="principle-title">Features and debt are separate.</h3>
        <p class="principle-desc">Don't refactor during feature delivery. Ship first, consolidate deliberately.</p>
      </div>
      <div class="principle">
        <h3 class="principle-title">Debt is concrete, not speculative.</h3>
        <p class="principle-desc">Grep-able duplication, actual unused code. Not "could be more generic."</p>
      </div>
      <div class="principle">
        <h3 class="principle-title">Senior engineers decide.</h3>
        <p class="principle-desc">Tool proposes, you dispose. Every finding has a skip option.</p>
      </div>
    </div>
  </div>
</section>

<style>
  .philosophy {
    padding: var(--section-gap) 0;
    border-top: 1px solid var(--border);
  }
  .section-header {
    margin-bottom: var(--space-3);
  }
  .section-title {
    font-size: var(--text-lg);
    font-weight: 600;
    margin-top: var(--space-1);
  }
  .principles {
    display: flex;
    gap: var(--column-gap);
  }
  .principle {
    flex: 1;
  }
  .principle-title {
    font-size: var(--text-md);
    font-weight: 600;
  }
  .principle-desc {
    font-size: var(--text-sm);
    color: var(--text-secondary);
    line-height: 1.7;
    margin-top: var(--space-1);
  }
  @media (max-width: 768px) {
    .principles {
      flex-direction: column;
      gap: var(--space-3);
    }
  }
</style>
```

- [ ] **Step 4: Verify build**

Run: `cd site && npm run build`
Expected: Build succeeds

- [ ] **Step 5: Commit**

```bash
git add site/src/components/Hero.astro site/src/components/QuickStart.astro site/src/components/Philosophy.astro
git commit -m "feat(site): add Hero, QuickStart, and Philosophy landing sections"
```

---

### Task 6: UsecaseGrid + Landing Page Assembly

**Files:**
- Create: `site/src/components/UsecaseGrid.astro`
- Create: `site/src/layouts/Landing.astro`
- Modify: `site/src/pages/index.astro`

- [ ] **Step 1: Create UsecaseGrid component**

Write to `site/src/components/UsecaseGrid.astro`:

```astro
---
const cases = [
  { num: '01', title: 'Evolving a system', desc: 'Auth → roles → claims → granular permissions. Iterative delivery building layer by layer.', slug: 'evolving-a-system' },
  { num: '02', title: 'Debt after a sprint', desc: '6 features shipped, code feels heavy. Scan, filter noise, execute with safety nets.', slug: 'debt-after-a-sprint' },
  { num: '03', title: 'Production fire', desc: 'Duplicate payments. Bug-as-test gate: reproduce first, then fix. No guessing.', slug: 'production-fire' },
  { num: '04', title: 'Cycle visibility', desc: 'Tech lead wants to see the rhythm. /status shows health, signals when to consolidate.', slug: 'cycle-visibility' },
  { num: '05', title: 'Legacy without fear', desc: 'Inherited monolith. Module-scoped cleanup with snapshot, escape hatch, hard stop.', slug: 'legacy-without-fear' },
];
---

<section id="use-cases" class="usecases">
  <div class="container">
    <div class="section-header">
      <span class="label">Use Cases</span>
      <h2 class="section-title">See it in action.</h2>
      <p class="section-subtitle">Real scenarios, real workflows. Each one has a visual walkthrough and a terminal deep-dive.</p>
    </div>

    <div class="grid">
      {cases.map((c) => (
        <a href={`/cases/${c.slug}/`} class="card">
          <span class="label">{c.num}</span>
          <h3 class="card-title">{c.title}</h3>
          <p class="card-desc">{c.desc}</p>
          <span class="card-link">VIEW CASE →</span>
        </a>
      ))}
    </div>
  </div>
</section>

<style>
  .usecases {
    padding: var(--section-gap) 0;
    border-top: 1px solid var(--border);
  }
  .section-header {
    margin-bottom: var(--space-3);
  }
  .section-title {
    font-size: var(--text-lg);
    font-weight: 600;
    margin-top: var(--space-1);
  }
  .section-subtitle {
    font-size: var(--text-base);
    color: var(--text-secondary);
    margin-top: var(--space-1);
  }
  .grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: var(--grid-gap);
    margin-top: var(--space-3);
  }
  .card {
    display: block;
    background: var(--surface);
    padding: var(--space-2);
    transition: background 0.15s;
  }
  .card:hover {
    background: var(--surface-hover);
    color: var(--text-primary);
  }
  .card-title {
    font-size: var(--text-md);
    font-weight: 600;
    margin-top: var(--space-1);
  }
  .card-desc {
    font-size: var(--text-sm);
    color: var(--text-secondary);
    line-height: 1.5;
    margin-top: var(--space-1);
  }
  .card-link {
    display: inline-block;
    font-size: var(--text-xs);
    color: var(--text-accent);
    letter-spacing: 1px;
    margin-top: var(--space-1);
  }
  @media (max-width: 768px) {
    .grid {
      grid-template-columns: 1fr;
    }
  }
</style>
```

- [ ] **Step 2: Create Landing layout**

Write to `site/src/layouts/Landing.astro`:

```astro
---
import Base from './Base.astro';
import Nav from '../components/Nav.astro';
import Footer from '../components/Footer.astro';

interface Props {
  title: string;
  description?: string;
}

const { title, description } = Astro.props;
---

<Base title={title} description={description}>
  <Nav />
  <main>
    <slot />
  </main>
  <Footer />
</Base>
```

- [ ] **Step 3: Assemble index page**

Write to `site/src/pages/index.astro`:

```astro
---
import Landing from '../layouts/Landing.astro';
import Hero from '../components/Hero.astro';
import QuickStart from '../components/QuickStart.astro';
import Philosophy from '../components/Philosophy.astro';
import UsecaseGrid from '../components/UsecaseGrid.astro';
---

<Landing title="Hypership — delivery-obsessed engineering">
  <Hero />
  <QuickStart />
  <Philosophy />
  <UsecaseGrid />
</Landing>
```

- [ ] **Step 4: Verify build**

Run: `cd site && npm run build`
Expected: Build succeeds. `dist/index.html` contains all sections.

- [ ] **Step 5: Verify HTML output contains key content**

Run: `cd site && grep -c "delivery-obsessed" dist/index.html && grep -c "quick-start" dist/index.html && grep -c "use-cases" dist/index.html`
Expected: Each grep returns at least 1

- [ ] **Step 6: Commit**

```bash
git add site/src/components/UsecaseGrid.astro site/src/layouts/Landing.astro site/src/pages/index.astro
git commit -m "feat(site): assemble landing page with all sections"
```

---

### Task 7: Tab System + Usecase Layout

**Files:**
- Create: `site/src/components/ModeTabs.astro`
- Create: `site/src/layouts/Usecase.astro`

- [ ] **Step 1: Create ModeTabs component**

Write to `site/src/components/ModeTabs.astro`:

```astro
<div class="tabs">
  <button class="tab tab-ootb" data-tab="ootb">out-of-the-box</button>
  <button class="tab tab-nerd" data-tab="nerd">im-a-nerd</button>
</div>

<script is:inline>
(function() {
  function setMode(mode) {
    document.documentElement.setAttribute('data-mode', mode);
    localStorage.setItem('hs-mode', mode);
    document.querySelectorAll('.tab').forEach(function(t) {
      t.classList.toggle('active', t.dataset.tab === mode);
    });
  }

  document.querySelectorAll('.tab').forEach(function(t) {
    t.addEventListener('click', function() {
      setMode(t.dataset.tab);
    });
  });

  // Initialize from localStorage or default
  var saved = localStorage.getItem('hs-mode') || 'ootb';
  setMode(saved);
})();
</script>

<style>
  .tabs {
    display: flex;
    border-bottom: 1.5px solid var(--border);
    gap: 0;
    margin-top: var(--space-3);
  }
  .tab {
    background: none;
    border: none;
    font-family: var(--font-mono);
    font-size: var(--text-base);
    color: var(--text-accent);
    padding: var(--space-1) var(--space-3);
    cursor: pointer;
    border-bottom: 2px solid transparent;
    margin-bottom: -1.5px;
  }
  .tab.active {
    color: var(--text-primary);
    font-weight: 600;
    border-bottom-color: var(--text-primary);
  }
  .tab:hover:not(.active) {
    color: var(--text-secondary);
  }
</style>
```

- [ ] **Step 2: Add global CSS for mode visibility**

Append to `site/src/styles/global.css`:

```css
/* Mode visibility: controlled by data-mode on <html> */
html:not([data-mode="nerd"]) .mode-nerd,
html[data-mode="ootb"] .mode-nerd {
  display: none !important;
}

html[data-mode="nerd"] .mode-ootb {
  display: none !important;
}

/* Default: show ootb, hide nerd (no-JS fallback) */
.mode-nerd {
  display: none;
}
```

- [ ] **Step 3: Create Usecase layout**

Write to `site/src/layouts/Usecase.astro`:

```astro
---
import Base from './Base.astro';
import Nav from '../components/Nav.astro';
import Footer from '../components/Footer.astro';
import ModeTabs from '../components/ModeTabs.astro';

interface Props {
  frontmatter: {
    number: string;
    title: string;
    subtitle: string;
    scenario: string;
    next?: { slug: string; title: string };
    prev?: { slug: string; title: string };
  };
}

const { frontmatter } = Astro.props;
const { number, title, subtitle, scenario, next, prev } = frontmatter;
---

<Base title={`${title} — Hypership`} description={subtitle}>
  <Nav breadcrumb={`use cases / ${title.toLowerCase()}`} />

  <main class="container usecase-page">
    <header class="usecase-header">
      <span class="label">Use Case {number}</span>
      <h1 class="usecase-title">{title}</h1>
      <p class="usecase-subtitle">{subtitle}</p>
    </header>

    <ModeTabs />

    <div class="usecase-scenario">
      <span class="label">The scenario</span>
      <p class="scenario-text">{scenario}</p>
    </div>

    <div class="usecase-content">
      <slot />
    </div>

    <nav class="usecase-nav">
      <div class="nav-prev">
        {prev ? (
          <a href={`/cases/${prev.slug}/`}>← {prev.title}</a>
        ) : (
          <a href="/#use-cases">← all cases</a>
        )}
      </div>
      <div class="nav-next">
        {next ? (
          <a href={`/cases/${next.slug}/`}>next: {next.title} →</a>
        ) : (
          <a href="/#use-cases">all cases →</a>
        )}
      </div>
    </nav>
  </main>

  <Footer />
</Base>

<style>
  .usecase-page {
    padding-top: var(--space-4);
    padding-bottom: var(--space-4);
  }
  .usecase-title {
    font-size: var(--text-xl);
    font-weight: 700;
    line-height: 1.25;
    margin-top: var(--space-1);
  }
  .usecase-subtitle {
    font-size: var(--text-md);
    color: var(--text-secondary);
    line-height: 1.6;
    margin-top: var(--space-1);
  }
  .usecase-scenario {
    background: var(--surface);
    padding: var(--space-2);
    border-left: 2px solid var(--border-strong);
    margin-top: var(--space-4);
  }
  .scenario-text {
    font-size: var(--text-base);
    line-height: 1.7;
    margin-top: var(--space-1);
  }
  .usecase-content {
    margin-top: var(--space-4);
  }
  .usecase-nav {
    display: flex;
    justify-content: space-between;
    border-top: 1px solid var(--border);
    padding-top: var(--space-3);
    margin-top: var(--space-5);
  }
  .usecase-nav a {
    font-size: var(--text-sm);
    color: var(--text-accent);
  }
  .nav-next a {
    color: var(--text-primary);
    font-weight: 600;
  }
</style>
```

- [ ] **Step 4: Verify build**

Run: `cd site && npm run build`
Expected: Build succeeds

- [ ] **Step 5: Commit**

```bash
git add site/src/components/ModeTabs.astro site/src/layouts/Usecase.astro site/src/styles/global.css
git commit -m "feat(site): add tab system and Usecase layout with mode persistence"
```

---

### Task 8: Dialogue Components (out-of-the-box mode)

**Files:**
- Create: `site/src/components/Dialogue.astro`
- Create: `site/src/components/DialogueMessage.astro`

- [ ] **Step 1: Create DialogueMessage component**

Write to `site/src/components/DialogueMessage.astro`:

```astro
---
interface Props {
  from: 'you' | 'hs';
  tags?: string[];
}

const { from, tags = [] } = Astro.props;
const isUser = from === 'you';
---

<div class:list={['msg', `msg-${from}`]}>
  <div class="avatar" data-from={from}>
    {isUser ? 'you' : 'hs'}
  </div>
  <div class="msg-body">
    <div class:list={['bubble', isUser ? 'bubble-user' : 'bubble-hs']}>
      <slot />
    </div>
    {tags.length > 0 && (
      <div class="tags">
        {tags.map((tag) => (
          <span class="tag">{tag}</span>
        ))}
      </div>
    )}
  </div>
</div>

<style>
  .msg {
    display: flex;
    gap: var(--space-1);
    margin-bottom: var(--space-2);
  }
  .avatar {
    min-width: 2rem;
    height: 2rem;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: var(--text-xs);
    font-weight: 600;
    flex-shrink: 0;
  }
  .avatar[data-from="you"] {
    background: var(--surface-hover);
    color: var(--text-secondary);
  }
  .avatar[data-from="hs"] {
    background: var(--text-primary);
    color: var(--bg);
  }
  .msg-body {
    flex: 1;
    min-width: 0;
  }
  .bubble {
    padding: var(--space-1) var(--space-2);
    font-size: var(--text-base);
    line-height: 1.7;
  }
  .bubble-user {
    background: var(--surface);
    border-radius: 2px 8px 8px 8px;
    font-weight: 500;
  }
  .bubble-hs {
    background: var(--surface);
    border-radius: 8px 2px 8px 8px;
    color: var(--text-secondary);
  }
  .bubble-hs :global(strong) {
    color: var(--text-primary);
  }
  .tags {
    display: flex;
    gap: 0.375rem;
    margin-top: 0.375rem;
    flex-wrap: wrap;
  }
  .tag {
    font-size: var(--text-xs);
    color: var(--success);
    background: rgba(154, 138, 110, 0.1);
    padding: 0.125rem var(--space-1);
    border-radius: 2px;
  }
</style>
```

- [ ] **Step 2: Create Dialogue wrapper**

Write to `site/src/components/Dialogue.astro`:

```astro
<div class="dialogue mode-ootb">
  <slot />
</div>

<style>
  .dialogue {
    max-width: 640px;
  }
</style>
```

- [ ] **Step 3: Verify build**

Run: `cd site && npm run build`
Expected: Build succeeds

- [ ] **Step 4: Commit**

```bash
git add site/src/components/Dialogue.astro site/src/components/DialogueMessage.astro
git commit -m "feat(site): add Dialogue and DialogueMessage components for out-of-the-box mode"
```

---

### Task 9: Split View Components (im-a-nerd mode)

**Files:**
- Create: `site/src/components/SplitView.astro`
- Create: `site/src/components/FlowStep.astro`
- Create: `site/src/components/CodeStep.astro`
- Create: `site/src/components/Tension.astro`
- Create: `site/src/components/TerminalBlock.astro`

- [ ] **Step 1: Create TerminalBlock component**

Write to `site/src/components/TerminalBlock.astro`:

```astro
---
interface Props {
  title?: string;
}
const { title } = Astro.props;
---

<div class="terminal">
  <div class="terminal-dots">
    <span class="dot"></span>
    <span class="dot"></span>
    <span class="dot"></span>
    {title && <span class="terminal-title">{title}</span>}
  </div>
  <div class="terminal-body">
    <slot />
  </div>
</div>

<style>
  .terminal {
    background: var(--terminal-bg);
    border-radius: 4px;
    padding: var(--space-2);
  }
  .terminal-dots {
    display: flex;
    gap: 0.375rem;
    align-items: center;
    margin-bottom: var(--space-2);
  }
  .dot {
    width: 0.5rem;
    height: 0.5rem;
    border-radius: 50%;
    background: var(--text-accent);
    opacity: 0.4;
  }
  .terminal-title {
    font-size: var(--text-xs);
    color: var(--text-accent);
    margin-left: var(--space-1);
  }
  .terminal-body {
    font-size: var(--text-code);
    line-height: 2;
    color: #dddad2;
  }
  .terminal-body :global(.prompt) {
    color: #8e8b80;
  }
  .terminal-body :global(.dim) {
    color: #8e8b80;
  }
  .terminal-body :global(.success) {
    color: #9a8a6e;
  }
  .terminal-body :global(.value) {
    color: #dddad2;
  }
</style>
```

- [ ] **Step 2: Create FlowStep component**

Write to `site/src/components/FlowStep.astro`:

```astro
---
interface Props {
  title?: string;
}
const { title } = Astro.props;
---

<div class="flow-step">
  {title && <div class="flow-title">{title}</div>}
  <slot />
</div>

<style>
  .flow-step {
    margin-bottom: var(--space-2);
  }
  .flow-title {
    font-size: var(--text-xs);
    color: var(--text-accent);
    margin-bottom: var(--space-1);
  }
</style>
```

- [ ] **Step 3: Create CodeStep component**

Write to `site/src/components/CodeStep.astro`:

```astro
---
interface Props {
  title?: string;
  annotation?: string;
  mood?: 'clean' | 'debt';
}
const { title, annotation, mood = 'clean' } = Astro.props;
---

<div class="code-step">
  {title && <div class="code-title">{title}</div>}
  <div class="code-block">
    <slot />
  </div>
  {annotation && (
    <div class:list={['annotation', `annotation-${mood}`]}>
      {annotation}
    </div>
  )}
</div>

<style>
  .code-step {
    margin-bottom: var(--space-2);
  }
  .code-title {
    font-size: var(--text-xs);
    color: var(--text-accent);
    margin-bottom: var(--space-1);
  }
  .code-block {
    background: var(--terminal-bg);
    border-radius: 4px;
    padding: var(--space-2);
    font-size: var(--text-code);
    line-height: 1.9;
    color: #dddad2;
    overflow-x: auto;
  }
  .code-block :global(pre) {
    margin: 0;
    background: transparent !important;
    padding: 0 !important;
  }
  .code-block :global(code) {
    font-family: var(--font-mono);
    font-size: var(--text-code);
  }
  .annotation {
    font-size: var(--text-xs);
    margin-top: 0.25rem;
  }
  .annotation-clean {
    color: var(--success);
  }
  .annotation-debt {
    color: var(--warning);
  }
</style>
```

- [ ] **Step 4: Create Tension callout component**

Write to `site/src/components/Tension.astro`:

```astro
---
interface Props {
  left?: string;
  right?: string;
}
const { left = 'discipline', right = 'reality' } = Astro.props;
---

<div class="tension">
  <span class="tension-side tension-left">← {left}</span>
  <span class="tension-center">the tension is the point</span>
  <span class="tension-side tension-right">{right} →</span>
</div>

<style>
  .tension {
    background: var(--surface-hover);
    padding: var(--space-1) var(--space-2);
    display: flex;
    align-items: center;
    gap: var(--space-2);
    margin: var(--space-3) 0;
  }
  .tension-side {
    font-size: var(--text-sm);
    flex: 1;
  }
  .tension-left {
    color: var(--text-accent);
    text-align: center;
  }
  .tension-right {
    color: var(--warning);
    text-align: center;
  }
  .tension-center {
    font-size: var(--text-base);
    font-weight: 600;
    white-space: nowrap;
  }
</style>
```

- [ ] **Step 5: Create SplitView wrapper**

Write to `site/src/components/SplitView.astro`:

```astro
<div class="split-view mode-nerd">
  <slot />
</div>

<style>
  .split-view {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: var(--grid-gap);
    align-items: start;
  }
  .split-view > :global(.tension) {
    grid-column: 1 / -1;
  }
  @media (max-width: 768px) {
    .split-view {
      grid-template-columns: 1fr;
    }
  }
</style>
```

- [ ] **Step 6: Verify build**

Run: `cd site && npm run build`
Expected: Build succeeds

- [ ] **Step 7: Commit**

```bash
git add site/src/components/SplitView.astro site/src/components/FlowStep.astro site/src/components/CodeStep.astro site/src/components/Tension.astro site/src/components/TerminalBlock.astro
git commit -m "feat(site): add SplitView, FlowStep, CodeStep, Tension, and TerminalBlock components"
```

---

### Task 10: Usecase 01 — Evolving a System

**Files:**
- Create: `site/src/pages/cases/evolving-a-system.mdx`

- [ ] **Step 1: Create the MDX file**

Write to `site/src/pages/cases/evolving-a-system.mdx`:

```mdx
---
layout: ../../layouts/Usecase.astro
number: "01"
title: "Evolving a system"
subtitle: "Auth → roles → claims → granular permissions. How iterative delivery builds complex systems one layer at a time."
scenario: "You have a working auth system. Now the product needs roles, then claims, then granular permissions. Each layer depends on the previous one. How do you deliver iteratively without the codebase turning into a mess?"
next: { slug: "debt-after-a-sprint", title: "Debt after a sprint" }
prev: null
---

import Dialogue from '../../components/Dialogue.astro';
import Msg from '../../components/DialogueMessage.astro';
import SplitView from '../../components/SplitView.astro';
import FlowStep from '../../components/FlowStep.astro';
import CodeStep from '../../components/CodeStep.astro';
import Tension from '../../components/Tension.astro';
import TerminalBlock from '../../components/TerminalBlock.astro';

<Dialogue>
  <Msg from="you">/delivery add role-based access to auth</Msg>
  <Msg from="hs" tags={["brainstorm ✓", "plan ✓", "TDD ✓", "gate ✓"]}>
    Classified as **feature**. Using Superpowers pipeline.
    Brainstormed scope, wrote plan with 3 tasks, implemented with TDD.
    Acceptance gate: 3/3 criteria covered.
  </Msg>
  <Msg from="you">/delivery add claims and granular permissions</Msg>
  <Msg from="hs" tags={["builds on step 1", "fresh context"]}>
    Builds on roles layer. Fresh brainstorm, 5 tasks planned.
    Delivered — tagged delivery/claims-v1.
  </Msg>
  <Msg from="you">/removedebt auth last 2 features</Msg>
  <Msg from="hs" tags={["3 findings", "safety gates ✓"]}>
    Found 3 real items, filtered 8 speculative. Safety gates active.
    3/3 consolidated — 47/47 tests, zero regressions.
  </Msg>
</Dialogue>

<SplitView>
  <FlowStep title="First delivery">
    <TerminalBlock>
      <div><span class="prompt">&gt;</span> /delivery add role-based access to auth</div>
      <div class="dim">⟩ classified: <span class="value">feature</span></div>
      <div class="dim">⟩ pipeline: <span class="value">superpowers</span></div>
      <div class="dim">⟩ brainstorm → plan → TDD</div>
      <div class="success">✓ delivered</div>
    </TerminalBlock>
  </FlowStep>
  <CodeStep title="Clean code" annotation="clean, focused, tested ✓" mood="clean">
    <pre><code><span style="color: var(--code-comment)">// auth/roles.ts</span>
<span style="color: var(--code-keyword)">function</span> checkRole(user, role) {"{"}
  <span style="color: var(--code-keyword)">return</span> user.roles.includes(role)
{"}"}</code></pre>
  </CodeStep>

  <FlowStep title="Second delivery">
    <TerminalBlock>
      <div><span class="prompt">&gt;</span> /delivery add claims and granular permissions</div>
      <div class="dim">⟩ classified: <span class="value">feature</span></div>
      <div class="dim">⟩ 5 tasks planned</div>
      <div class="success">✓ delivered</div>
    </TerminalBlock>
  </FlowStep>
  <CodeStep title="Duplication creeping in" annotation="duplication creeping in — shipped fast, works, but..." mood="debt">
    <pre><code><span style="color: var(--code-comment)">// auth/permissions.ts</span>
<span style="color: var(--code-keyword)">function</span> checkPermission(user, perm) {"{"}
  <span style="color: var(--code-keyword)">const</span> role = getUserRole(user) <span style="color: var(--warning)">// ← duplicates checkRole logic</span>
  <span style="color: var(--code-keyword)">return</span> claims[role]?.includes(perm)
{"}"}</code></pre>
  </CodeStep>

  <Tension left="discipline" right="reality" />

  <FlowStep title="Consolidation">
    <TerminalBlock>
      <div><span class="prompt">&gt;</span> /removedebt auth last 2 features</div>
      <div class="dim">⟩ scanning 14 files...</div>
      <div class="dim">⟩ found <span class="value">3</span> concrete, filtered <span style="color: #636158">8 speculative</span></div>
      <div class="dim">⟩ snapshot: <span class="success">47 tests ✓</span></div>
      <div class="dim">⟩ executing...</div>
      <div class="dim">⟩ item 1: <span class="success">47/47 ✓</span></div>
      <div class="dim">⟩ item 2: <span class="success">47/47 ✓</span></div>
      <div class="dim">⟩ item 3: <span class="success">47/47 ✓</span></div>
      <div class="success">✓ consolidated — zero regressions</div>
    </TerminalBlock>
  </FlowStep>
  <CodeStep title="Unified" annotation="clean, unified, zero duplication ✓" mood="clean">
    <pre><code><span style="color: var(--code-comment)">// auth/access.ts</span> <span style="color: var(--success)">← unified</span>
<span style="color: var(--code-keyword)">function</span> checkAccess(user, requirement) {"{"}
  <span style="color: var(--code-keyword)">if</span> (requirement.type === <span style="color: var(--code-string)">'role'</span>)
    <span style="color: var(--code-keyword)">return</span> user.roles.includes(requirement.value)
  <span style="color: var(--code-keyword)">if</span> (requirement.type === <span style="color: var(--code-string)">'permission'</span>)
    <span style="color: var(--code-keyword)">return</span> resolveClaims(user).has(requirement.value)
{"}"}</code></pre>
  </CodeStep>
</SplitView>
```

- [ ] **Step 2: Verify build**

Run: `cd site && npm run build`
Expected: Build succeeds. `dist/cases/evolving-a-system/index.html` exists.

- [ ] **Step 3: Verify HTML output**

Run: `cd site && grep -c "checkRole" dist/cases/evolving-a-system/index.html && grep -c "out-of-the-box" dist/cases/evolving-a-system/index.html`
Expected: Both return at least 1

- [ ] **Step 4: Commit**

```bash
git add site/src/pages/cases/evolving-a-system.mdx
git commit -m "feat(site): add usecase 01 — evolving a system"
```

---

### Task 11: Usecases 02-05

**Files:**
- Create: `site/src/pages/cases/debt-after-a-sprint.mdx`
- Create: `site/src/pages/cases/production-fire.mdx`
- Create: `site/src/pages/cases/cycle-visibility.mdx`
- Create: `site/src/pages/cases/legacy-without-fear.mdx`

**IMPORTANT:** Replicate the exact same component patterns, HTML structure, and inline-styled code blocks from Task 10 (usecase 01). Use the same `<pre><code>` with `<span style="color: var(...)">` for syntax highlighting, `<TerminalBlock>` with `.prompt`, `.dim`, `.success`, `.value` classes for terminal output, and `<Tension>` between delivery and consolidation phases.

Follow the same structure as usecase 01. Each MDX file must:
1. Have frontmatter with `layout`, `number`, `title`, `subtitle`, `scenario`, `next`, `prev`
2. Import all needed components
3. Contain a `<Dialogue>` block with `<Msg>` exchanges for out-of-the-box mode
4. Contain a `<SplitView>` block with paired `<FlowStep>` / `<CodeStep>` entries for im-a-nerd mode
5. Include a `<Tension>` callout between the delivery and consolidation phases

Content for each usecase comes from the spec (section "Usecase Content Summary"):

- [ ] **Step 1: Create usecase 02 — Debt after a sprint**

Write to `site/src/pages/cases/debt-after-a-sprint.mdx`.

Frontmatter:
- `number: "02"`, `title: "Debt after a sprint"`, `subtitle: "6 features shipped, code feels heavy. Scan, filter noise, execute with safety nets."`
- `scenario: "You've been shipping fast — 6 features in two weeks. The code works, the tests pass, but you can feel the weight. Duplicated utilities, inconsistent naming, a helper that got copy-pasted three times. Time to consolidate."`
- `prev: { slug: "evolving-a-system", title: "Evolving a system" }`, `next: { slug: "production-fire", title: "Production fire" }`

Dialogue (out-of-the-box): Show `/status` revealing 6 features since last consolidation → Hypership suggests `/removedebt` → user runs `/removedebt last 6 features` → scan finds 5 real items, filters 12 speculative → user selects all → execution with safety gates, 89/89 tests passing.

Split view (im-a-nerd): Left shows /status output and /removedebt terminal flow. Right shows scattered copy-pasted `formatDate` helpers across 3 files → consolidated into single `utils/date.ts`.

- [ ] **Step 2: Create usecase 03 — Production fire**

Write to `site/src/pages/cases/production-fire.mdx`.

Frontmatter:
- `number: "03"`, `title: "Production fire"`, `subtitle: "Duplicate payments. Bug-as-test gate: reproduce first, then fix. No guessing."`
- `scenario: "Users are getting charged twice. The on-call Slack channel is lighting up. You need to fix this now — but Hypership won't let you skip the test."`
- `prev: { slug: "debt-after-a-sprint", title: "Debt after a sprint" }`, `next: { slug: "cycle-visibility", title: "Cycle visibility" }`

Dialogue: `/delivery fix duplicate payment processing` → classified as bugfix → bug-as-test gate activates → "Write a failing test first" → user writes test → RED confirmed → implement fix → GREEN → acceptance gate passes.

Split view: Left shows bugfix flow with gate enforcement. Right shows the failing test expecting single charge → payment handler with race condition in idempotency check → fix with mutex + test green.

- [ ] **Step 3: Create usecase 04 — Cycle visibility**

Write to `site/src/pages/cases/cycle-visibility.mdx`.

Frontmatter:
- `number: "04"`, `title: "Cycle visibility"`, `subtitle: "Tech lead wants to see the rhythm. /status shows health, signals when to consolidate."`
- `scenario: "You're leading a team of 4 engineers. Features are shipping, but you've lost track of when you last consolidated. Are you accumulating hidden debt? How do you know when to pause and clean up?"`
- `prev: { slug: "production-fire", title: "Production fire" }`, `next: { slug: "legacy-without-fear", title: "Legacy without fear" }`

Dialogue: `/status` → shows 8 features delivered, 0 consolidations, health signal RED → suggests `/removedebt` → user runs it → after consolidation → `/status` again → health GREEN.

Split view: Left shows /status output with feature count and health metrics. Right shows delivery-log.md entries and debt-log.md entries illustrating the cadence over time.

- [ ] **Step 4: Create usecase 05 — Legacy without fear**

Write to `site/src/pages/cases/legacy-without-fear.mdx`.

Frontmatter:
- `number: "05"`, `title: "Legacy without fear"`, `subtitle: "Inherited monolith. Module-scoped cleanup with snapshot, escape hatch, hard stop."`
- `scenario: "You inherited a payments module that nobody wants to touch. It works, but the code is tangled — 6 different patterns for the same operation, dead imports everywhere. You need to clean it without breaking the 124 tests that keep it alive."`
- `prev: { slug: "cycle-visibility", title: "Cycle visibility" }`, `next: null`

Dialogue: `/removedebt payments module` → scan finds 7 items → user selects 5 → safety gates activate: snapshot (124 tests), escape hatch (user declares 2 tests may break) → executing → item 3 triggers HARD STOP (unexpected test failure) → options: revert/investigate/continue → user investigates → finds cascading import → fixes → continues → done.

Split view: Left shows removedebt flow with all 3 safety gates in action, including the hard stop scenario. Right shows legacy code with 3 different charge patterns → unified `processCharge` → hard stop on unexpected test break → investigation reveals import chain → clean resolution.

- [ ] **Step 5: Verify build**

Run: `cd site && npm run build`
Expected: Build succeeds. All 5 case pages exist in `dist/cases/`.

- [ ] **Step 6: Verify all case pages exist**

Run: `cd site && ls dist/cases/`
Expected: 5 directories: `evolving-a-system/`, `debt-after-a-sprint/`, `production-fire/`, `cycle-visibility/`, `legacy-without-fear/`

- [ ] **Step 7: Commit**

```bash
git add site/src/pages/cases/
git commit -m "feat(site): add usecases 02-05 with dialogue and split-view content"
```

---

### Task 12: 404 Page + Final Validation

**Files:**
- Create: `site/src/pages/404.astro`

- [ ] **Step 1: Create 404 page**

Write to `site/src/pages/404.astro`:

```astro
---
import Base from '../layouts/Base.astro';
import Nav from '../components/Nav.astro';
import Footer from '../components/Footer.astro';
---

<Base title="404 — Hypership">
  <Nav />
  <main class="container not-found">
    <span class="label">404</span>
    <h1 class="title">Page not found.</h1>
    <p class="subtitle">Nothing here. Maybe you meant one of these:</p>
    <div class="links">
      <a href="/">← home</a>
      <a href="/#use-cases">use cases</a>
    </div>
  </main>
  <Footer />
</Base>

<style>
  .not-found {
    text-align: center;
    padding: var(--space-6) 0;
    min-height: 60vh;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
  }
  .title {
    font-size: var(--text-xl);
    font-weight: 700;
    margin-top: var(--space-2);
  }
  .subtitle {
    font-size: var(--text-base);
    color: var(--text-secondary);
    margin-top: var(--space-1);
  }
  .links {
    display: flex;
    gap: var(--space-3);
    margin-top: var(--space-4);
    font-size: var(--text-sm);
  }
  .links a {
    color: var(--text-accent);
  }
</style>
```

- [ ] **Step 2: Run final build**

Run: `cd site && npm run build`
Expected: Build succeeds with zero errors.

- [ ] **Step 3: Validate landing page output**

Run: `cd site && grep -c "delivery-obsessed" dist/index.html && grep -c "quick-start" dist/index.html && grep -c "use-cases" dist/index.html && grep -c "delivery-first methodology" dist/index.html`
Expected: All return at least 1

- [ ] **Step 4: Validate all usecase pages exist**

Run: `cd site && for d in evolving-a-system debt-after-a-sprint production-fire cycle-visibility legacy-without-fear; do test -f "dist/cases/$d/index.html" && echo "$d: OK" || echo "$d: MISSING"; done`
Expected: All 5 show "OK"

- [ ] **Step 5: Validate 404 page**

Run: `cd site && grep -c "404" dist/404.html`
Expected: At least 1

- [ ] **Step 6: Validate dark mode tokens in CSS output**

Run: `cd site && grep -c "prefers-color-scheme" dist/_assets/*.css`
Expected: At least 1

- [ ] **Step 7: Validate tab persistence script**

Run: `cd site && grep -c "hs-mode" dist/index.html`
Expected: At least 1

- [ ] **Step 8: Commit**

```bash
git add site/src/pages/404.astro
git commit -m "feat(site): add 404 page and complete site build"
```

- [ ] **Step 9: Final commit with all remaining changes**

```bash
git add -A site/
git commit -m "chore(site): ensure all site files are tracked"
```
