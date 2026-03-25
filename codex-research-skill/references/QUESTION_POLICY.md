# Question Policy

Use `AskUserQuestion` for every clarification prompt shown to the user.
Present neat options, not a loose interview transcript.

## General Rules

- Ask only when the answer cannot be discovered locally and the ambiguity matters.
- Do not ask about CLI version, command availability, or search support if you can inspect them yourself.
- Do not ask for an effort choice by default. This skill should prefer `High` automatically if available.
- Keep the number of questions low.

## Required Tool

All user-facing clarification prompts must use `AskUserQuestion`.
Do not switch to plain chat for option selection if `AskUserQuestion` is available.

## When To Ask

Ask when one of these is unclear and matters:

- research scope
- desired output artifact
- comparison target
- time horizon or recency requirement
- whether the user wants a summary, recommendation framework, or source digest

## When Not To Ask

Do not ask when:

- the topic and goal are already clear
- a reasonable default will not reduce research quality
- the answer can be recovered from repo context or prior session context
- effort controls exist and the skill already has a default policy

## Standard Option Sets

Use compact option sets for common choices.

### Research Scope

- `Broad landscape`
- `Focused question`
- `Compare options`

### Output Shape

- `Summary`
- `Recommendation framework`
- `Source digest`

### Time Horizon

- `Current state`
- `Recent changes`
- `Stable background`

## If `AskUserQuestion` Is Missing

If the runtime unexpectedly lacks `AskUserQuestion`, note that limitation briefly and use the narrowest plain-language question necessary.
This is a fallback, not the default.
