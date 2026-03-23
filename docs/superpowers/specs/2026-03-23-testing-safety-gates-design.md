# Testing & Safety Gates for Hypership

> Design spec for adding testing gates to `/delivery` and safety gates to `/removedebt`.
> Approved during brainstorming session 2026-03-23.

## Problem Statement

Hypership orchestrates feature delivery and tech debt removal via Superpowers pipeline. Two gaps exist:

1. **Delivery side:** Superpowers enforces TDD, but nothing validates that tests cover the user's actual requirements (acceptance criteria). Bugfixes go through TDD but don't enforce reproducing the bug as a failing test first.

2. **Removedebt side:** The skill says "run ALL tests" and "if a test breaks, STOP" but this is instructional text — no enforcement mechanism, no baseline comparison, no escape hatch for intentional breaking changes.

## Design Decisions

- **Approach:** "Triage Light + Smart Gates" — triage is Phase 0 of delivery (not a separate skill), removedebt gets direct gates.
- **Bug handling:** Bug = failing test first (iron law). Non-reproducible bugs get 3 fallback strategies instead of hard stop.
- **Feature testing:** Acceptance criteria from brainstorm must map 1:1 to tests. Spec reviewer validates both code and tests against spec.
- **Mixed prompts:** Decomposed into independent deliveries (sequential or parallel). Each gets its own type-appropriate gates.
- **Removedebt safety:** Snapshot baseline + upfront escape hatch + hard stop with delta after each category.
- **Fragments:** Dedicated prompt files per gate to keep subagent context isolated (Superpowers pattern).

---

## Part 1: Phase 0 — Classify & Decompose (`/delivery`)

Added as the opening phase of `skills/delivery/SKILL.md`, before environment detection.

### Classification

Every prompt is classified into exactly one type:

| Type | Criteria | Example |
|------|----------|---------|
| `feature` | New functionality, no bug mention, no pure refactor | "add Stripe refund flow" |
| `bugfix` | Mentions error, bug, break, regression | "fix race condition in checkout" |
| `chore` | Refactoring, dependency updates, config changes, performance tuning — no new behavior, no bug | "refactor auth module", "update dependencies", "improve query performance" |
| `mixed` | Contains explicit feature + fix, or feature + chore | "fix the login bug and add 2FA" |
| `overloaded` | 3+ distinct concerns, or scope too vague | "refactor auth, add billing, fix payments" |

### Behavior by Type

**`feature`** — proceeds to Phase 1. Internal flag: `acceptance_test_gate = true`.

**`chore`** — proceeds to Phase 1 with no testing gates. Superpowers TDD still applies (the implementer writes tests for what they change), but no acceptance criteria mapping and no bug reproduction. If the chore is pure refactoring, suggest `/removedebt` instead — it has better tooling for that. If user insists on `/delivery`, proceed without gates.

**`bugfix`** — presents to user:

> "I'll reproduce this bug as a failing test before fixing. Describe the expected vs actual behavior, or point me to where the bug occurs so I can investigate."

Internal flag: `bug_as_test_gate = true`. Implementer subagent receives instruction that first action is writing the failing test (RED), confirming it fails for the right reason, then fixing (GREEN).

**`mixed`** — decomposes and presents:

> "I identified two distinct work items in this prompt:
> 1. **[bugfix]**: fix the login bug
> 2. **[feature]**: add 2FA
>
> Options:
> - **Sequential**: fix first (may unblock the feature), then feature
> - **Parallel**: two independent deliveries via subagents (if no dependency)
>
> Which do you prefer?"

After choice, each item enters the pipeline as an independent delivery with its own type and gates.

**`overloaded`** — does not execute. Helps refine:

> "This prompt has [N] distinct concerns: [list]. For maximum quality, I propose breaking into separate deliveries. Which do you want to tackle first?"

If user insists on everything together, delivery accepts but forces decomposition into independent stories during brainstorm.

---

## Part 2: Gate A — Bug-as-Test (`bugfix` type)

Activated when `bug_as_test_gate = true`. Runs before implementation, inside subagent-driven-development.

