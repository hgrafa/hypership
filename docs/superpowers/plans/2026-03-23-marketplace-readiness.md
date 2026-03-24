# Marketplace Readiness Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make hypership a polished, marketplace-ready plugin with session-start context injection, configuration system, enriched metadata, and marketplace-grade README.

**Architecture:** 4 new files (config, hooks.json, session-start script, run-hook.cmd), 6 modified files (plugin.json, marketplace.json, 2 skill descriptions, delivery-cycle-check.sh, README). All changes are config/markdown/shell — no application code.

**Tech Stack:** Bash (hooks), JSON (config/metadata), Markdown (README/skills)

**Spec:** `docs/superpowers/specs/2026-03-23-marketplace-readiness-design.md`

---

## File Structure

### New Files

| File | Responsibility |
|------|---------------|
| `hypership.config.json` | User-editable plugin configuration (`strictDeliveryFramework` toggle) |
| `hooks/hooks.json` | SessionStart hook registration (Claude Code convention) |
| `hooks/session-start` | Bash script: reads config, injects context into Claude session |
| `hooks/run-hook.cmd` | Cross-platform polyglot wrapper (batch + bash) for hook execution |

### Modified Files

| File | Change |
|------|--------|
| `.claude-plugin/plugin.json` | Enrich metadata: author object, keywords, homepage, repository, description |
| `.claude-plugin/marketplace.json` | Enrich: top-level name/owner/description, plugin version/source/author |
| `skills/delivery/SKILL.md` | Rewrite frontmatter description (delegative, no generic triggers) |
| `skills/removedebt/SKILL.md` | Rewrite frontmatter description (delegative, no generic triggers) |
| `hooks/delivery-cycle-check.sh` | Replace `grep -oP` (GNU-only) with POSIX `grep | sed` |
| `README.md` | Complete rewrite: marketplace-grade with value prop, badges, quick start |

---

### Task 1: Create configuration file

**Files:**
- Create: `hypership.config.json`

- [ ] **Step 1: Create `hypership.config.json` at plugin root**

```json
{
  "strictDeliveryFramework": false
}
```

- [ ] **Step 2: Verify the JSON is valid**

Run: `cat hypership.config.json | python3 -c "import sys,json; json.load(sys.stdin); print('OK')" 2>&1 || echo "INVALID"`
Expected: `OK`

- [ ] **Step 3: Commit**

```bash
git add hypership.config.json
git commit -m "feat: add hypership.config.json with strictDeliveryFramework toggle"
```

---

### Task 2: Create hooks.json for SessionStart registration

**Files:**
- Create: `hooks/hooks.json`

- [ ] **Step 1: Create `hooks/hooks.json`**

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|clear|compact",
        "hooks": [
          {
            "type": "command",
            "command": "\"${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.cmd\" session-start",
            "async": false
          }
        ]
      }
    ]
  }
}
```

Key details:
- `matcher`: fires on session startup, after `/clear`, and after `/compact`
- `async: false`: ensures context is injected before user interacts
- `${CLAUDE_PLUGIN_ROOT}`: environment variable set by Claude Code at runtime
- Claude Code discovers `hooks/hooks.json` by convention at the plugin root — no plugin.json modification needed

- [ ] **Step 2: Verify the JSON is valid**

Run: `cat hooks/hooks.json | python3 -c "import sys,json; json.load(sys.stdin); print('OK')" 2>&1 || echo "INVALID"`
Expected: `OK`

- [ ] **Step 3: Commit**

```bash
git add hooks/hooks.json
git commit -m "feat: add hooks.json for SessionStart registration"
```

---

### Task 3: Create run-hook.cmd (cross-platform hook wrapper)

**Files:**
- Create: `hooks/run-hook.cmd`

- [ ] **Step 1: Copy `run-hook.cmd` verbatim from Superpowers**

Source: `~/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.5/hooks/run-hook.cmd`

The file is a polyglot (batch + bash) that works on Windows and Unix:

```
: << 'CMDBLOCK'
@echo off
REM Cross-platform polyglot wrapper for hook scripts.
REM On Windows: cmd.exe runs the batch portion, which finds and calls bash.
REM On Unix: the shell interprets this as a script (: is a no-op in bash).
REM
REM Hook scripts use extensionless filenames (e.g. "session-start" not
REM "session-start.sh") so Claude Code's Windows auto-detection -- which
REM prepends "bash" to any command containing .sh -- doesn't interfere.
REM
REM Usage: run-hook.cmd <script-name> [args...]

