# Hypership

AI-first delivery and tech debt management for senior engineering teams.

Two commands. One philosophy: **deliver fast, consolidate deliberately.**

## Commands

### `/delivery [description]`

Orchestrates feature implementation. Chooses between Superpowers
pipeline (interactive, two-stage review) or Ralph Loop (autonomous,
PRD-driven) based on task characteristics. Asks you when both fit.

```
/delivery implement the refund flow for Stripe and PayPal
/delivery fix the race condition in checkout queue
/delivery migrate user preferences from localStorage to API
```

What happens:
1. Evaluates task → picks Superpowers or Ralph
2. Brainstorms to refine requirements (even for "simple" tasks)
3. Generates granular plan with exact file paths
4. Implements via subagents with TDD
5. Two-stage review: spec compliance + code quality
6. Finishes branch, logs delivery, checks debt cycle

### `/removedebt [context]`

Analyzes accumulated tech debt from recent deliveries. Scopes analysis
by your context argument — time range, feature set, or module.

```
/removedebt the last 3 features about payment methods
/removedebt after v2.0 release until now
/removedebt everything on the checkout module
/removedebt since last consolidation
/removedebt                              # = since last /removedebt
```

What happens:
1. Resolves your context to a git range
2. Dispatches debt-scanner agent on the diff
3. Classifies findings: duplication, dead code, naming drift, type sprawl, missing tests, stale imports
4. Filters out non-debt (YAGNI, premature optimization, preferences)
5. Presents findings with strategic questions (max 5 decision points)
6. You decide what to address, skip, or handle manually
7. Executes approved items via Superpowers pipeline
8. Logs everything to `docs/debt-log.md`

### `/status`

Shows current delivery cycle health: features since last debt removal,
recent deliveries, pending plans.

## Philosophy

- **Features and debt removal are separate activities.** Don't refactor
  during feature delivery. Don't add features during debt removal.
- **Debt is concrete, not speculative.** Duplication you can grep for.
  Dead code with zero imports. Not "could be more generic."
- **Senior engineers decide.** The tool proposes, you dispose. Every
  finding comes with "skip" as a valid option.
- **Superpowers is the quality backbone.** Both delivery and debt
  removal run through the full pipeline: brainstorm → plan → TDD →
  subagent-driven-development → two-stage review.

## Prerequisites

- [Claude Code](https://code.claude.com) with plugin support
- [Superpowers](https://github.com/obra/superpowers) plugin installed
- (Optional) [Ralph Loop](https://github.com/snarktank/ralph) for autonomous mode

## Recommended Companions

These are NOT dependencies — the plugin works 100% without them.
But when present, it detects and uses them automatically.

| Plugin/MCP | What it adds | Install |
|---|---|---|
| **Context7** | Docs lookup during implementation — fewer API mistakes | `claude mcp add context7 -- npx -y @upstreamapi/context7-mcp` |
| **GitHub MCP** | Auto-fetch issues, auto-create PRs | `claude mcp add github -- npx -y @anthropic-ai/github-mcp-server` |
| **claude-mem** | Rich persistent memory with AI compression across sessions | `/plugin marketplace add thedotmack/claude-mem` then `/plugin install claude-mem` |
| **memsearch** | Lightweight persistent memory, markdown-based, vector search | `/plugin marketplace add zilliztech/memsearch` then `/plugin install memsearch` |
| **Ralph Loop** | AFK autonomous delivery mode | `/plugin install ralph-loop` |

**On memory:** You don't need all memory options. Claude Code already has
built-in auto memory (v2.1.59+). Pick ONE if you want more:
- **claude-mem** for deep, compressed memory across long projects (adds ~60-90s latency per tool call)
- **memsearch** for lightweight, fast, markdown-based memory (minimal latency)
- **Neither** if built-in auto memory is enough for your workflow

The plugin auto-detects whichever memory system is present and uses it.

## Installation

```bash
# Install Superpowers first (dependency)
/plugin marketplace add obra/superpowers-marketplace
/plugin install superpowers@superpowers-marketplace

# Install delivery-cycle
/plugin install your-org/delivery-cycle
```

## Project Setup

The plugin creates these files as needed:

```
docs/
├── plans/            # Superpowers plans (auto-managed)
├── delivery-log.md   # Feature delivery history
└── debt-log.md       # Debt removal history
```

Add to your `.claude/settings.json`:

```json
{
  "plansDirectory": "./docs/plans"
}
```

## Configuration

The plugin reads your `CLAUDE.md` for:
- Test command (to run after refactors)
- Build command (to verify nothing broke)
- Code conventions (passed to subagents)

No additional configuration needed. The skills activate automatically.

## License

MIT