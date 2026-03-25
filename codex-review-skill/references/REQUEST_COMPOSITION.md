# Request Composition

When you invoke Codex CLI for a review, constrain the request just enough to preserve review quality without over-specifying the method.
Define the target, the goal, and the output contract. Leave room for the model to think.

## Core Rule

Most review requests should include:

- scope
- primary review objective
- output expectations

Add extra focus areas only when the change justifies them.

## Required Ingredients

### Scope

State what should be reviewed:

- current uncommitted changes
- staged diff
- changes against a base branch
- a specific commit
- a named set of files

### Primary Review Objective

Use a compact objective centered on defects:

- correctness bugs
- regressions
- unsafe assumptions
- missing or weak tests

This is the default review core. Include it unless the user explicitly wants a different type of review.

### Output Expectations

Tell Codex what shape to return:

- findings ordered by severity
- file references when available
- open questions or assumptions
- residual risk

## Optional Focus Areas

Add these only when relevant to the change:

- security or privacy
- performance regressions
- API compatibility
- concurrency, state transitions, or lifecycle behavior
- migration or rollback risk
- documentation or spec alignment

Do not attach every focus area to every review request. That turns signal into wallpaper.

## Composition Style

Prefer short direct requests.
Do not turn the prompt into a checklist novella.
Do not script the reasoning process unless the user explicitly asks for a specialized methodology.

Good pattern:

`Review <scope>. Focus on correctness, regressions, unsafe assumptions, and missing tests. Return severity-ordered findings with file references where possible, then assumptions and residual risk.`

Adjust the middle clause only when the change calls for something more specific.

## Small Examples

Uncommitted changes:

`Review the current uncommitted changes. Focus on correctness, regressions, unsafe assumptions, and missing tests. Return severity-ordered findings with file references where possible, then assumptions and residual risk.`

Commit review:

`Review commit <sha> against <base>. Focus on correctness, retry behavior, and missing tests. Return only concrete findings ordered by severity, followed by assumptions and residual risk.`

Specific files:

`Review these files: <paths>. Focus on state handling, error propagation, and regression risk. Return severity-ordered findings with file references, then assumptions and residual risk.`

## Anti-Patterns

Avoid:

- long canned prompts with every possible concern
- forcing exact wording when equivalent wording is clearer
- requesting praise, summaries, or self-justification in the review prompt
- specifying methodology so tightly that the model cannot adapt to the code

The request should frame the review, not handcuff it.
