# Landing Page Design Spec

## Overview

A landing page and interactive documentation site for Hypership, a Claude Code plugin focused on delivery-obsessed engineering. The site serves two primary audiences: senior developers/tech leads who already use Claude Code and engineering managers evaluating tools for their teams.

The site consists of a focused landing page with quick start and usecase previews, plus dedicated subpages for each usecase with dual viewing modes.

## Technology

**Astro** — static output, MDX for doc pages, built-in syntax highlighting, full CSS control for custom aesthetic. Deployable to GitHub Pages, Netlify, or any static host.

Rationale: The site is a hybrid of documentation and product marketing for a free tool. Astro provides the content/page management of a docs framework without the opinionated design of VitePress/Docusaurus, allowing the custom Typewriter Craft aesthetic. No dynamic features needed.

## Visual Identity

### Typewriter Craft

The aesthetic evokes a professional technical document — monospaced typography, subtle paper texture, sepia-toned warmth. The feeling of a handcrafted engineering note, not a generic SaaS landing page.

### Light Mode

- Background: `#f5f0e8` (warm parchment)
- Texture: subtle paper grain via SVG noise filter (`opacity: 0.04`), faint ruled lines (`rgba(180,160,130,0.13)`) repeating every 28px
- Primary text: `#2c2418` (deep warm brown)
- Secondary text: `#6b5d4f` (muted brown)
- Accent/labels: `#8a7a65` (medium sepia)
- Surface: `--surface` at `rgba(44,36,24,0.04)`, `--surface-hover` at `rgba(44,36,24,0.06)`
- Borders: `--border` at `rgba(138,122,101,0.12)`, `--border-strong` at `rgba(138,122,101,0.25)`
- Success accent: `#9a8a6e` (warm olive for checkmarks/confirmations)
- Warning/debt accent: `#966b5a` (warm terracotta for code smell annotations)

### Dark Mode (30% warm)

Triggered by `prefers-color-scheme: dark`. Not a generic dark mode — "the same desk with the lights low." Graphite with a whisper of warmth.

- Background: `#1b1b1c` (near-neutral dark with faint warm tint)
- Texture: same paper grain and ruled lines, reduced opacity (`0.05`)
- Primary text: `#dddad2` (warm off-white)
- Secondary text: `#94918a` (muted warm gray)
- Accent/labels: `#8e8b80` (desaturated warm gray)
- Surface: `rgba(220,210,195,0.04)` (barely-there warm overlay)
- Borders: `rgba(108,108,98,0.05)` for rules, `rgba(130,135,145,0.10)` for dividers
- Success accent: `#9a8a6e` (same warm olive, works in both modes)
- Code keywords: `#c8a87a` (warm gold), `#a8c878` (muted green for strings)

### Typography

Font stack: `'JetBrains Mono', 'Fira Code', 'Cascadia Code', monospace`

All sizes use `rem` units (base 16px) to respect user font-size preferences.

- Logo/brand: 0.875rem (14px), weight 700, letter-spacing 1px
- Section labels: 0.6875rem (11px), uppercase, letter-spacing 2-3px, accent color
- Headlines: 1.75-2.25rem (28-36px), weight 700, line-height 1.2
- Subheadlines: 1.25rem (20px), weight 600
- Body: 0.9375rem (15px), line-height 1.6-1.7
- Code/terminal: 0.875rem (14px), line-height 1.8-2.0
- CTAs/buttons: 0.875rem (14px), letter-spacing 1px
- Small labels/tags: 0.75rem (12px)

## Landing Page Structure

### Navigation

Minimal top bar:
- Left: "hypership" logo text (weight 700)
- Right: links — "quick start", "use cases", "github ↗" (small labels, uppercase)

### Section 1: Hero

Centered layout:
- Label: "claude code plugin" (small labels, uppercase, accent color)
- Headline: **"delivery-obsessed engineering."** (hero size, weight 700)
- Subtitle: **"Ship features. Kill debt. Works with whatever plugins and agents you already use."** (body size, secondary text)
- CTA: `/plugin install hgrafa/hypership` in a bordered box (1.5px solid accent). Uses Claude Code prompt prefix `>` instead of shell `$` to distinguish slash commands from shell commands.

