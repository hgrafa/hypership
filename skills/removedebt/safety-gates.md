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