### Primary Flow (Reproducible Bug)

```
Bug described by user
       |
       v
  Implementer subagent receives extra instruction:
  "Your FIRST action is to reproduce the bug as a test
   that FAILS. Confirm it fails for the correct reason.
   Only then fix. If you cannot reproduce, report
   BLOCKED - do not guess the fix."
       |
       v
  Test written -> runs -> fails?
       |
      YES -> implement minimal fix -> test passes -> spec review
       |
      NO -> non-reproducible flow (see below)
```

### Non-Reproducible Bug Flow

Instead of stopping completely, presents 3 alternatives ordered by assertiveness:

```
Cannot reproduce
       |
       v
  "Could not reproduce the bug with a direct test.
   [test output]. Three paths:

   1. Defense-in-depth — add assertions, guards, and
      boundary validations on the affected code path.
      Doesn't prove the bug existed, but prevents it
      (or variants) from passing silently.

   2. Observability — instrument the code path with
      structured logs, metrics, or tracing. The 'test'
      becomes a monitor that detects recurrence in prod.

   3. Hypothesis-driven hardening — document the most
      likely hypothesis ('probably race condition between
      X and Y'), write a test that attempts to provoke
      the scenario, and apply preventive fix.

   Which approach for this case?"
       |
       v
  Engineer chooses (1, 2, or 3)
       |
       +-- Defense-in-depth:
       |   Implementer adds invariant checks, boundary
       |   validations, defensive error handling with
       |   explicit logging.
       |   Spec reviewer validates: "Do guards cover
       |   the bug's code path? Are they proportional?"
       |
       +-- Observability:
       |   Implementer adds structured logs, metrics,
       |   or tracing points.
       |   Spec reviewer validates: "If the bug occurs
       |   again, will these instruments detect it?"
       |
       +-- Hypothesis-driven:
           Implementer documents hypothesis, writes test
           that attempts to provoke scenario (may pass —
           ok), applies preventive fix.
           Spec reviewer validates: "Is hypothesis
           reasonable? Does fix have side effects?"
       |
       v
  Quality reviewer (normal Superpowers)
```

### Iron Law

`NO BUGFIX WITHOUT EVIDENCE. Reproduce first. If you can't reproduce, harden — never guess.`

### Escape Hatch

If the bug is in pure infrastructure that cannot be unit-tested (e.g., deploy config, env var), the implementer can declare this and the spec reviewer validates whether the justification makes sense.

### Prompt Fragment

Delivered via `skills/delivery/bug-as-test-prompt.md` — loaded only when task is bugfix. Feature implementers never see this context.

---

## Part 3: Gate B — Acceptance Test Coverage (`feature` type)

Activated when `acceptance_test_gate = true`. Runs between implementation and spec review.

### Flow

```
Brainstorm produces acceptance criteria
  e.g.: ["user can request refund",
         "refund creates Stripe reversal",
         "email sent after refund processed"]
       |
       v
  Implementer does TDD (normal Superpowers)
       |
       v
  GATE: Before spec review, check:
  "For each acceptance criterion from brainstorm,
   does at least one test exercise it?"
       |
       v
  Mapping found for all criteria?
       |
      YES -> spec reviewer receives extra context:
       |     "Validate that tests exercise THESE criteria:
       |     [list from brainstorm]. Not just that the code
       |     works — that the TESTS prove it works."
       |
      NO -> implementer receives:
             "Criteria without tests:
              - [criterion X]
              - [criterion Y]
             Write tests for these before proceeding."
             -> loops back to gate check (max 2 attempts)
             -> after 2nd failure, escalates to user:
                "Could not map tests to these criteria
                 after 2 attempts:
                 - [criterion X]
                 Approve override, or reword the criteria?"
```

### What Changes in Spec Reviewer

Receives an extra instruction in dispatch prompt: beyond checking "code does what spec says", checks "tests prove code does what spec says". Rejects if a criterion has no corresponding test.

### What Does NOT Change

