# Version Policy

This skill was tested with Codex CLI `0.115.0`.
Other versions are allowed. A mismatch is a compatibility event, not a reason to abandon the research task.

## Required Mismatch Behavior

When the detected Codex CLI version differs from `0.115.0`:

1. briefly inform the user in chat
2. continue with capability discovery
3. adapt commands and flags to the installed CLI
4. preserve the same research behavior even if the command surface changed

## Short Chat Note

Use a short factual note.

Recommended wording:

`Codex CLI version note: this skill was tested with 0.115.0, and this system has <detected-version>. I’m proceeding with capability discovery and will adapt if the CLI surface differs.`

If the detected version matches `0.115.0`, no mismatch note is needed.

## Feature Mapping Rules

Map current CLI capabilities onto the skill workflow in this order:

1. `exec` with explicit search enabled
2. interactive top-level run with explicit search enabled
3. local-only research fallback if web search is unavailable

Preserve these invariants:

- prefer resumed context for ongoing work
- use web search aggressively when available
- prefer high effort if explicitly supported
- gather evidence before conclusions
- produce a clear evidence-backed output

## Missing Or Renamed Features

If an expected flag or command is missing:

- re-check the relevant help output
- look for an equivalent in another research-capable command
- prefer documented alternatives over guesswork
- if still unavailable, use the next fallback path

## Hard Fallback Rule

If the installed CLI cannot support live web search:

- continue with local and provided materials
- say clearly that external web search was unavailable
- avoid presenting stale model memory as if it were verified current research

The user asked for research, not confident archaeology.