if "%~1"=="" (
    echo run-hook.cmd: missing script name >&2
    exit /b 1
)

set "HOOK_DIR=%~dp0"

REM Try Git for Windows bash in standard locations
if exist "C:\Program Files\Git\bin\bash.exe" (
    "C:\Program Files\Git\bin\bash.exe" "%HOOK_DIR%%~1" %2 %3 %4 %5 %6 %7 %8 %9
    exit /b %ERRORLEVEL%
)
if exist "C:\Program Files (x86)\Git\bin\bash.exe" (
    "C:\Program Files (x86)\Git\bin\bash.exe" "%HOOK_DIR%%~1" %2 %3 %4 %5 %6 %7 %8 %9
    exit /b %ERRORLEVEL%
)

REM Try bash on PATH (e.g. user-installed Git Bash, MSYS2, Cygwin)
where bash >nul 2>nul
if %ERRORLEVEL% equ 0 (
    bash "%HOOK_DIR%%~1" %2 %3 %4 %5 %6 %7 %8 %9
    exit /b %ERRORLEVEL%
)

REM No bash found - exit silently rather than error
REM (plugin still works, just without SessionStart context injection)
exit /b 0
CMDBLOCK

# Unix: run the named script directly
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPT_NAME="$1"
shift
exec bash "${SCRIPT_DIR}/${SCRIPT_NAME}" "$@"
```

This file is generic (not Superpowers-specific) and works as-is for any plugin.

- [ ] **Step 2: Set executable permission and verify**

```bash
chmod +x hooks/run-hook.cmd
```

Run: `bash -n hooks/run-hook.cmd && echo "bash syntax OK"`
Expected: `bash syntax OK` (validates the bash portion; the batch portion cannot be syntax-checked on Unix)

- [ ] **Step 3: Commit**

```bash
git add hooks/run-hook.cmd
git commit -m "feat: add run-hook.cmd cross-platform hook wrapper"
```

---

### Task 4: Create session-start hook script

**Files:**
- Create: `hooks/session-start`

This is the core hook. It reads `hypership.config.json`, determines strict vs suggestive mode, and injects context into the Claude session.

- [ ] **Step 1: Create `hooks/session-start`**

```bash
#!/usr/bin/env bash
# SessionStart hook for hypership plugin
# Reads config and injects delivery framework context into Claude session.

set -euo pipefail

# Determine plugin root directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Read config: strictDeliveryFramework
# Uses grep (no jq dependency). Any value other than literal true = false (fail-open).
CONFIG_FILE="${PLUGIN_ROOT}/hypership.config.json"
STRICT_MODE=false
if [ -f "$CONFIG_FILE" ] && grep -q '"strictDeliveryFramework"[[:space:]]*:[[:space:]]*true' "$CONFIG_FILE" 2>/dev/null; then
    STRICT_MODE=true
fi

# Build context based on mode
if [ "$STRICT_MODE" = "true" ]; then
    CONTEXT="Hypership strict delivery framework is active. ALL implementation work MUST go through /delivery. Classify every user request using Phase 0 (feature/bugfix/chore/mixed/overloaded) before any action. Do not use TDD, brainstorming, or debugging skills directly — the delivery pipeline orchestrates them. Use /removedebt for debt consolidation. Use /status for cycle health."
else
    CONTEXT="Hypership is installed. When the user describes implementation work (features, fixes, new endpoints, components), suggest /delivery — it orchestrates Superpowers with testing gates and delivery tracking. When they mention tech debt, consolidation, or refactoring, suggest /removedebt. /status shows delivery cycle health. Superpowers skills remain available for direct use."
fi

# Escape string for JSON embedding using bash parameter substitution.
# Each ${s//old/new} is a single C-level pass — matches Superpowers pattern.
escape_for_json() {
    local s="$1"
    s="${s//\\/\\\\}"
    s="${s//\"/\\\"}"
    s="${s//$'\n'/\\n}"
    s="${s//$'\r'/\\r}"
    s="${s//$'\t'/\\t}"
    printf '%s' "$s"
}

session_context=$(escape_for_json "$CONTEXT")

# Output context injection as JSON.
# Uses printf instead of heredoc to work around bash 5.3+ bug with large content.
# Platform branching: Cursor vs Claude Code vs fallback.
if [ -n "${CURSOR_PLUGIN_ROOT:-}" ]; then
    printf '{\n  "additional_context": "%s"\n}\n' "$session_context"
