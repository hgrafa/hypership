# Testing & Safety Gates Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add testing gates to `/delivery` (Phase 0 classify & decompose, Bug-as-Test gate, Acceptance Coverage gate) and safety gates to `/removedebt` (Snapshot, Escape Hatch, Hard Stop with delta).

**Architecture:** Three new prompt fragment files provide isolated context to subagents. Two existing SKILL.md files are modified to insert new phases and reference the fragments. No new skills or commands — gates are phases within existing skills.

**Tech Stack:** Markdown skill files, markdown prompt fragments (Superpowers plugin conventions)

**Spec:** `docs/superpowers/specs/2026-03-23-testing-safety-gates-design.md`

---

## File Structure

### Modified Files

| File | Responsibility |
|------|---------------|
| `skills/delivery/SKILL.md` | Add Phase 0 (classify & decompose) before environment detection. Add Gate A and Gate B references after Superpowers pipeline description. |
| `skills/removedebt/SKILL.md` | Add Safety Gates phase (snapshot, escape hatch, hard stop) between Phase 3 (strategic questions) and Phase 4 (execution). Update debt-log template with test fields. |

### New Files

| File | Responsibility |
|------|---------------|
| `skills/delivery/bug-as-test-prompt.md` | Prompt fragment for implementer subagent on bugfix tasks. Contains iron law, reproduction flow, 3 non-reproducible alternatives, infrastructure escape hatch. |
| `skills/delivery/acceptance-gate-prompt.md` | Prompt fragment for spec reviewer on feature tasks. Contains instruction to validate tests against acceptance criteria from brainstorm. Max 2 attempts before escalation. |
| `skills/removedebt/safety-gates.md` | Prompt fragment with 3-gate protocol: snapshot capture, escape hatch declaration, hard stop with delta comparison. Immutable escape_list enforcement. |

---

## Task 1: Create bug-as-test-prompt.md

Prompt fragment loaded by the delivery skill when dispatching an implementer subagent for a `bugfix` task. Follows Superpowers pattern: template with placeholder sections, addresses the subagent directly, includes escalation paths.

**Files:**
- Create: `skills/delivery/bug-as-test-prompt.md`

- [ ] **Step 1: Write the bug-as-test prompt fragment**

```markdown
# Bug-as-Test Implementer Prompt Extension

> Loaded by the delivery skill when the task is classified as `bugfix`.
> This is an EXTENSION to the standard Superpowers implementer prompt —
> it adds bug-specific instructions, not replaces the base prompt.

## Iron Law

`NO BUGFIX WITHOUT EVIDENCE. Reproduce first. If you can't reproduce, harden — never guess.`

## Your Process (Overrides Normal TDD Start)

Your FIRST action — before any implementation — is to reproduce the bug
as a failing test.

### Step 1: Write a Failing Test

Write a test that exercises the exact scenario described in the bug report.
The test MUST:
- Target the specific behavior that is broken
- FAIL when run against the current code
- Fail for the RIGHT REASON (not a syntax error, import error, or unrelated failure)

Run the test. Confirm it fails. Include the failure output in your report.

### Step 2: If the Test Fails (Bug Reproduced)

Good. Now fix the bug with minimal changes:
- Change ONLY what is necessary to make the test pass
- Do NOT refactor surrounding code
- Do NOT fix other issues you notice
- Run ALL tests, not just yours

Report with status: `DONE`
Include: the failing test output (before), the passing test output (after),
and the diff of your fix.

### Step 3: If the Test Passes (Bug NOT Reproduced)

Do NOT guess a fix. Do NOT proceed with implementation.

Report with status: `BLOCKED_NON_REPRODUCIBLE`
Include:
- The test you wrote and its output (passing, not failing)
- Your analysis of why the bug might not reproduce in test
- Which of these three approaches you recommend:

**1. Defense-in-depth**
Add assertions, guards, and boundary validations on the affected code path.
Doesn't prove the bug existed, but prevents it (or variants) from passing
silently. Best when: the code path lacks defensive checks and the bug
is in a critical flow.

