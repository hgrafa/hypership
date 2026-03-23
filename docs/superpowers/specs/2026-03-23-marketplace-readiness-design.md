# Marketplace Readiness for Hypership

> Design spec for making hypership a polished, installable, marketplace-ready plugin.
> Approved during brainstorming session 2026-03-23.

## Problem Statement

Hypership has solid delivery orchestration and testing/safety gates, but lacks the structural polish that makes a plugin marketplace-ready:

1. **No session-start hook** — Claude doesn't know hypership exists until user types a command. Superpowers achieves "fluidity" by injecting skill context on every session start.
2. **Skill descriptions conflict with Superpowers** — triggers like "implement", "build", "ship" overlap with Superpowers' brainstorming skill, causing activation confusion.
3. **No configuration system** — no way for users to customize behavior (e.g., strict delivery mode).
4. **Plugin metadata incomplete** — missing keywords, homepage, repository, author object. Marketplace.json lacks version, source, owner.
5. **Cross-platform hook broken** — `grep -oP` is GNU-only, fails on macOS.
6. **README is functional, not commercial** — documents commands but doesn't sell the value proposition.

## Design Decisions

- **Approach:** Full Marketplace Package — all gaps addressed in one cycle.
- **Config strategy:** Separate `hypership.config.json` (not embedded in plugin.json).
- **Trigger conflict resolution:** `strictDeliveryFramework` toggle + delegative skill descriptions.
- **Hook pattern:** Follow Superpowers exactly (hooks.json + bash script + run-hook.cmd).
- **README style:** Marketplace-grade (value prop first, docs second).

---

## Part 1: Configuration System

### `hypership.config.json` (plugin root)

New file. User-editable configuration.

```json
{
  "strictDeliveryFramework": false
}
```

| Setting | Type | Default | Effect |
|---------|------|---------|--------|
| `strictDeliveryFramework` | boolean | `false` | When `true`, ALL implementation work must route through `/delivery`. Phase 0 classification is mandatory. No direct Superpowers bypass. When `false`, hypership suggests commands but Superpowers skills remain available for direct use. |

**Why a separate file:** `plugin.json` is the manifest — it declares what the plugin IS. Config declares how it BEHAVES. Mixing them creates ambiguity about which fields are spec-required vs custom. Separate file also allows future config expansion without touching the manifest.

**How it's consumed:** The session-start hook reads this file with `jq`. If `jq` is unavailable or the file is missing, defaults to `false`.

---

## Part 2: Session-Start Hook Infrastructure

### `hooks/hooks.json`

New file. Formal hook registration following Superpowers pattern.

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|clear|compact",
        "hooks": [
          {
            "type": "command",
            "command": "\"${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.cmd\" session-start"
          }
        ]
      }
    ]
  }
}
```

**Matcher:** Activates on session startup, after `/clear`, and after `/compact` — same events Superpowers hooks into.

### `hooks/run-hook.cmd`

New file. Windows-compatible wrapper that locates and executes the named hook script via bash. Follows the Superpowers pattern for cross-platform support.

### `hooks/session-start`

New file. Bash script that:

1. Detects `CLAUDE_PLUGIN_ROOT` from script location
2. Reads `hypership.config.json` via `jq` (fallback: `strictDeliveryFramework=false`)
3. Builds context string based on strict mode
4. Outputs JSON with `hookSpecificOutput.additionalContext`

**Strict mode context (`strictDeliveryFramework: true`):**

```
Hypership strict delivery framework is active. ALL implementation work MUST go through /delivery. Classify every user request using Phase 0 (feature/bugfix/chore/mixed/overloaded) before any action. Do not use TDD, brainstorming, or debugging skills directly — the delivery pipeline orchestrates them. Use /removedebt for debt consolidation. Use /status for cycle health.
```

**Suggestive mode context (`strictDeliveryFramework: false`, default):**

```
Hypership is installed. When the user describes implementation work (features, fixes, new endpoints, components), suggest /delivery — it orchestrates Superpowers with testing gates and delivery tracking. When they mention tech debt, consolidation, or refactoring, suggest /removedebt. /status shows delivery cycle health. Superpowers skills remain available for direct use.
```

**Why two modes:** Strict mode is for teams that want every change tracked through the delivery pipeline — no ad-hoc implementations that bypass gates and logging. Suggestive mode is for users who want hypership as an option alongside direct Superpowers usage.

### Cross-Platform Fix: `delivery-cycle-check.sh`

Existing file. Replace GNU-only `grep -oP` with POSIX-compatible alternative:

**Before:**
```bash
LAST_DATE=$(grep -oP '## \[\K[0-9]{4}-[0-9]{2}-[0-9]{2}' "$DEBT_LOG" | tail -1)
```

**After:**
```bash
LAST_DATE=$(grep '## \[' "$DEBT_LOG" | sed 's/.*## \[\([0-9-]*\).*/\1/' | tail -1)
```

Works on macOS (BSD grep/sed) and Linux (GNU grep/sed).

---

## Part 3: Skill Descriptions

### Problem

Current skill descriptions use generic triggers that conflict with Superpowers:

```yaml
# delivery SKILL.md (current)
description: >
  ALWAYS invoke when implementing features, fixing bugs, or delivering
  any functional change. Triggers: "implement", "build", "ship"...
