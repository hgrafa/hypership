---
name: removedebt
description: >
  ALWAYS invoke when removing debt, refactoring, consolidating code,
  or analyzing technical quality of delivered features. Do not refactor
  without this skill. Triggers: /removedebt, "tech debt", "consolidate",
  "refactor", "cleanup", "dead code", "duplication", "code quality review".
---

# Remove Debt

Analyze and remove technical debt from delivered features. Your audience
is senior engineers — propose tradeoffs, not instructions. They decide
what to cut; you execute with precision.

## Pre-flight: Environment Detection

1. **Superpowers** (required): verify installed.
2. **GitHub MCP** (optional): if available, create PR with debt
   analysis as description after execution.
3. **Memory** (optional): detect whichever is available, in order:
   - **claude-mem**: check `ls ~/.claude/plugins/cache/ | grep -i claude-mem`
     → use MCP search tools to query past decisions about the code
   - **memsearch**: check `ls ~/.claude/plugins/cache/ | grep -i memsearch`
     → use memsearch query for relevant past context
   - **Auto Memory (built-in)**: check `ls ~/.claude/projects/*/memory/`
     → read MEMORY.md and topic files for relevant decisions
   - **Memory MCP**: check `claude mcp list 2>/dev/null | grep -i memory`
     → search knowledge graph for past decisions
   Use whichever is found first. If none, proceed without — analysis
   will be based purely on code diff.

Report: `"Env: Superpowers ✅ | GitHub [✅|❌] | Memory: [claude-mem|memsearch|auto|mcp|none]"`

If any memory system returns relevant context, prepend to
each finding: `"📝 Memory: [past decision context]"`

## Phase 1: Scope Resolution

Parse the user's context argument into a concrete git scope.

### Context Patterns

| User says | Git interpretation |
|---|---|
| `the last N features about X` | `git log --grep="^feat:.*X" -N` → extract SHAs |
| `after 2.0 release until now` | `git log v2.0..HEAD` |
| `after tag/release X` | `git log X..HEAD` |
| `since last consolidation` | Read `docs/debt-log.md` → last entry date → `git log --after="date"` |
| `everything on module X` | `git log -- path/to/module/` |
| `since last /removedebt` | Same as "since last consolidation" |
| (empty) | Default to since last entry in `docs/debt-log.md`, or all of current branch |

### Resolution Steps

1. Parse the context argument.
2. If ambiguous, ask ONE clarifying question:
   > "By 'payment methods' do you mean `src/payments/` or also
   > `src/checkout/payment-*`? I see changes in both."
3. Run the resolved git commands to get the diff scope.
4. Summarize what you found:
   > "Scope: 7 commits, 23 files changed, across `src/payments/`
   > and `src/api/routes/payment*.ts`. Proceed with analysis?"

## Phase 2: Debt Discovery

Run the `debt-scanner` agent as a subagent to analyze the scoped diff.

### Dispatch debt-scanner

Use the Task tool to dispatch the debt-scanner agent with:
- The resolved git scope (base SHA, head SHA)
- File paths in scope
- The project's test command (from CLAUDE.md or package.json)

The debt-scanner returns a structured findings report.

### Debt Classification

Every finding MUST be classified into exactly one category:

| Category | Icon | Definition | Action |
|---|---|---|---|
| **Duplication** | 🔁 | >10 lines of identical or near-identical code across 2+ files | Extract to shared module |
| **Dead Code** | 💀 | Unreachable code, unused exports, orphaned after refactors | Remove |
| **Naming Drift** | 🏷️ | Same concept, different names across features | Unify naming |
| **Type Sprawl** | 📦 | >2 features define structurally identical types separately | Consolidate types |
| **Missing Tests** | 🧪 | Delivered code below project's coverage baseline | Add tests |
| **Stale Imports** | 🧹 | Unused imports left from refactors | Remove |

### What is NOT debt (hard filter)

The following MUST NOT appear in findings. If the scanner returns them,
filter them out before presenting to the user:

- "Could be more generic" → YAGNI
- "Performance concern" without measured benchmark → speculation
- "Better pattern exists" that doesn't fix a bug → preference
- "Should use library X" when custom code works → preference
- "Future-proofing" anything → over-engineering
- "Code style" differences that lint doesn't catch → subjective
- Single-use helpers that could be "reusable" → premature abstraction

## Phase 3: Strategic Questions

Present findings grouped by category. For each group, ask a strategic
question that helps the senior engineer decide.

### Question Format

```
## Debt Analysis: [scope description]

### 🔁 Duplication (3 findings)

1. `createPaymentIntent()` in `src/payments/stripe.ts:45-67` and
   `src/payments/paypal.ts:32-54` — 22 lines, identical validation
   logic with different provider calls.

2. Error handling block in `src/api/routes/payment-create.ts:89-112`
   and `src/api/routes/payment-update.ts:45-68` — same try/catch
   structure, same error mapping.

3. `formatCurrency()` implemented in 3 files with identical logic.

**Decision point:** Extract shared validation into
`src/payments/shared/validation.ts`? The provider-specific parts
stay in each file. Estimated: ~30 min, touches 4 files.

Options:
  [A] Extract all 3 → single refactor PR
  [B] Extract #1 and #3 only (highest duplication), leave #2 (lower risk)
  [C] Skip — duplication is acceptable for now
  [D] I'll handle this manually, just note it

> Your call:
```

### Question Design Principles

1. **Show the code locations** — senior engineers want to see WHERE,
   not just hear about it.
