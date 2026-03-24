---
name: delivery
description: >
  Invoked by /delivery command. Orchestrates feature delivery with Phase 0
  classification, testing gates, and Superpowers/Ralph Loop pipeline selection.
  Do not invoke directly — use the /delivery command.
---

# Delivery

Orchestrate feature delivery choosing the right strategy for the task.
Your audience is senior engineers who make architectural decisions — be
direct, technical, and skip introductory explanations.

## Phase 0: Classify & Decompose

Before evaluating delivery strategy, classify the prompt.

### Classification

| Type | Criteria | Behavior |
|------|----------|----------|
| `feature` | New functionality, no bug mention, no pure refactor | Proceed. Flag: `acceptance_test_gate = true` |
| `bugfix` | Mentions error, bug, break, regression | Ask user to describe expected vs actual. Flag: `bug_as_test_gate = true` |
| `chore` | Refactoring, dependency updates, config changes, performance tuning — no new behavior, no bug | Suggest `/removedebt` if pure refactoring. If user insists, proceed with standard TDD only — no extra gates. |
| `mixed` | Contains feature + fix, or feature + chore | Decompose (see below) |
| `overloaded` | 3+ distinct concerns, or scope too vague | Do not execute. Help refine. |

### Mixed Prompt Handling

Decompose and present:

> "I identified [N] distinct work items in this prompt:
> 1. **[type]**: [description]
> 2. **[type]**: [description]
>
> Options:
> - **Sequential**: [recommended order with reasoning]
> - **Parallel**: independent deliveries via subagents (if no dependency)
>
> Which do you prefer?"

After choice, each item enters the pipeline independently with its
own type classification and corresponding gates.

### Overloaded Prompt Handling

> "This prompt has [N] distinct concerns: [list]. For maximum quality,
> I propose breaking into separate deliveries. Which do you want to
> tackle first?"

If user insists on everything together, force decomposition into
independent stories during brainstorm.

### Gate Applicability by Mode

Phase 0 classification applies regardless of delivery mode:
- **Superpowers mode**: gates activate directly via prompt fragments
  (bug-as-test for implementer, acceptance-gate for spec reviewer)
- **Ralph Loop mode**: gates are embedded in the PRD — bugfix stories
  must include "reproduce as failing test" as the first acceptance
  criterion; feature stories must have explicit acceptance criteria
  that map 1:1 to tests. Ralph's per-story execution inherits TDD
  from Superpowers but does not have the two-stage review gate.

## Decision: Superpowers Pipeline vs Ralph Loop

Before starting, evaluate the task against these criteria:

```
TASK ARRIVES
     │
     ▼
Can you define clear acceptance criteria
AND the task decomposes into >3 independent stories
AND the user wants AFK/autonomous execution?
     │
  YES ──▶ RALPH LOOP MODE
     │     PRD-driven, autonomous, fresh context per iteration.
     │     Best for: greenfield features, migrations, batch changes.
     │
  NO
     │
     ▼
  SUPERPOWERS MODE (default)
     brainstorm → plan → subagent-driven-dev → finish
     Best for: everything else. Complex logic, integrations,
     features needing human judgment mid-implementation.
```

**When in doubt, use Superpowers.** Ralph is a power tool for specific
scenarios; Superpowers is the general-purpose pipeline.

**Ask the user which mode they prefer if the task fits both.** Present
the tradeoff concisely:

> "This could run as a Ralph loop (autonomous, fresh context per story,
> good for AFK) or Superpowers pipeline (interactive, two-stage review
> per task, higher precision). Which do you prefer?"

## Superpowers Mode

### Pre-flight: Environment Detection

Before starting, detect available tools silently:

1. **Superpowers** (required):
   - Run: `ls ~/.claude/plugins/cache/ | grep -i superpowers`
   - If missing: stop and tell user to install.

2. **Context7** (optional):
   - Check: `claude mcp list 2>/dev/null | grep -i context7`
   - If available: use `docs-researcher` agent for API lookups
     during implementation instead of relying on training knowledge.

3. **Memory** (optional, any of these):
   - `claude-mem` plugin → use its MCP search tools
   - `memsearch` plugin → use its query tools
   - Built-in auto memory → read `~/.claude/projects/*/memory/`
   - Memory MCP server → search knowledge graph
   Use whichever is found. If present, search for past architectural
   decisions relevant to this feature before brainstorming.

4. **GitHub/GitLab MCP** (optional):
   - Check: `claude mcp list 2>/dev/null | grep -i github`
   - If available: fetch issue details for context, create PR on finish.

5. **Ralph Loop** (optional):
   - Check plugin or `scripts/ralph/ralph.sh`
   - If available: offer as delivery mode when task fits.