### Section 2: Quick Start

Three-column layout — "Three commands. Zero config."

| Column | Label | Command | Description |
|--------|-------|---------|-------------|
| 01 — install | `> /plugin install hgrafa/hypership` | Reads your CLAUDE.md. Adapts to your stack. Done. |
| 02 — deliver | `> /delivery add roles to auth` | Classifies, plans, tests, ships. Your plugins, your pipeline. |
| 03 — consolidate | `> /removedebt last 3 features` | Scans real debt. You decide. Safety gates protect you. |

All commands use `>` prompt prefix (Claude Code input), not `$` (shell). Each column: warm surface background, left border accent (2px), label in small uppercase.

### Section 3: Philosophy

Title: **"A delivery-first methodology."** (16px, weight 600)

Three principles side by side:

1. **"Features and debt are separate."** — Don't refactor during feature delivery. Ship first, consolidate deliberately.
2. **"Debt is concrete, not speculative."** — Grep-able duplication, actual unused code. Not "could be more generic."
3. **"Senior engineers decide."** — Tool proposes, you dispose. Every finding has a skip option.

### Section 4: Use Cases

Title: **"See it in action."**
Subtitle: "Real scenarios, real workflows. Each one has a visual walkthrough and a terminal deep-dive."

Grid of 5 cards (2 columns, last row centered or full-width):

| # | Title | Preview text |
|---|-------|-------------|
| 01 | Evolving a system | Auth → roles → claims → granular permissions. Iterative delivery building layer by layer. |
| 02 | Debt after a sprint | 6 features shipped, code feels heavy. Scan, filter noise, execute with safety nets. |
| 03 | Production fire | Duplicate payments. Bug-as-test gate: reproduce first, then fix. No guessing. |
| 04 | Cycle visibility | Tech lead wants to see the rhythm. /status shows health, signals when to consolidate. |
| 05 | Legacy without fear | Inherited monolith. Module-scoped cleanup with snapshot, escape hatch, hard stop. |

Each card: number label (small labels, uppercase), title (body bold), description (body), "VIEW CASE →" link.

### Section 5: Footer

Minimal:
- Left: "hypership" + "A Claude Code plugin. Open source."
- Right: "github ↗" + "install"

## Usecase Subpages

### Navigation

Breadcrumb style: "hypership / use cases / [case name]" left, "← all cases" right.

### Header

- Case number label (small labels, uppercase)
- Title (xl size, weight 700)
- Subtitle (body, secondary text)

### Dual Mode Tabs

Tab bar below header with two modes:

- **"out-of-the-box"** — default active tab
- **"im-a-nerd"** — kebab-case styling, intentionally casual

Active tab: primary text color, weight 600, 2px bottom border.
Inactive tab: accent color, no border.

The user's selection persists across page navigations (localStorage).

### Mode: out-of-the-box (Dialogue / Conversational)

Content presented as a dialogue between "you" and "hs" (hypership):

- **"you" messages**: user avatar (circle, initials), message in warm surface bubble with rounded corners (2px top-left, 8px others)
- **"hs" messages**: dark avatar circle with "hs" initials, response bubble, followed by status tags (small pills showing "brainstorm ✓", "plan ✓", "TDD ✓", "gate ✓")

The dialogue format:
1. Shows the interaction as it really happens — a conversation
2. Familiar to the LLM-native audience
3. Naturally paces the story
4. Can be later complemented with NotebookLM-generated video walkthroughs

### Mode: im-a-nerd (Split View — Flow + Code)

Split view with two columns:

- **Left column ("the flow")**: terminal-style dialogue showing commands and Hypership responses in dark terminal blocks (`background: var(--terminal-bg)`)
- **Right column ("the code")**: pseudocode showing what's emerging in the codebase — clean code after step 1, duplication/shortcuts appearing after step 2, unified clean code after removedebt

A callout bar between steps reads: **"the tension is the point"** with "← discipline" on the left and "reality →" on the right.