elif [ -n "${CLAUDE_PLUGIN_ROOT:-}" ]; then
    printf '{\n  "hookSpecificOutput": {\n    "hookEventName": "SessionStart",\n    "additionalContext": "%s"\n  }\n}\n' "$session_context"
else
    printf '{\n  "additional_context": "%s"\n}\n' "$session_context"
fi

exit 0
```

Key implementation details:
- `grep -q` for config reading: no `jq` dependency, POSIX-compatible
- `escape_for_json()`: handles backslashes, quotes, newlines, carriage returns, tabs
- `printf` instead of heredoc: avoids bash 5.3+ bug
- Platform branching: `CURSOR_PLUGIN_ROOT` → Cursor, `CLAUDE_PLUGIN_ROOT` → Claude Code, else → fallback
- Multi-plugin safe: Claude Code concatenates `additionalContext` from multiple plugins

- [ ] **Step 2: Set executable permission and verify bash syntax**

```bash
chmod +x hooks/session-start
```

Run: `bash -n hooks/session-start`
Expected: no output (no syntax errors)

- [ ] **Step 3: Test suggestive mode output (default config)**

Note: This step requires `hypership.config.json` to exist (created in Task 1). If it doesn't exist yet, the script defaults to suggestive mode — which is the correct behavior we're testing.

Run: `CLAUDE_PLUGIN_ROOT=/tmp bash hooks/session-start | python3 -c "import sys,json; d=json.load(sys.stdin); print('OK' if 'hookSpecificOutput' in d else 'FAIL')"`
Expected: `OK`

- [ ] **Step 4: Test strict mode output**

Run: `sed -i 's/false/true/' hypership.config.json && CLAUDE_PLUGIN_ROOT=/tmp bash hooks/session-start | python3 -c "import sys,json; d=json.load(sys.stdin); ctx=d['hookSpecificOutput']['additionalContext']; print('OK' if 'MUST go through' in ctx else 'FAIL')" && sed -i 's/true/false/' hypership.config.json`
Expected: `OK`

- [ ] **Step 5: Commit**

```bash
git add hooks/session-start
git commit -m "feat: add session-start hook with strict/suggestive mode context injection"
```

Note: `git add` after `chmod +x` ensures the executable permission bit is committed.

---

### Task 5: Rewrite skill descriptions (delegative, no trigger conflicts)

**Files:**
- Modify: `skills/delivery/SKILL.md` (frontmatter only)
- Modify: `skills/removedebt/SKILL.md` (frontmatter only)

- [ ] **Step 1: Replace delivery skill frontmatter**

In `skills/delivery/SKILL.md`, find the frontmatter block:

```yaml
---
name: delivery
description: >
  ALWAYS invoke when implementing features, fixing bugs, or delivering
  any functional change. Do not start implementation without this skill.
  Triggers: /delivery, "implement", "build", "ship", "develop", "create feature",
  "fix bug", "add feature", "new endpoint", "new component", "new module".
---
```

Replace with:

```yaml
---
name: delivery
description: >
  Invoked by /delivery command. Orchestrates feature delivery with Phase 0
  classification, testing gates, and Superpowers/Ralph Loop pipeline selection.
  Do not invoke directly — use the /delivery command.
---
```

- [ ] **Step 2: Replace removedebt skill frontmatter**

In `skills/removedebt/SKILL.md`, find the frontmatter block:

```yaml
---
name: removedebt
description: >
  ALWAYS invoke when removing debt, refactoring, consolidating code,
  or analyzing technical quality of delivered features. Do not refactor
  without this skill. Triggers: /removedebt, "tech debt", "consolidate",
  "refactor", "cleanup", "dead code", "duplication", "code quality review".
---
```

Replace with:

```yaml
---
name: removedebt
description: >
  Invoked by /removedebt command. Analyzes and removes technical debt with
  safety gates (snapshot, escape hatch, hard stop). Scopes via git history.
  Do not invoke directly — use the /removedebt command.