Report to user concisely:
> "Env: Superpowers ✅ | Context7 [✅|❌] | GitHub [✅|❌] | Memory [✅|❌] | Ralph [✅|❌]"

Then invoke `superpowers:using-superpowers` to activate the skill system.

### Execution

Follow the standard Superpowers pipeline. The skills activate
automatically once brainstorming completes:

1. `superpowers:brainstorming` → design doc saved
2. `superpowers:using-git-worktrees` → isolated branch
3. `superpowers:writing-plans` → granular tasks in `docs/plans/`
4. `superpowers:subagent-driven-development` → implement + two-stage review
5. `superpowers:finishing-a-development-branch` → merge/PR/keep/discard

### Testing Gates (per task, during subagent-driven-development)

Gates activate based on Phase 0 classification flags. They modify
how the Superpowers `subagent-driven-development` skill dispatches
and reviews each task.

**When `bug_as_test_gate = true` (bugfix):**
- Load `./bug-as-test-prompt.md` and append to the implementer prompt
- Implementer MUST reproduce the bug as a failing test first
- If non-reproducible: implementer reports `BLOCKED_NON_REPRODUCIBLE`
  with 3 alternative approaches. Present to user for choice.
- If infrastructure-only: implementer reports `BLOCKED_INFRA`.
  Spec reviewer validates the justification.
- Iron law: `NO BUGFIX WITHOUT EVIDENCE.`

**When `acceptance_test_gate = true` (feature):**
- After implementation, before spec review:
  check if acceptance criteria from brainstorm have corresponding tests
- If mapping complete: load `./acceptance-gate-prompt.md`, replace the
  `[ACCEPTANCE_CRITERIA]` placeholder with the actual criteria list from
  brainstorm, and append to the spec reviewer prompt
- If mapping incomplete: send uncovered criteria back to implementer
- Max 2 attempts. After 2nd failure, escalate to user:
  "Approve override, or reword the criteria?"

**When neither flag is set (chore):**
- Standard Superpowers TDD. No extra gates.

### Delivery-specific additions

After Superpowers finishes:

- **Tag the delivery**: `git tag delivery/YYYY-MM-DD-feature-name`
- **Update delivery log**: append to `docs/delivery-log.md`:
  ```
  ## [date] feature-name
  - Plan: docs/plans/plan-file.md
  - Branch: branch-name
  - Stories completed: N/N
  - Status: merged | pending-review
  ```
- **Check consolidation trigger**: count features since last
  `removedebt` entry in `docs/debt-log.md`. If > 5, suggest:
  > "You have N features since last debt removal. Consider running
  > `/removedebt since last consolidation`"

## Ralph Loop Mode

### Pre-flight

1. Check Ralph availability:
   - Plugin: `ls ~/.claude/plugins/cache/ | grep -i ralph`
   - Or standalone: check `scripts/ralph/ralph.sh` exists

2. If neither exists, offer to set up:
   ```
   /plugin install ralph-loop
   ```
   Or manual setup with Superpowers brainstorming to generate the PRD.

### PRD Generation

Use `superpowers:brainstorming` to generate the PRD. This is where the
two tools combine: Superpowers' structured brainstorm produces a better
PRD than writing one manually.

After brainstorm, format as PRD:

```json
{
  "branchName": "feat/feature-name",
  "userStories": [
    {
      "id": "STORY-1",
      "title": "story title",
      "acceptanceCriteria": ["criterion 1", "criterion 2"],
      "passes": false
    }
  ]
}
```

**Rule**: Each story must fit in a single context window. If it's too
big, split it. Ask the user if unsure about granularity.

### Loop Configuration

Present to user:
> "Ralph loop configured with N stories. Options:
> - **HITL** (human-in-the-loop): you watch each iteration, review, re-run
> - **AFK**: autonomous with max-iterations safety. I notify on completion.
>
> For first time with this feature scope, I recommend HITL."

### Execution

Ralph handles the loop. After completion:

- Same delivery log update as Superpowers mode
- Same consolidation trigger check

## Cross-cutting: Context Engineering

Regardless of mode, before starting:

1. **Read CLAUDE.md** for project conventions.
2. **Read recent delivery-log.md** entries for context on recent changes.
3. **Read recent debt-log.md** to know what was consolidated.
4. If MCP servers are available (GitHub, Jira, Linear), **fetch the
   issue/ticket** for full requirements context.

## Post-delivery Checklist

Present to user after delivery completes:

```
✅ Feature implemented and tested
✅ Plan saved to docs/plans/
✅ Delivery logged in docs/delivery-log.md
✅ Branch merged / PR created

⚠️  Features since last /removedebt: [N]
    [If > 5: "Recommend running /removedebt"]
```