This creates a visual argument for why /removedebt exists:
- Step 1: Clean, focused code (shipped with discipline)
- Step 2: Natural duplication emerging (shipped fast, works, but...)
- Step 3: Consolidated code (debt removed deliberately)

Code syntax uses:
- Keywords: `#c8a87a` (warm gold)
- Strings: `#a8c878` (muted green)
- Comments: `#8e8b80` (muted gray) for neutral annotations
- Debt annotations: `#966b5a` (warm terracotta) for "← duplicates X logic"
- Clean annotations: `#9a8a6e` (warm olive) for "← unified"

### Navigation Footer

Between usecase pages: "← all cases" left, "next: [case name] →" right.

## Content Authoring Format (MDX)

Each usecase is an MDX file with frontmatter metadata and Astro components for dual-mode rendering. Example structure for `evolving-a-system.mdx`:

```mdx
---
number: "01"
title: "Evolving a system"
subtitle: "Auth → roles → claims → granular permissions. How iterative delivery builds complex systems one layer at a time."
scenario: "You have a working auth system. Now the product needs roles, then claims, then granular permissions."
next: { slug: "debt-after-a-sprint", title: "Debt after a sprint" }
prev: null
---

import { Dialogue, Msg, SplitView, FlowStep, CodeStep, Tension } from '../../components'

{/* out-of-the-box mode */}
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

{/* im-a-nerd mode */}
<SplitView>
  <FlowStep title="First delivery">
    ```terminal
    > /delivery add role-based access to auth
    ⟩ classified: feature
    ⟩ pipeline: superpowers
    ⟩ brainstorm → plan → TDD
    ✓ delivered
    ```
  </FlowStep>
  <CodeStep title="Clean code" annotation="clean, focused, tested ✓" mood="clean">
    ```ts
    // auth/roles.ts
    function checkRole(user, role) {
      return user.roles.includes(role)
    }
    ```
  </CodeStep>

  <FlowStep title="Second delivery">
    ```terminal
    > /delivery add claims and granular permissions
    ⟩ classified: feature
    ⟩ 5 tasks planned
    ✓ delivered
    ```
  </FlowStep>
  <CodeStep title="Duplication creeping in" annotation="duplication creeping in — shipped fast, works, but..." mood="debt">
    ```ts
    // auth/permissions.ts
    function checkPermission(user, perm) {
      const role = getUserRole(user) // ← duplicates checkRole logic
      return claims[role]?.includes(perm)
    }
    ```
  </CodeStep>

  <Tension left="discipline" right="reality" />

  <FlowStep title="Consolidation">
    ```terminal
    > /removedebt auth last 2 features
    ⟩ found 3 concrete, filtered 8 speculative
    ⟩ snapshot: 47 tests ✓
    ⟩ executing... 47/47 ✓ per item
    ✓ consolidated — zero regressions
    ```
  </FlowStep>
  <CodeStep title="Unified" annotation="clean, unified, zero duplication ✓" mood="clean">
    ```ts
    // auth/access.ts ← unified
    function checkAccess(user, requirement) {
      if (requirement.type === 'role')
        return user.roles.includes(requirement.value)
      if (requirement.type === 'permission')
        return resolveClaims(user).has(requirement.value)
    }
    ```
  </CodeStep>
</SplitView>
```

### Component Props

- `<Dialogue>`: wrapper for out-of-the-box mode. Only visible when that tab is active.
- `<Msg from="you"|"hs" tags={[...]}>`: single dialogue message. `from` determines avatar and alignment. `tags` renders status pills below hs messages.
- `<SplitView>`: wrapper for im-a-nerd mode. Renders paired FlowStep/CodeStep columns.
- `<FlowStep title>`: left-column terminal block with title annotation.
- `<CodeStep title annotation mood="clean"|"debt">`: right-column code block. `mood` controls annotation color (clean=`--success`, debt=`--warning`).
- `<Tension left right>`: centered callout bar between step pairs.

## Usecase Content Summary

### 01 — Evolving a system

