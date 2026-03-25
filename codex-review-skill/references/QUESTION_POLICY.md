# Question Policy

Use `AskUserQuestion` for every clarification prompt shown to the user.
Present neat options, not free-form essays.

## General Rules

- Ask only when the answer cannot be discovered locally and the ambiguity matters.
- Do not ask about CLI version, repo state, changed files, or command availability if you can inspect them yourself.
- Do not ask for an effort level if the user already specified one in the current request.
- Keep the number of questions low. A review should not feel like tax season.

## Required Tool

All user-facing clarification prompts must use `AskUserQuestion`.
Do not switch to plain chat for option selection if `AskUserQuestion` is available.

## When To Ask

Ask when one of these is unclear and matters:

- review scope
- review mode
- reasoning or effort level, if supported by the installed CLI and not already specified
- base branch or commit target when multiple plausible choices exist

## When Not To Ask

Do not ask when:

- the repo state makes the scope obvious
- the user already requested staged, uncommitted, or commit-based review
- effort controls are not actually available in the installed CLI
- you can proceed safely with a documented default

## Standard Option Sets

Use compact option sets for common choices.

### Review Scope

- `Staged diff`
- `Working tree`
- `Specific files`

### Review Mode

- `Review only`
- `Review then fix`

Only offer `Review then fix` if the user asked for review with possible follow-up edits.

### Effort Level

- `Low`
- `Medium`
- `High`

Ask for effort only if the installed CLI exposes that control and the user did not already choose it.

## If `AskUserQuestion` Is Missing

If the runtime unexpectedly lacks `AskUserQuestion`, note that limitation briefly and use the narrowest plain-language question necessary.
This is a fallback, not the default.
