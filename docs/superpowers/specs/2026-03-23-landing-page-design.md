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
- Surface: `rgba(44,36,24,0.04-0.06)` (faint warm overlay)
- Borders/dividers: `rgba(138,122,101,0.12-0.25)` (subtle sepia lines)
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

- Logo/brand: 12px, weight 700, letter-spacing 1px
- Section labels: 9px, uppercase, letter-spacing 2-3px, accent color
- Headlines: 22-28px, weight 700, line-height 1.2
- Subheadlines: 16px, weight 600
- Body: 10-11px, line-height 1.6-1.7
- Code/terminal: 9-10px, line-height 1.8-2.0
- CTAs/buttons: 10-11px, letter-spacing 1px

## Landing Page Structure

### Navigation

Minimal top bar:
- Left: "hypership" logo text (weight 700)
- Right: links — "quick start", "use cases", "github ↗" (9px uppercase)

### Section 1: Hero

Centered layout:
- Label: "claude code plugin" (9px uppercase, accent color)
- Headline: **"delivery-obsessed engineering."** (28px, weight 700)
- Subtitle: **"Ship features. Kill debt. Works with whatever plugins and agents you already use."** (12px, secondary text)
- CTA: `$ claude install hypership` in a bordered box (1.5px solid accent)

### Section 2: Quick Start

Three-column layout — "Three commands. Zero config."

| Column | Label | Command | Description |
|--------|-------|---------|-------------|
| 01 — install | `$ claude install hypership` | Reads your CLAUDE.md. Adapts to your stack. Done. |
| 02 — deliver | `$ /delivery add roles to auth` | Classifies, plans, tests, ships. Your plugins, your pipeline. |
| 03 — consolidate | `$ /removedebt last 3 features` | Scans real debt. You decide. Safety gates protect you. |

Each column: warm surface background, left border accent (2px), label in 8px uppercase.

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

Each card: number label (8px uppercase), title (11px bold), description (9px), "VIEW CASE →" link.

### Section 5: Footer

Minimal:
- Left: "hypership" + "A Claude Code plugin. Open source."
- Right: "github ↗" + "install"

## Usecase Subpages

### Navigation

Breadcrumb style: "hypership / use cases / [case name]" left, "← all cases" right.

### Header

- Case number label (9px uppercase)
- Title (22px, weight 700)
- Subtitle (11px, secondary text)

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

- **Left column ("the flow")**: terminal-style dialogue showing commands and Hypership responses in dark terminal blocks (`background: #1b1b1c`)
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
│   │   ├── Base.astro            # HTML shell, dark mode, fonts, texture
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
  /* Light mode */
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

  /* Typography */
  --font-mono: 'JetBrains Mono', 'Fira Code', 'Cascadia Code', monospace;
  --text-xs: 8px;
  --text-sm: 9px;
  --text-base: 10px;
  --text-md: 11px;
  --text-lg: 16px;
  --text-xl: 22px;
  --text-hero: 28px;
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

    /* Code syntax (dark only) */
    --code-keyword: #c8a87a;
    --code-string: #a8c878;
    --code-comment: #636158;
  }
}
```

## Responsive Behavior

- **Desktop (>768px)**: full layout as described — 3-column quick start, 2-column usecase grid, split view in im-a-nerd mode
- **Tablet (768px)**: 2-column quick start collapses to stacked, usecase grid becomes single column, split view stacks (flow on top, code below)
- **Mobile (<480px)**: single column throughout, tabs remain functional, terminal blocks scroll horizontally if needed

## Acceptance Criteria

1. Landing page loads with all 5 sections in correct order
2. Quick start shows 3-step flow with real commands
3. Usecase cards link to individual subpages
4. Tab toggle persists across page navigation (localStorage)
5. out-of-the-box mode renders dialogue format with you/hs messages
6. im-a-nerd mode renders split view with flow + code columns
7. Dark mode activates via prefers-color-scheme with 30% warm palette
8. Paper texture visible in both modes (SVG noise + ruled lines)
9. All text in monospaced font stack
10. Responsive: stacks gracefully on mobile/tablet
11. Astro builds to fully static output, zero client JS except tab toggle + localStorage
12. All 5 usecase subpages have content for both modes
