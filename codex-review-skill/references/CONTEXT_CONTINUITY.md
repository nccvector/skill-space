# Context Continuity

Codex should not start from zero by default.
Losing prior task context wastes time, repeats mistakes, and makes review quality worse because earlier decisions, inspected files, and unresolved questions disappear from working memory.

## Core Rule

Prefer `resume` for the same ongoing line of work.
Use `fork` when you want the same context but need a fresh branch of reasoning.
Start a fresh session only when the work has materially changed.

## Preferred Session Strategy

Use this order:

1. `resume` for the same task, repo, and general review thread
2. `fork` when the prior context is useful but the new work is a meaningful branch
3. fresh session only when continuity would be misleading or unavailable

## When To Prefer `resume`

Prefer `resume` when:

- reviewing follow-up changes in the same repository
- continuing the same review after interruption
- checking fixes for findings from the earlier review
- working on the same feature, bug, or handoff thread
- the workspace and problem are still fundamentally the same

Default to `resume` unless there is a strong reason not to.

## When To Use `fork`

Use `fork` when:

- the earlier context is still useful but you want a distinct branch of analysis
- you need to explore an alternative review approach without contaminating the original thread
- the task has shifted meaningfully within the same workspace, but earlier context still helps

`fork` preserves context, but it is not the default for normal continuation.

## When To Start Fresh

Start a new session only when:

- the workspace changed and you are now working on something entirely different
- the task shifted so far that prior context would be misleading
- the earlier session is unavailable and local artifacts cannot recover enough context
- the user explicitly wants a fresh start

Changing a few files is not a big shift. Changing the problem is.

## Avoid Starting From Zero

Do not casually start a fresh Codex session for ongoing work.
Starting from zero has real costs:

- repeated repo discovery
- duplicated review effort
- lower-quality follow-up reviews
- missed continuity between earlier findings and later fixes
- wasted tokens on context reconstruction

Fresh starts are sometimes necessary. They are not a virtue.

## Operational Guidance

If the CLI supports session continuation commands such as `resume` and `fork`, prefer them over a new `exec` run for ongoing work.
Do not use `--ephemeral` unless the user explicitly wants a disposable session.

When the previous session is unavailable:

- recover context from local review artifacts, diffs, and recent outputs
- include a short recap in the next request if needed
- preserve continuity manually rather than pretending there was none

## Short Heuristic

Ask yourself:

`Am I continuing the same work in the same workspace?`

If yes, prefer `resume`.
If mostly yes but the analysis should branch, use `fork`.
If no, start fresh.