**2. Observability**
Instrument the code path with structured logs, metrics, or tracing.
The "test" becomes a monitor that detects recurrence in production.
Best when: the bug is environment-dependent or timing-sensitive and
cannot be reproduced in test.

**3. Hypothesis-driven hardening**
Document your most likely hypothesis for the root cause. Write a test
that attempts to provoke the scenario (it may pass — that's ok). Apply
a preventive fix based on the hypothesis. Best when: you have a strong
theory but can't deterministically trigger the condition.

The engineer will choose the approach. Wait for their decision.

### Infrastructure Escape Hatch

If the bug is in pure infrastructure that cannot be unit-tested
(deploy config, environment variables, CI pipeline, docker setup),
declare this in your report:

Report with status: `BLOCKED_INFRA`
Include: why this cannot be tested, what you would test if you could,
and your proposed fix for the engineer to review manually.

The spec reviewer will validate whether the infra justification is reasonable.

## What NOT To Do

- Do NOT write the fix before the failing test
- Do NOT assume the bug exists without evidence
- Do NOT fix adjacent issues while fixing the bug
- Do NOT report DONE without showing test output (before and after)
- Do NOT report DONE_WITH_CONCERNS for a non-reproduced bug — use BLOCKED_NON_REPRODUCIBLE
```

- [ ] **Step 2: Verify the file exists and is well-formed**

Run: `cat skills/delivery/bug-as-test-prompt.md | head -5`
Expected: Shows the title and first lines of the file.

- [ ] **Step 3: Commit**

```bash
git add skills/delivery/bug-as-test-prompt.md
git commit -m "feat: add bug-as-test prompt fragment for bugfix implementer subagents"
```

---

## Task 2: Create acceptance-gate-prompt.md

Prompt fragment loaded by the delivery skill when dispatching the spec reviewer for a `feature` task. Extends the standard spec reviewer with acceptance criteria validation.

**Files:**
- Create: `skills/delivery/acceptance-gate-prompt.md`

- [ ] **Step 1: Write the acceptance gate prompt fragment**

```markdown
# Acceptance Test Coverage — Spec Reviewer Extension

> Loaded by the delivery skill when the task is classified as `feature`.
> This is an EXTENSION to the standard Superpowers spec reviewer prompt —
> it adds acceptance-criteria-to-test mapping validation.

## Additional Review Requirement

Beyond verifying that the code implements what the spec requires, you MUST
verify that **tests prove the code works** — not just that the code exists.

## Acceptance Criteria to Validate

The brainstorm for this feature produced these acceptance criteria:

```
[ACCEPTANCE_CRITERIA]
```

## Your Additional Checks

For EACH criterion above:

1. **Find the test(s)** that exercise this criterion
   - Search test files for assertions that match the criterion's behavior
   - A criterion might be covered by one test or spread across multiple

2. **Verify the test is meaningful**
   - Does the test actually exercise the behavior, or just check a mock?
   - Would the test fail if the feature was removed?
   - Is the assertion specific enough to catch regressions?

3. **Report mapping**
   For each criterion, report one of:
   - `COVERED: [criterion] → [test file:line] — [what it tests]`
   - `WEAK: [criterion] → [test file:line] — [why it's weak]`
   - `MISSING: [criterion] — no test found`

## Decision Logic

- If ALL criteria are `COVERED`: proceed with normal spec review (approve/reject)
- If any are `WEAK`: flag in your report but do not auto-reject. Note what would make it stronger.
- If any are `MISSING`: **REJECT** with the list of uncovered criteria

## Escalation (Max 2 Attempts)

This gate runs at most twice. If after the second attempt criteria remain
`MISSING`, the gate escalates to the engineer:

> "Could not map tests to these criteria after 2 attempts:
> - [criterion X]
> Approve override, or reword the criteria?"

You do not need to track attempts — the delivery skill handles the counter.
Just report your findings honestly each time.

## What NOT To Do

- Do NOT invent criteria that weren't in the brainstorm
- Do NOT reject tests because they could be "more thorough" if they cover the criterion
- Do NOT check coverage percentage — check behavioral coverage against criteria
- Do NOT conflate this check with code quality review (that's a separate stage)
```

- [ ] **Step 2: Verify the file exists and is well-formed**

Run: `cat skills/delivery/acceptance-gate-prompt.md | head -5`
Expected: Shows the title and first lines of the file.

- [ ] **Step 3: Commit**

```bash
git add skills/delivery/acceptance-gate-prompt.md
git commit -m "feat: add acceptance gate prompt fragment for feature spec reviewers"
```

---

## Task 3: Create safety-gates.md for removedebt

Prompt fragment loaded by the removedebt skill during execution phase. Contains the complete 3-gate protocol.

**Files:**
- Create: `skills/removedebt/safety-gates.md`

- [ ] **Step 1: Write the safety gates prompt fragment**

```markdown
# Safety Gates Protocol — Removedebt Execution

> Loaded by the removedebt skill after findings are approved and before
> executing any refactor. This protocol wraps every execution category
> with test-based safety verification.

## Gate 1: Snapshot

Before executing ANY approved finding, capture the test baseline.

### Capture Process

1. Identify the project's test command:
   - Read `CLAUDE.md` for `test command` or `test` field
   - Fallback: check `package.json` scripts for `test`
   - Fallback: check for `pytest`, `go test`, `cargo test`, etc.
   - If no test command found: **STOP** — report to engineer

2. Run the full test suite and record:
   - Total tests, passed, failed, skipped
   - Which specific tests failed (these are `already-failing`)
   - Coverage per file (if coverage tool is available; if not, skip coverage checks later)

3. Present the baseline:
   > "Baseline captured: [N] pass, [N] fail (pre-existing), [N] skip.
   > [Coverage: N% | Coverage: not available]"

### Failure Handling

If the test command fails to run (not found, timeout, environment error):

> "Cannot establish test baseline. Without baseline, I cannot guarantee
> the refactor didn't break anything.
>
> Fix: configure the test command in CLAUDE.md (e.g., `test: npm test`)
> and try again."

**STOP.** Do not proceed without a baseline.

## Gate 2: Escape Hatch

After baseline is captured, before first execution.

### Ask Once

> "Can any tests break intentionally with these refactors?
>
> Examples:
> - Renaming public API changes integration tests
> - Consolidating types breaks tests importing the old type
> - Removing dead code breaks tests for the removed code
>
> Declare now which tests/patterns may break,
> or 'none' for total hard stop."

### Record and Freeze

Store the engineer's response as `escape_list`:
- `"none"` → `escape_list = []`
- Specific patterns → `escape_list = [patterns]`

**IMMUTABILITY RULE:** The `escape_list` is frozen at this moment. It
CANNOT be modified, extended, or overridden after the first refactor
category starts execution. This is not a suggestion — the list is
captured once and referenced read-only for all subsequent delta checks.

## Gate 3: Hard Stop with Delta

After EACH debt category execution (duplication, dead code, etc.).

### Delta Process

1. Run the full test suite again (same command as snapshot)

2. Compare against baseline:
   - **New failures:** tests that PASSED in baseline but now FAIL
   - **Filter:** remove any new failures that match `escape_list` patterns
   - **Coverage:** if coverage was available at snapshot, compare per touched file

3. Decision tree:

**New failures outside escape_list → HARD STOP**

> "[N] tests broke after [category]:
>
> FAIL: [test_name] (was PASS)
> FAIL: [test_name] (was PASS)
>
> These are NOT in your declared breaking changes list.
>
> Options:
> [A] Revert this category (git checkout the changes)
> [B] Investigate (I'll use systematic-debugging)
> [C] Continue anyway (you assume the risk)"

Wait for engineer's choice. Do not proceed automatically.

**New failures inside escape_list → LOG + CONTINUE**

> "[N] tests broke as declared: [list].
> Logging to debt-log. Continuing with next category."

**No new failures, but coverage dropped on touched files → WARNING**

> "Coverage dropped [X]% → [Y]% on [files]. Expected if code was
> removed. Want me to add tests to compensate?"

This is non-blocking — engineer decides.

**No new failures, coverage stable → CLEAN**

> "Category [name] clean. [N] pass, [N] fail (same as baseline).
> Proceeding to next category."

## Debt Log Test Fields

After all categories complete, add these fields to the debt-log entry:

```markdown
### Tests
- Baseline: [N] pass, [N] fail (pre-existing), [N]% coverage
- After: [N] pass, [N] fail (pre-existing), [N]% coverage
- Declared breaks: [N] ([description of each])
- Unexpected breaks: [N]
- Hard stops triggered: [N]
- Coverage delta: [+/-N]% ([reason])
```

If coverage was not available at snapshot time, record:
```markdown
### Tests
- Baseline: [N] pass, [N] fail (pre-existing), coverage: not available
- After: [N] pass, [N] fail (pre-existing), coverage: not available
- Declared breaks: [N]
- Unexpected breaks: [N]
- Hard stops triggered: [N]
```
```

- [ ] **Step 2: Verify the file exists and is well-formed**

Run: `cat skills/removedebt/safety-gates.md | head -5`
Expected: Shows the title and first lines of the file.

- [ ] **Step 3: Commit**

```bash
git add skills/removedebt/safety-gates.md
git commit -m "feat: add safety gates prompt fragment for removedebt execution"
```

---

## Task 4: Modify delivery SKILL.md — Add Phase 0 (Classify & Decompose)

Insert Phase 0 at the top of the skill body, before the existing "Decision: Superpowers Pipeline vs Ralph Loop" section. Phase 0 classifies the user's prompt and handles decomposition of mixed/overloaded prompts.

**Files:**
- Modify: `skills/delivery/SKILL.md` (insert Phase 0 between intro paragraph and Decision section)

- [ ] **Step 1: Insert Phase 0 section after the intro paragraph**

Use the Edit tool. Find the text anchor:
```
direct, technical, and skip introductory explanations.

## Decision: Superpowers Pipeline vs Ralph Loop
```
Insert the Phase 0 content between the intro paragraph and the Decision heading.
The old_string is the blank line + "## Decision" heading. The new_string prepends Phase 0 before it:

```markdown
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
```

- [ ] **Step 2: Verify Phase 0 appears before the Decision section**

Run: `grep -n "## Phase 0\|## Decision" skills/delivery/SKILL.md`
Expected: Phase 0 appears at a lower line number than Decision.

- [ ] **Step 3: Commit**

```bash
git add skills/delivery/SKILL.md
git commit -m "feat: add Phase 0 classify & decompose to delivery skill"
```

---

## Task 5: Modify delivery SKILL.md — Add Gate References

Add sections that reference the bug-as-test and acceptance-gate prompt fragments, integrating them into the Superpowers pipeline execution flow.

**Files:**
- Modify: `skills/delivery/SKILL.md` (add after the "### Execution" subsection under Superpowers Mode)

- [ ] **Step 1: Add testing gates section after the Execution subsection**

Use the Edit tool. Find the text anchor (in the already-modified file, after Task 4):
```
5. `superpowers:finishing-a-development-branch` → merge/PR/keep/discard

### Delivery-specific additions
```
Insert the Testing Gates section between step 5 and "### Delivery-specific additions".
The old_string is the blank line + "### Delivery-specific additions". The new_string prepends the Testing Gates section before it:

```markdown
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
```

- [ ] **Step 2: Verify the section appears in the right location**

Run: `grep -n "Testing Gates\|Delivery-specific" skills/delivery/SKILL.md`
Expected: "Testing Gates" appears before "Delivery-specific additions".

- [ ] **Step 3: Commit**

```bash
git add skills/delivery/SKILL.md
git commit -m "feat: add testing gate references to delivery skill execution flow"
```

---

## Task 6: Modify removedebt SKILL.md — Add Safety Gates Phase

Insert the safety gates phase between Phase 3 (Strategic Questions) and Phase 4 (Execution). This replaces the existing instructional text about running tests with an enforced protocol that references the safety-gates.md fragment.

**Files:**
- Modify: `skills/removedebt/SKILL.md` (insert safety gates between Phase 3 and Phase 4, update execution rules, update debt-log template)

**Note:** Phase 3.5 numbering is intentional — avoids renumbering Phase 4 and Phase 5. Do NOT "correct" to Phase 4 with subsequent renumbering.

- [ ] **Step 1: Insert Safety Gates phase before Execution**

Use the Edit tool. Find the text anchor:
```
Want to proceed with all, or pick specific priorities?
```

This is the end of Phase 3. Insert Phase 3.5 after this code block's closing and before "## Phase 4: Execution":

```markdown
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
```

- [ ] **Step 2: Update the existing Execution Rules to reference the gates**

Use the Edit tool. Find the exact text anchor in "### Execution Rules":

```markdown
- **Run ALL tests after each task**, not just related ones.
- **If a test breaks, STOP and ask the user.** Don't auto-fix — the
  break might reveal a dependency they know about.
```

With:

```markdown
- **Safety gates handle test verification.** After each category,
  Gate 3 runs the full test suite and compares with baseline.
  Do not run ad-hoc test checks — the gate protocol handles this.
- **If Gate 3 triggers a hard stop**, present the options to the user.
  Do not auto-fix or auto-revert.
```

- [ ] **Step 3: Update the debt-log template in Phase 5**

Use the Edit tool. Find the exact text anchor in the debt-log template within Phase 5:

```markdown
### Tests
- Before: [pass/fail count]
- After: [pass/fail count]
- Regressions: none | [description]
```

With:

```markdown
### Tests
- Baseline: [N] pass, [N] fail (pre-existing), [N]% coverage
- After: [N] pass, [N] fail (pre-existing), [N]% coverage
- Declared breaks: [N] ([description])
- Unexpected breaks: [N]
- Hard stops triggered: [N]
- Coverage delta: [+/-N]% ([reason])
```

- [ ] **Step 4: Verify the phases appear in correct order**

Run: `grep -n "## Phase" skills/removedebt/SKILL.md`
Expected: Phase 1, Phase 2, Phase 3, Phase 3.5, Phase 4, Phase 5 in order.

- [ ] **Step 5: Commit**

```bash
git add skills/removedebt/SKILL.md
git commit -m "feat: add safety gates phase to removedebt skill with snapshot, escape hatch, and hard stop"
```

---

## Task 7: Final Verification

Verify all files are in place and the repo structure matches the spec.

**Files:**
- Verify: all modified and new files

- [ ] **Step 1: Verify repo structure matches spec**

Run: `find skills/ -name "*.md" | sort`
Expected:
```
skills/delivery/SKILL.md
skills/delivery/acceptance-gate-prompt.md
skills/delivery/bug-as-test-prompt.md
skills/removedebt/SKILL.md
skills/removedebt/safety-gates.md
```

- [ ] **Step 2: Verify all cross-references resolve**

Run: `grep -r "bug-as-test-prompt\|acceptance-gate-prompt\|safety-gates" skills/`
Expected: Each fragment is referenced by its parent SKILL.md at least once.

- [ ] **Step 3: Verify no stale references remain**

Run: `grep -rn "TODO\|FIXME\|TBD\|PLACEHOLDER" skills/`
Expected: No matches (no unfinished placeholders).

- [ ] **Step 4: Verify Phase 0 classification table in delivery skill**

Run: `grep -c "feature\|bugfix\|chore\|mixed\|overloaded" skills/delivery/SKILL.md`
Expected: All 5 types appear.

- [ ] **Step 5: Verify gates summary in delivery skill**

Run: `grep "bug_as_test_gate\|acceptance_test_gate" skills/delivery/SKILL.md`
Expected: Both flags are referenced.

- [ ] **Step 6: Verify safety gates in removedebt skill**

Run: `grep "Snapshot\|Escape Hatch\|Hard Stop\|safety-gates.md" skills/removedebt/SKILL.md`
Expected: All three gates and the fragment reference appear.

- [ ] **Step 7: Review git log for clean commit history**

Run: `git log --oneline -7`
Expected: 6 new commits (Tasks 1-6) on top of existing history.
