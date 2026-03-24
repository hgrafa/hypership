# Hypership

> Ship features with testing gates. Consolidate debt with safety nets.

![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)
![Version: 1.0.0](https://img.shields.io/badge/Version-1.0.0-green.svg)
![Requires: Superpowers](https://img.shields.io/badge/Requires-Superpowers-purple.svg)

AI-first delivery framework for senior engineering teams.
Two commands. One philosophy: **obsessively ship, deliberately consolidate.**

---

## Why Hypership

Every feature you ship accumulates debt. Every debt removal risks breaking what you shipped. Hypership solves both sides:

- **`/delivery`** — classifies your work (feature, bugfix, chore, mixed), applies testing gates, orchestrates Superpowers or Ralph Loop, logs everything
- **`/removedebt`** — scopes debt via git history, presents findings with strategic questions, executes with safety gates (snapshot, escape hatch, hard stop)

You decide what to cut. Hypership executes with guardrails.

## Quick Start

### 1. Install

```bash
/plugin install hgrafa/hypership
```

Superpowers installs automatically as a dependency.

### 2. Ship something

```
/delivery add Stripe refund flow with webhook handling
```

Hypership classifies your request, selects the right pipeline, implements with testing gates, and logs the delivery.

### 3. Consolidate

```
/removedebt since last consolidation
```

Scans the git diff, finds real debt, asks you what to fix, and executes with safety nets.

## Commands

| Command | Purpose |
|---------|---------|
| `/delivery [description]` | Orchestrate feature/bugfix delivery with testing gates |
| `/removedebt [context]` | Analyze and remove tech debt with safety gates |
| `/status` | Show delivery cycle health |

## Testing Gates (`/delivery`)

| Type | Gate | Enforces |
|------|------|----------|
| Bugfix | Bug-as-Test | Reproduce bug as failing test before fixing |
| Feature | Acceptance Coverage | Tests map 1:1 to acceptance criteria from brainstorm |
| Chore | TDD only | Standard Superpowers TDD, no extra gates |
| Mixed | Per-item | Decomposes prompt, each item gets its type-appropriate gate |

Non-reproducible bugs don't block — they get 3 fallback strategies (defense-in-depth, observability, hypothesis-driven hardening).

## Safety Gates (`/removedebt`)

| Gate | When | What |
|------|------|------|
| Snapshot | Before execution | Captures full test baseline (pass/fail/skip/coverage) |
| Escape Hatch | After snapshot | Declare which tests may break intentionally (immutable once execution starts) |
| Hard Stop | After each category | Blocks on unexpected test failures with options: revert, investigate, or continue |

## Configuration

Create or edit `hypership.config.json` in the plugin root:

```json
{
  "strictDeliveryFramework": false
}
```

| Setting | Default | Effect |
|---------|---------|--------|
| `strictDeliveryFramework` | `false` | When `true`, ALL implementation work must go through `/delivery`. No direct Superpowers bypass. |

## Philosophy

- Features and debt removal are **separate activities**
- Debt is **concrete** (detectable via grep), not speculative
- Senior engineers **decide** — tool proposes, you dispose
- **No bugfix without evidence** — reproduce first, harden if you can't
- **No refactor without safety net** — snapshot, declare breaks, hard stop on surprises

## Stack

**Required:**
- [Superpowers](https://github.com/obra/superpowers) — quality backbone (TDD, debugging, code review, planning)

**Optional companions** (auto-detected when present):
- [Ralph Loop](https://github.com/snarktank/ralph) — AFK autonomous delivery mode
- [Context7](https://github.com/upstreamapi/context7) — docs lookup during implementation
- GitHub MCP — auto-fetch issues, auto-create PRs

## License

MIT
