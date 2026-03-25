# Review Workflow

The goal is to find problems in existing work.
Default to a code review mindset: prioritize bugs, regressions, risky behavior changes, and missing tests.

## Scope Selection

Choose scope using the strongest local signal available:

- use staged or PR-style scope if the user asked for it
- use the current working tree diff otherwise
- use a specific commit or file set if the user named one

If the scope is genuinely ambiguous and the choice would change the review outcome, ask via `AskUserQuestion`.

## Context Gathering

Before judging the change:

- read the changed files
- read adjacent tests if present
- read nearby code needed to understand control flow or data flow
- read docs or specs only if they are directly relevant

Do not read the whole repo for a five-line change unless the five lines are loaded with consequences.

## Review Priorities

Look for these first:

- correctness bugs
- regressions relative to prior behavior
- missing validation or unsafe assumptions
- edge cases and error handling gaps
- data loss, privacy, or security issues when relevant
- concurrency, state, or lifecycle mistakes
- missing or inadequate tests for risky logic

Style comments are low priority unless they hide a real defect.

## What Counts As A Finding

A finding should identify a real or likely defect, regression, or verification gap.
Good findings are specific, testable, and tied to code.

Good examples:

- logic fails for an empty input path
- error from a dependency is swallowed, hiding a failed write
- behavior changed but tests still only cover the old branch
- cleanup path leaks state after a retry

Weak examples:

- code is a bit hard to read
- maybe rename this variable
- I would structure this differently

## No-Findings Behavior

If no findings are identified:

- say so explicitly
- state what scope you reviewed
- mention anything you could not verify
- mention residual risk, especially around untested behavior

No findings is allowed. False confidence is not.

## Review Versus Repair

Do not silently patch code during the review pass.
If the user asks for fixes after the review, switch modes explicitly and then make changes.

Keep the boundary crisp:

- review mode identifies problems
- fix mode changes code

Combining them without saying so produces neat output and bad process.