Implementer continues doing normal Superpowers TDD. The gate doesn't change the writing process — it validates completeness before review.

### Prompt Fragment

Delivered via `skills/delivery/acceptance-gate-prompt.md` — loaded only during feature spec review.

---

## Part 4: Safety Gates for `/removedebt`

Three gates forming a safety belt around every debt refactor.

### Gate 1: Snapshot (before any execution)

After findings are approved, before executing any item:

```
Approved findings ready for execution
       |
       v
  SNAPSHOT: capture current state
  - Run full test suite
  - Record: total, pass, fail, skip
  - Record: coverage % per file (if available)
  - Record: list of tests that fail BEFORE refactor
    (already-failing = ignored in delta later)
  - Save as temporary baseline
       |
       v
  Snapshot failed (test cmd missing, timeout, env error)?
       |
      YES -> STOP: "Cannot establish test baseline.
       |    Without baseline, I cannot guarantee the
       |    refactor didn't break anything. Configure
       |    the test command in CLAUDE.md and try again."
       |
      NO -> proceed to escape hatch
```

**Why capture already-failing:** In real projects, there may be broken tests outside scope. The delta compares only against baseline — a test that was already failing doesn't block the refactor.

### Gate 2: Escape Hatch (upfront declaration)

Right after snapshot, before first execution:

```
Snapshot captured: 247 pass, 3 fail (pre-existing), 82% coverage
       |
       v
  "Can any tests break intentionally with these refactors?
   Examples:
   - Renaming public API changes integration tests
   - Consolidating types breaks tests importing the old type
   - Removing dead code breaks tests for the removed code

   Declare now which tests/patterns may break,
   or 'none' for total hard stop."
       |
       v
  Engineer responds:
       |
       +-- "none" -> escape_list = []
       |   (any new failing test = hard stop)
       |
       +-- "integration tests for module X" / "*.test.ts
            importing OldTypeName" / specific patterns
            -> escape_list = [declared patterns]
```

**Rule:** Escape hatch is declarative and upfront. The `escape_list` is **immutable once execution begins** — it is frozen at declaration time and cannot be modified, extended, or overridden after the first refactor category starts. This is enforced by flow (the escape hatch question is asked exactly once, before execution), not by instructional text. Any test failure outside the frozen list triggers the hard stop regardless of context.

### Gate 3: Hard Stop with Delta (after each debt category)

Each approved category is executed as a separate refactor. After each:

```
Category executed (e.g., Duplication extracted)
       |
       v
  Run full test suite again
       |
       v
  DELTA: compare with snapshot
  - Tests that passed and now fail? -> filter escape_list
  - Coverage dropped on touched files?
  - New tests added by refactor?
       |
       v
  Tests broke outside escape_list?
       |
      YES -> HARD STOP
       |   "X tests broke after [category]:
       |
       |    FAIL: test_payment_intent (was PASS)
       |    FAIL: test_refund_flow (was PASS)
       |
       |    These are NOT in your declared
       |    breaking changes list.
       |
       |    Options:
       |    [A] Revert this category (git checkout)
       |    [B] Investigate (systematic-debugging)
       |    [C] Continue anyway (you assume the risk)"
       |
      NO -> tests broke but in escape_list?
             |
            YES -> LOG + CONTINUE
             |    "N tests broke as declared: [list].
             |     Logging to debt-log. Continuing."
             |
            NO (all green) -> coverage dropped?
                   |
                  YES -> WARNING (non-blocking)
                   |    "Coverage dropped X% -> Y% on
                   |     [files]. Expected if code was
                   |     removed. Want me to add tests
                   |     to compensate?"
                   |
                  NO -> Category clean. Next.
```

### Debt Log Integration

After all categories, `docs/debt-log.md` gains test fields:

```markdown
### Tests
- Baseline: 247 pass, 3 fail (pre-existing), 82% coverage
- After: 245 pass, 3 fail (pre-existing), 83% coverage
- Declared breaks: 2 (OldTypeName import tests - removed with dead code)
- Unexpected breaks: 0
- Hard stops triggered: 0
- Coverage delta: +1% (dead code removal improved ratio)
```