**Scenario**: Existing auth system needs roles, then claims, then granular permissions.

**out-of-the-box flow**:
1. you: /delivery add role-based access → hs: classified feature, brainstorm → plan → TDD → gate ✓
2. you: /delivery add claims and permissions → hs: builds on roles, fresh context, delivered ✓
3. you: /removedebt auth last 2 features → hs: 3 real items, 8 filtered, safety gates, zero regressions ✓

**im-a-nerd split**:
- Left: terminal commands and outputs
- Right: `checkRole` clean → `checkPermission` duplicating logic → unified `checkAccess`

### 02 — Debt after a sprint

**Scenario**: 6 features shipped, code feels heavy. Time to consolidate.

**out-of-the-box flow**:
1. hs (via hook): "6 features since last consolidation. Consider /removedebt"
2. you: /removedebt last 6 features → hs: scans, finds concrete debt, presents with effort estimates
3. you: selects items → hs: executes with safety gates, reports results

**im-a-nerd split**:
- Left: /status showing feature count, /removedebt scan and execution
- Right: scattered shortcuts across multiple files → consolidated patterns

### 03 — Production fire

**Scenario**: Duplicate payments bug in production.

**out-of-the-box flow**:
1. you: /delivery fix duplicate payment processing → hs: classified bugfix, activates bug-as-test gate
2. hs: "Write a failing test that reproduces the bug first"
3. you: test written → hs: RED confirmed, now implement fix → GREEN ✓

**im-a-nerd split**:
- Left: bugfix flow with bug-as-test gate enforcement
- Right: failing test → payment handler with the subtle race condition → fix with test green

### 04 — Cycle visibility

**Scenario**: Tech lead wants to understand the team's delivery rhythm.

**out-of-the-box flow**:
1. you: /status → hs: shows features delivered, last consolidation, health signal
2. hs: recommends /removedebt for specific modules
3. Narrative about using delivery-log.md and debt-log.md as artifacts

**im-a-nerd split**:
- Left: /status output with metrics
- Right: delivery-log.md and debt-log.md entries showing the cadence

### 05 — Legacy without fear

**Scenario**: Inherited monolith, need to clean modules without breaking anything.

**out-of-the-box flow**:
1. you: /removedebt payments module → hs: scans module scope, finds debt
2. hs: activates safety gates — snapshot (124 tests), escape hatch declaration, hard stop protocol
3. Execution with test comparison after each item, one hard stop triggered, options presented

**im-a-nerd split**:
- Left: removedebt flow with safety gates in action, including a hard stop scenario
- Right: legacy spaghetti → incremental cleanup → hard stop on unexpected test break → investigation → clean resolution

## File Structure (Astro Project)

```
site/
├── astro.config.mjs
├── package.json
├── public/
│   └── fonts/                    # JetBrains Mono (self-hosted)
├── src/
│   ├── layouts/
│   │   ├── Base.astro            # HTML shell, dark mode, fonts, texture, OG meta
│   │   ├── Landing.astro         # Landing page layout
│   │   └── Usecase.astro         # Usecase subpage layout with tabs
│   ├── components/
│   │   ├── Nav.astro             # Top navigation
│   │   ├── Hero.astro            # Hero section
│   │   ├── QuickStart.astro      # Quick start 3-column
│   │   ├── Philosophy.astro      # 3 principles
│   │   ├── UsecaseGrid.astro     # Usecase preview cards
│   │   ├── Footer.astro          # Footer
│   │   ├── ModeTabs.astro        # out-of-the-box / im-a-nerd tabs
│   │   ├── Dialogue.astro        # Chat-style message component
│   │   ├── DialogueMessage.astro # Individual message (you/hs)
│   │   ├── SplitView.astro       # Left/right flow+code container
│   │   ├── TerminalBlock.astro   # Dark terminal code block
│   │   └── CodeBlock.astro       # Syntax-highlighted code block
│   ├── pages/
│   │   ├── index.astro           # Landing page
│   │   ├── 404.astro             # Not found page (Typewriter Craft styled)
│   │   └── cases/
│   │       ├── evolving-a-system.mdx
│   │       ├── debt-after-a-sprint.mdx
│   │       ├── production-fire.mdx
│   │       ├── cycle-visibility.mdx
│   │       └── legacy-without-fear.mdx
│   └── styles/
│       ├── global.css            # Typewriter Craft theme, textures, dark mode
│       └── tokens.css            # CSS custom properties (colors, spacing)
└── .gitignore
```

