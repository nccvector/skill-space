# Output Format

Return findings first.
The user asked for review, not a narrated tour of your process.

## Required Section Order

Use this order:

1. `Findings`
2. `Open questions / assumptions`
3. `Residual risk`

If there are no findings, still include the latter two sections when they add value.

## Finding Template

Each finding should include:

- severity: `P0`, `P1`, `P2`, or `P3`
- file and line reference when available
- concise issue statement
- why it matters
- failure mode, repro condition, or missing test signal when relevant

Order findings from highest severity to lowest.

## Severity Guidance

- `P0`: catastrophic or release-blocking failure
- `P1`: serious correctness, safety, or data integrity issue
- `P2`: meaningful bug, regression risk, or missing verification for important behavior
- `P3`: lower-severity issue worth fixing, but not a major blocker

Do not inflate severity to sound busy.

## No-Findings Template

If no findings are identified, say so explicitly.
Include:

- what scope was reviewed
- what evidence was inspected
- what could not be verified

Example shape:

`No findings identified in the reviewed scope. I checked <scope>, read the changed files and related tests, and did not find a concrete defect. I did not verify <unverified area>, so residual risk remains there.`

## Open Questions / Assumptions

Use this section for:

- assumptions required to interpret the change
- unanswered questions that could change the review result
- missing product or behavioral context

Keep it short. If the question is important enough to block confidence, say that plainly.

## Residual Risk

Use this section even when findings exist if there are meaningful unverified areas:

- untested edge cases
- unrun integration paths
- behavior gated behind environment-specific conditions
- code paths inferred but not executed

A good review can still end with uncertainty. Say where it lives.