```

These overlap with Superpowers' `brainstorming` ("any creative work") and `test-driven-development` ("any feature or bugfix"). When both plugins are installed, Claude may activate the wrong skill.

### Solution: Delegative Descriptions

Skills are invoked via `/delivery` and `/removedebt` commands. The session-start hook handles proactive suggestion. Descriptions just state what they are — no activation triggers.

**`skills/delivery/SKILL.md` new frontmatter:**
```yaml
---
name: delivery
description: >
  Invoked by /delivery command. Orchestrates feature delivery with Phase 0
  classification, testing gates, and Superpowers/Ralph Loop pipeline selection.
  Do not invoke directly — use the /delivery command.
---
```

**`skills/removedebt/SKILL.md` new frontmatter:**
```yaml
---
name: removedebt
description: >
  Invoked by /removedebt command. Analyzes and removes technical debt with
  safety gates (snapshot, escape hatch, hard stop). Scopes via git history.
  Do not invoke directly — use the /removedebt command.
---
```

**Why "Do not invoke directly":** Prevents Superpowers' skill-matching logic from activating hypership skills based on keyword overlap. The commands are the entry points; the hook is the suggestion engine.

---

## Part 4: Plugin Metadata

### `plugin.json` (enriched)

```json
{
  "name": "hypership",
  "version": "1.0.0",
  "description": "Ship features with testing gates. Consolidate debt with safety nets. AI-first delivery framework for senior engineering teams.",
  "author": {
    "name": "hgrafa"
  },
  "homepage": "https://github.com/hgrafa/hypership",
  "repository": "https://github.com/hgrafa/hypership",
  "license": "MIT",
  "keywords": [
    "delivery",
    "tech-debt",
    "testing-gates",
    "safety-gates",
    "tdd",
    "orchestration",
    "superpowers"
  ],
  "dependencies": {
    "plugins": ["superpowers@superpowers-marketplace"]
  }
}
```

Changes from current:
- `description`: action-oriented, marketplace-friendly (was explanatory)
- `author`: object with `name` field (was plain string) — matches Superpowers pattern
- `homepage` and `repository`: added for discoverability
- `keywords`: added for marketplace search

### `marketplace.json` (enriched)

```json
{
  "name": "hypership-marketplace",
  "description": "Marketplace for Hypership delivery framework",
  "owner": {
    "name": "hgrafa"
  },
  "plugins": [
    {
      "name": "hypership",
      "description": "Ship features with testing gates. Consolidate debt with safety nets. AI-first delivery framework for senior engineering teams.",
      "version": "1.0.0",
      "source": "./",
      "author": {
        "name": "hgrafa"
      }
    }
  ]
}
```

Changes from current:
- Added `owner` (marketplace-level author)
- Added `version` and `source` to plugin entry
- Added `author` to plugin entry
- `name` changed to `hypership-marketplace` (was just plugin name)
- `description` aligned with plugin.json

---

## Part 5: README Marketplace-Grade

Complete rewrite. Structure:

1. **Header** — name, tagline, badges (license, version, superpowers dependency)
2. **Why Hypership** — 3-sentence value proposition, two bullet points for the two commands
3. **Quick Start** — 3 steps: install, ship, consolidate. Copy-pasteable commands.
4. **Commands** — table with command, purpose
5. **Testing Gates** — table showing gate per type (bugfix, feature, chore, mixed)
6. **Safety Gates** — table showing 3 gates (snapshot, escape hatch, hard stop)
7. **Configuration** — `hypership.config.json` with settings table
8. **Philosophy** — 5 bullet points, each one sentence
9. **Stack** — required (Superpowers) and optional companions (Ralph Loop, Context7, GitHub MCP)
10. **License** — MIT

**Design principles for the README:**
- Value before documentation (why → how → what)
- Scannable tables over prose paragraphs
- 3-step quick start (cognitive limit for onboarding)
- Configuration inline (no separate docs for one setting)
- Philosophy as bullet points (manifesto feel, not essay)

---

## Part 6: Files Changed

### New Files

| File | Purpose |
|------|---------|
| `hypership.config.json` | User-editable configuration with `strictDeliveryFramework` toggle |
| `hooks/hooks.json` | Formal hook registration for SessionStart event |
| `hooks/session-start` | Bash script that reads config and injects context into Claude session |
| `hooks/run-hook.cmd` | Windows-compatible wrapper for hook execution |

### Modified Files

| File | Change |
|------|--------|
| `skills/delivery/SKILL.md` | Rewrite frontmatter description (delegative, no generic triggers) |
| `skills/removedebt/SKILL.md` | Rewrite frontmatter description (delegative, no generic triggers) |
| `.claude-plugin/plugin.json` | Add keywords, homepage, repository, author as object, rewrite description |
| `.claude-plugin/marketplace.json` | Add owner, version, source, author; rename to hypership-marketplace |
| `hooks/delivery-cycle-check.sh` | Replace `grep -oP` with POSIX-compatible `grep | sed` |
| `README.md` | Complete rewrite with marketplace-grade structure |

### Unchanged Files

| File | Why |
|------|-----|
| `commands/delivery.md` | Already delegates correctly to skill |
| `commands/removedebt.md` | Already delegates correctly to skill |
| `commands/status.md` | No change needed |
| `agents/debt-scanner.md` | No change needed |
| `skills/delivery/bug-as-test-prompt.md` | Prompt fragment, not affected |
| `skills/delivery/acceptance-gate-prompt.md` | Prompt fragment, not affected |
| `skills/removedebt/safety-gates.md` | Prompt fragment, not affected |

### Final Repo Structure

```
hypership/
├── .claude-plugin/
│   ├── plugin.json                    <- modified (enriched metadata)
│   └── marketplace.json              <- modified (enriched marketplace)
├── hypership.config.json              <- NEW (user config)
├── commands/
│   ├── delivery.md
│   ├── removedebt.md
│   └── status.md
├── skills/
│   ├── delivery/
│   │   ├── SKILL.md                  <- modified (description only)
│   │   ├── bug-as-test-prompt.md
│   │   └── acceptance-gate-prompt.md
│   └── removedebt/
│       ├── SKILL.md                  <- modified (description only)
│       └── safety-gates.md
├── agents/
│   └── debt-scanner.md
├── hooks/
│   ├── hooks.json                    <- NEW (hook registration)
│   ├── session-start                 <- NEW (context injection script)
│   ├── run-hook.cmd                  <- NEW (Windows wrapper)
│   └── delivery-cycle-check.sh       <- modified (cross-platform fix)
├── docs/
│   └── superpowers/
│       ├── plans/
│       │   └── 2026-03-23-testing-safety-gates.md
│       └── specs/
│           ├── 2026-03-23-testing-safety-gates-design.md
│           └── 2026-03-23-marketplace-readiness-design.md  <- THIS DOC
└── README.md                          <- modified (complete rewrite)
```

---

## Out of Scope (Future Cycles)

- CLAUDE.md for the hypership repo itself (conventions, test commands)
- Plugin self-tests (validate hooks fire, gates activate)
- `hooks.json` for delivery-cycle-check.sh (currently only fired by convention, not registered)
- Multi-platform testing (CI pipeline for macOS + Linux + Windows)
- Versioning strategy (semver automation, CHANGELOG.md)
- Additional config options (e.g., `deliveryLogPath`, `debtLogPath`)