2. **Estimate effort** — "~30 min, touches 4 files" lets them weigh
   cost vs benefit.
3. **Always offer "skip"** — not all debt is worth fixing now.
4. **Always offer "I'll do it manually"** — respect their autonomy.
5. **Group related findings** — don't ask 15 separate questions.
   Bundle by category or module.
6. **Max 5 decision points per session** — more than that is
   decision fatigue. If >5, ask which categories to prioritize first.

### Priority Suggestion

After presenting all findings, suggest a priority:

```
**My recommendation (you decide):**

Priority 1: 💀 Dead code (3 items) — zero-risk removal, cleaner codebase
Priority 2: 🔁 Duplication #1 and #3 — high duplication, low effort
Priority 3: 🧪 Missing tests — prevents regression in next delivery

Skip for now: 🏷️ Naming drift — 2 instances, not causing confusion yet

Total estimated effort: ~2h for Priority 1-2, ~1h for Priority 3.

Want to proceed with all, or pick specific priorities?
```

## Phase 3.5: Safety Gates

After the engineer approves findings and before executing any refactor,
activate the safety gates protocol.

**Load `./safety-gates.md`** and follow the 3-gate protocol:

### Gate 1: Snapshot
- Run full test suite, capture baseline (pass/fail/skip counts, coverage if available)
- Record already-failing tests (excluded from delta later)
- If test command cannot be found or fails: **STOP** — do not proceed

### Gate 2: Escape Hatch
- Ask engineer which tests may break intentionally
- Record as `escape_list` — **immutable once execution begins**
- If "none": any new failure triggers hard stop

### Gate 3: Hard Stop with Delta (after EACH category)
- Run tests after each refactor category completes
- Compare with snapshot baseline
- New failures outside escape_list → **HARD STOP** with options:
  [A] Revert  [B] Investigate (systematic-debugging)  [C] Continue (user's risk)
- New failures inside escape_list → log and continue
- Coverage drop on touched files → warning (non-blocking)
- All clean → proceed to next category

**The safety-gates.md fragment contains the full protocol with exact
wording for each gate, decision tree, and debt-log test fields template.**

## Phase 4: Execution

For each approved debt item, execute via Superpowers pipeline:

1. Invoke `superpowers:brainstorming` with the specific refactor scope.
   - Brainstorm is shorter here — the "what" is already decided.
   - Focus on "how": strategy for the refactor, migration path.

2. Invoke `superpowers:writing-plans` for the approved items.
   - Group related items into a single plan when they touch the same files.

3. Invoke `superpowers:subagent-driven-development`:
   - Implementer does the refactor with TDD.
   - Spec reviewer verifies: ONLY the approved debt was addressed.
     **If the implementer touched anything outside scope → REJECT.**
   - Quality reviewer verifies: tests pass, nothing broke.

4. Invoke `superpowers:finishing-a-development-branch`:
   - Branch name: `refactor/removedebt-YYYY-MM-DD-scope`
   - PR description includes the debt analysis and user decisions.

### Execution Rules

- **One refactor category at a time.** Don't mix duplication removal
  with dead code cleanup in the same subagent task.
- **Safety gates handle test verification.** After each category,
  Gate 3 runs the full test suite and compares with baseline.
  Do not run ad-hoc test checks — the gate protocol handles this.
- **If Gate 3 triggers a hard stop**, present the options to the user.
  Do not auto-fix or auto-revert.
- **Commit after each category** with: `refactor(debt): [category] [scope]`
  Example: `refactor(debt): extract shared payment validation`

## Phase 5: Logging

After execution (or if user skips everything), update `docs/debt-log.md`:

```markdown
## [YYYY-MM-DD] Debt Removal: [scope description]

### Scope
- Context: "[original user argument]"
- Git range: `[base_sha]..[head_sha]`
- Files analyzed: [N]
- Features in scope: [list]

### Findings
| # | Category | Location | Decision | Status |
|---|----------|----------|----------|--------|
| 1 | 🔁 Duplication | payments/stripe,paypal | Extract → shared | ✅ Done |
| 2 | 🔁 Duplication | routes/payment-*.ts | Skip (acceptable) | ⏭️ Skipped |
| 3 | 💀 Dead Code | utils/legacy-format.ts | Remove | ✅ Done |
| 4 | 🧪 Missing Tests | payments/refund.ts | Add coverage | ✅ Done |

### Tests
- Baseline: [N] pass, [N] fail (pre-existing), [N]% coverage
- After: [N] pass, [N] fail (pre-existing), [N]% coverage
- Declared breaks: [N] ([description])
- Unexpected breaks: [N]
- Hard stops triggered: [N]
- Coverage delta: [+/-N]% ([reason])

### Branch
- `refactor/removedebt-YYYY-MM-DD-payments`
- PR: #[number] (if created)
```

## Interaction Model Summary

```
/removedebt [context]
       │
       ▼
  Resolve scope (git range, files)
       │
       ▼
  Dispatch debt-scanner agent
       │
       ▼
  Filter out non-debt (YAGNI, premature optimization, etc)
       │
       ▼
  Present findings with strategic questions (max 5 decision points)
       │
       ▼
  User decides: proceed / skip / manual per group
       │
       ▼
  Execute approved items via Superpowers pipeline
  (brainstorm → plan → SDD with TDD + two-stage review)
       │
       ▼
  Log to docs/debt-log.md
       │
       ▼
  Summary: what was done, what was skipped, test status
```
