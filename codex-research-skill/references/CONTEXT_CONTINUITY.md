# Context Continuity

Codex should not start from zero by default.
Research often spans multiple rounds, and losing prior context means repeated search setup, duplicated source gathering, and weaker synthesis.

## Core Rule

Prefer `resume` for the same ongoing line of research.
Use `fork` when you want the same context but need a new branch of investigation.
Start a fresh session only when the work has materially changed.

## Preferred Session Strategy

Use this order:

1. `resume` for the same topic, workspace, and research thread
2. `fork` when the prior context is useful but the investigation needs a meaningful branch
3. fresh session only when continuity would be misleading or unavailable

## When To Prefer `resume`

Prefer `resume` when:

- continuing the same research topic after interruption
- refining an earlier research summary
- following up on sources or open questions from the prior run
- researching the same design or implementation decision in the same repo
- the workspace and main question are still fundamentally the same

Default to `resume` unless there is a strong reason not to.

## When To Use `fork`

Use `fork` when:

- the earlier context is still useful but you need a distinct branch of inquiry
- you want to compare two competing research directions without muddying the original thread
- the topic shifted within the same workspace, but earlier findings still matter

`fork` preserves context, but it is not the default for ordinary continuation.

## When To Start Fresh

Start a new session only when:

- the workspace changed and you are now working on something entirely different
- the research question changed so much that old context would mislead the new run
- the earlier session is unavailable and local artifacts cannot recover enough context
- the user explicitly wants a fresh start

Switching sub-questions is not automatically a fresh-start event.

## Avoid Starting From Zero

Do not casually start a fresh Codex session for ongoing research.
Starting from zero has real costs:

- repeated search setup
- duplicated source discovery
- weaker continuity between earlier and later findings
- wasted time rebuilding the same background
- more opportunities to miss prior caveats or unresolved questions

Fresh starts are sometimes necessary. They are not the enlightened path.

## Operational Guidance

If the CLI supports session continuation commands such as `resume` and `fork`, prefer them over a new `exec` run for ongoing work.
Do not use `--ephemeral` unless the user explicitly wants a disposable session.

When the previous session is unavailable:

- recover context from local notes, previous research outputs, and relevant docs
- include a short recap in the next request if needed
- preserve continuity manually rather than pretending there was none

## Short Heuristic

Ask yourself:

`Am I still working on the same topic in the same workspace?`

If yes, prefer `resume`.
If mostly yes but the investigation should branch, use `fork`.
If no, start fresh.
