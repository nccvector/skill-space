# Version Policy

This skill was tested with Codex CLI `0.115.0`.
Other versions are allowed. A mismatch is a compatibility event, not a failure condition.

## Required Mismatch Behavior

When the detected Codex CLI version differs from `0.115.0`:

1. briefly inform the user in chat
2. continue with capability discovery
3. adapt commands and flags to the installed CLI
4. fall back to a manual review workflow if the native review path is unavailable

Do not stop just because the version changed.

## Short Chat Note

Use a short factual note. Keep it to one or two sentences.

Recommended wording:

`Codex CLI version note: this skill was tested with 0.115.0, and this system has <detected-version>. I’m proceeding with capability discovery and will adapt if the CLI surface differs.`

If the detected version matches `0.115.0`, no mismatch note is needed.

## Feature Mapping Rules

Map current CLI capabilities onto the skill workflow in this order:

1. native `codex review` command
2. `codex exec` with explicit review instructions
3. manual repository review using local diffs and changed files

Preserve the same review behavior even if the command path changes:

- define the review scope clearly
- inspect changed code and nearby tests
- bias toward bug-finding and regressions
- produce findings-first output

## Missing or Renamed Features

If an expected flag or command is missing:

- re-check the relevant help output
- look for an equivalent in another review-capable command
- prefer documented alternatives over guesswork
- if still unavailable, use the next fallback path

Unknown flags should be treated as a signal to adapt, not to improvise unsupported syntax.

## Hard Fallback Rule

If the installed CLI cannot support the intended native review flow:

- perform the review manually against the repo state
- keep the same output contract
- state the limitation briefly if it affected the path you used

The user asked for a coherent review experience, not a command taxonomy lecture.
