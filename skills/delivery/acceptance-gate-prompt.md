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