---
```

- [ ] **Step 3: Verify frontmatter is valid YAML**

Run: `head -8 skills/delivery/SKILL.md && echo "---" && head -8 skills/removedebt/SKILL.md`
Expected: Both show `---` delimiters with `name:` and `description:` fields, no trigger keywords like "implement", "build", "ship"

- [ ] **Step 4: Commit**

```bash
git add skills/delivery/SKILL.md skills/removedebt/SKILL.md
git commit -m "feat: rewrite skill descriptions to delegative style (no trigger conflicts)"
```

---

### Task 6: Enrich plugin.json and marketplace.json

**Files:**
- Modify: `.claude-plugin/plugin.json` (full rewrite)
- Modify: `.claude-plugin/marketplace.json` (full rewrite)

- [ ] **Step 1: Rewrite `plugin.json`**

Replace entire contents of `.claude-plugin/plugin.json` with:

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

Changes: `author` as object, `homepage`, `repository`, `keywords` added, `description` rewritten for marketplace.

- [ ] **Step 2: Rewrite `marketplace.json`**

Replace entire contents of `.claude-plugin/marketplace.json` with:

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

Structure mirrors Superpowers' marketplace.json: top-level `name`, `description`, `owner`, nested `plugins` array with `version`, `source`, `author`.

- [ ] **Step 3: Verify both JSON files are valid**

Run: `cat .claude-plugin/plugin.json | python3 -c "import sys,json; json.load(sys.stdin); print('plugin.json OK')" && cat .claude-plugin/marketplace.json | python3 -c "import sys,json; json.load(sys.stdin); print('marketplace.json OK')"`
Expected: Both print OK

- [ ] **Step 4: Commit**

```bash
git add .claude-plugin/plugin.json .claude-plugin/marketplace.json
git commit -m "feat: enrich plugin.json and marketplace.json for marketplace readiness"
```

---

### Task 7: Fix cross-platform hook (delivery-cycle-check.sh)

**Files:**
- Modify: `hooks/delivery-cycle-check.sh`

- [ ] **Step 1: Replace GNU-only grep with POSIX alternative**

In `hooks/delivery-cycle-check.sh`, find this line:

```bash
    LAST_DATE=$(grep -oP '## \[\K[0-9]{4}-[0-9]{2}-[0-9]{2}' "$DEBT_LOG" | tail -1)
```

Replace with:

```bash
    LAST_DATE=$(grep '## \[' "$DEBT_LOG" | sed 's/.*## \[\([0-9-]*\).*/\1/' | tail -1)
```

`grep -oP` and `\K` are GNU extensions that fail on macOS (BSD grep). The replacement uses POSIX-compatible `grep | sed`.

- [ ] **Step 2: Verify syntax**

Run: `bash -n hooks/delivery-cycle-check.sh`
Expected: no output (no syntax errors)

- [ ] **Step 3: Commit**

```bash
git add hooks/delivery-cycle-check.sh
git commit -m "fix: replace GNU-only grep -oP with POSIX grep|sed in delivery-cycle-check"
```

---

### Task 8: Rewrite README for marketplace

**Files:**
- Modify: `README.md` (complete rewrite)

- [ ] **Step 1: Replace entire README.md**

```markdown
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
```

- [ ] **Step 2: Verify no broken markdown**

Run: `head -5 README.md`
Expected: `# Hypership` followed by tagline and badges

- [ ] **Step 3: Commit**

```bash
git add README.md
git commit -m "docs: rewrite README for marketplace with value prop, badges, and quick start"
```

---

### Task 9: Final verification

- [ ] **Step 1: Verify all new files exist**

Run: `ls -la hypership.config.json hooks/hooks.json hooks/session-start hooks/run-hook.cmd`
Expected: All 4 files listed

- [ ] **Step 2: Verify session-start hook runs without errors**

Run: `CLAUDE_PLUGIN_ROOT=/tmp bash hooks/session-start > /dev/null && echo "OK"`
Expected: `OK`

- [ ] **Step 3: Verify all JSON files are valid**

Run: `for f in hypership.config.json hooks/hooks.json .claude-plugin/plugin.json .claude-plugin/marketplace.json; do echo -n "$f: "; python3 -c "import sys,json; json.load(open('$f')); print('OK')" 2>&1; done`
Expected: All 4 print OK

- [ ] **Step 4: Verify skill descriptions no longer have generic triggers**

Run: `grep -l "ALWAYS invoke\|Triggers:" skills/*/SKILL.md`
Expected: No output (no matches — the old trigger-heavy descriptions are gone)

- [ ] **Step 5: Verify delivery-cycle-check.sh has no GNU-only grep**

Run: `grep 'grep -oP' hooks/delivery-cycle-check.sh`
Expected: No output (the GNU-only pattern is gone)

- [ ] **Step 6: Verify repo structure matches spec**

Run: `find . -not -path './.git/*' -not -path './.git' -type f | sort`
Expected output should include all files from the spec's "Final Repo Structure" section.