### Prompt Fragment

Delivered via `skills/removedebt/safety-gates.md` — loaded only during removedebt execution.

---

## Part 5: Files Changed

### Modified Files

| File | Change |
|------|--------|
| `skills/delivery/SKILL.md` | Add Phase 0 (classify & decompose) at the top. Add Gate A and Gate B sections referencing their prompt fragments. |
| `skills/removedebt/SKILL.md` | Add Safety Gates phase between finding approval and execution. Reference safety-gates.md fragment. Update debt-log template with test fields. |

### New Files

| File | Purpose |
|------|---------|
| `skills/delivery/bug-as-test-prompt.md` | Prompt fragment for implementer subagent on bugfix tasks. Contains iron law, reproduction flow, 3 non-reproducible alternatives. Loaded only for bugfix type. |
| `skills/delivery/acceptance-gate-prompt.md` | Prompt fragment for spec reviewer on feature tasks. Contains instruction to validate tests against acceptance criteria. Loaded only for feature type. |
| `skills/removedebt/safety-gates.md` | Prompt fragment with complete 3-gate protocol (snapshot, escape hatch, hard stop + delta). Loaded only during removedebt execution. |

### Unchanged Files

| File | Why |
|------|-----|
| `agents/debt-scanner.md` | Scanner analyzes debt, not tests. Test gates are the skill's responsibility. |
| `commands/delivery.md` | Already delegates to skill correctly. |
| `commands/removedebt.md` | Already delegates to skill correctly. |
| `commands/status.md` | No change needed. |
| `hooks/delivery-cycle-check.sh` | No change needed. |
| `.claude-plugin/plugin.json` | Structural fixes deferred to next design cycle. |

### Final Repo Structure

```
hypership/
+-- .claude-plugin/
|   +-- plugin.json
|   +-- marketplace.json
+-- commands/
|   +-- delivery.md
|   +-- removedebt.md
|   +-- status.md
+-- skills/
|   +-- delivery/
|   |   +-- SKILL.md                    <- modified (Phase 0 + gates)
|   |   +-- bug-as-test-prompt.md       <- NEW
|   |   +-- acceptance-gate-prompt.md   <- NEW
|   +-- removedebt/
|       +-- SKILL.md                    <- modified (safety gates)
|       +-- safety-gates.md             <- NEW
+-- agents/
|   +-- debt-scanner.md
+-- hooks/
|   +-- delivery-cycle-check.sh
+-- docs/
|   +-- superpowers/
|       +-- specs/
|           +-- 2026-03-23-testing-safety-gates-design.md
+-- README.md
```

---

## Out of Scope (Next Design Cycle)

- Restructure `plugin.json` (declare skills/commands/agents/hooks)
- Add `hooks.json` for formal hook registration
- Fix cross-platform hook (`grep -oP` -> POSIX)
- Refine skill descriptions (remove generic triggers)
- Plugin self-tests (validate gates work)
- README update with testing philosophy

---

## Summary of Gates

| Context | Gate | When | Enforces | Blocks? |
|---------|------|------|----------|---------|
| `/delivery` bugfix | Bug-as-Test | Before implementation | Failing test reproducing the bug | Yes, but offers 3 non-reproducible fallbacks |
| `/delivery` feature | Acceptance Coverage | After implementation, before spec review | Tests mapped 1:1 to acceptance criteria | Yes, max 2 attempts then escalates to user |
| `/delivery` chore | None (TDD only) | N/A | Standard Superpowers TDD, no extra gates | No |
| `/delivery` mixed | Both | After decomposition, per item | Each item gets its type-appropriate gate | Per item |
| `/removedebt` | Snapshot | Before any execution | Test baseline captured | Yes, if test cmd fails |
| `/removedebt` | Escape Hatch | After snapshot, before execution | Engineer declares expected breaks upfront | No (declaration) |
| `/removedebt` | Hard Stop + Delta | After each debt category | No unexpected test regressions | Yes, with revert/investigate/continue options |