## Design Tokens (CSS Custom Properties)

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
  --text-xs: 0.75rem;    /* 12px — tags, small labels */
  --text-sm: 0.8125rem;  /* 13px — section labels */
  --text-base: 0.9375rem;/* 15px — body text */
  --text-md: 1rem;       /* 16px — body emphasis */
  --text-lg: 1.25rem;    /* 20px — subheadlines */
  --text-xl: 1.75rem;    /* 28px — page titles */
  --text-hero: 2.25rem;  /* 36px — hero headline */
  --text-code: 0.875rem; /* 14px — code/terminal */

  /* Spacing scale (8px base) */
  --space-1: 0.5rem;   /* 8px */
  --space-2: 1rem;     /* 16px */
  --space-3: 1.5rem;   /* 24px */
  --space-4: 2rem;     /* 32px */
  --space-5: 3rem;     /* 48px */
  --space-6: 4rem;     /* 64px */

  /* Layout */
  --content-max-width: 960px;
  --content-padding: var(--space-4); /* 32px horizontal padding */
  --section-gap: var(--space-5);     /* 48px between sections */
  --grid-gap: var(--space-2);        /* 16px grid/card gap */
  --column-gap: var(--space-3);      /* 24px between columns */
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
    --terminal-bg: #141415; /* darker than --bg for contrast */

    /* Code syntax (dark) */
    --code-keyword: #c8a87a;
    --code-string: #a8c878;
    --code-comment: #636158;
  }
}
```

## Responsive Behavior

- **Desktop (>768px)**: full layout as described — 3-column quick start, 2-column usecase grid, split view in im-a-nerd mode
- **Tablet (480-768px)**: quick start collapses to stacked, usecase grid becomes single column, split view stacks (flow on top, code below)
- **Mobile (<480px)**: single column throughout, tabs remain functional, terminal blocks scroll horizontally if needed

## Metadata & SEO

`Base.astro` includes:
- `<title>` and `<meta name="description">` per page (frontmatter-driven)
- Open Graph tags: `og:title`, `og:description`, `og:type` ("website"), `og:image` (parchment-textured card with logo)
- Twitter card: `twitter:card` ("summary_large_image")
- Favicon: monospaced "h" glyph on parchment background, provided as SVG + PNG fallback
- Canonical URL

### Tab Persistence Without Flash

`Base.astro` includes an inline `<script>` in `<head>` (before paint) that reads localStorage and sets a `data-mode` attribute on `<html>`. CSS uses this attribute to show the correct tab content on first render, avoiding flash-of-wrong-content.

## Acceptance Criteria

1. Landing page loads with all 5 sections in correct order
2. Quick start shows 3-step flow with correct commands (using `>` prefix for Claude Code slash commands)
3. Usecase cards link to individual subpages
4. Tab toggle persists across page navigation (localStorage) without flash-of-wrong-content
5. out-of-the-box mode renders dialogue format with you/hs messages
6. im-a-nerd mode renders split view with flow + code columns
7. Dark mode activates via prefers-color-scheme with 30% warm palette
8. Paper texture visible in both modes (SVG noise + ruled lines)
9. All text in monospaced font stack using rem units
10. Responsive: stacks gracefully at 480px and 768px breakpoints
11. Astro builds to fully static output, zero client JS except tab toggle + localStorage
12. All 5 usecase subpages have content for both modes using the MDX component schema
13. Lighthouse performance score >= 95 on landing page
14. Open Graph and Twitter Card meta tags present on all pages
15. 404 page renders in Typewriter Craft aesthetic
16. Install command matches actual plugin registry (`/plugin install hgrafa/hypership`)
