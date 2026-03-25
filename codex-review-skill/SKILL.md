---
name: codex-review-skill
description: "Use this skill whenever an agent needs to review work already done in the current repository, especially self-review before handoff. Trigger for: reviewing the current diff, staged changes, a commit, or a set of modified files; running a Codex CLI review workflow; checking work completed by an AI agent for bugs, regressions, missing tests, risky assumptions, or incomplete implementation; adapting review behavior across changing Codex CLI versions, commands, and model availability. Use even when the user says 'review my work', 'self-review this', 'audit these changes', 'run codex review', or similar. Do not use for implementation-first requests unless review is explicitly part of the task."
---

# Codex Review Skill

Use this skill to review existing work, not to defend it.
If you wrote the code, review it as if somebody else did and you do not trust it yet.

## Tested Baseline

- Tested with Codex CLI version: `0.115.0`
- Last verified: `2026-03-25`
- If the installed Codex CLI version differs, briefly inform the user in chat and continue using [references/VERSION_POLICY.md](references/VERSION_POLICY.md).

## Non-Negotiable Rules

- Review first. Do not silently fix issues during the review pass unless the user explicitly asks for that.
- Findings come before summaries. A review is not a retrospective victory lap.
- Treat your own implementation as suspect. Intent is not evidence.
- Prefer continuing Codex context over starting fresh. Reuse context unless there is a real reason not to.
- Use `AskUserQuestion` for every clarification prompt shown to the user.
- If the user already specified the reasoning or effort level in the current request, do not ask again.
- Do not ask about information you can discover locally from the repo or Codex CLI.
- Keep every markdown file in this skill under `400` lines and `5000` words. Load references selectively.

## Review Sequence

1. Detect the installed Codex CLI version and relevant capabilities using [references/CLI_DISCOVERY.md](references/CLI_DISCOVERY.md).
2. Preserve or recover task context using [references/CONTEXT_CONTINUITY.md](references/CONTEXT_CONTINUITY.md).
3. Compare the detected version against the tested baseline and apply [references/VERSION_POLICY.md](references/VERSION_POLICY.md).
4. Select a model and determine whether effort controls are available using [references/MODEL_SELECTION.md](references/MODEL_SELECTION.md).
5. Compose a concise review request for the installed CLI using [references/REQUEST_COMPOSITION.md](references/REQUEST_COMPOSITION.md).
6. Ask only the minimum necessary clarifying questions via `AskUserQuestion`, following [references/QUESTION_POLICY.md](references/QUESTION_POLICY.md).
7. Run the review workflow in [references/REVIEW_WORKFLOW.md](references/REVIEW_WORKFLOW.md).
8. Return output using [references/OUTPUT_FORMAT.md](references/OUTPUT_FORMAT.md).

## Reference Map

- Read [references/CLI_DISCOVERY.md](references/CLI_DISCOVERY.md) first when the installed CLI version, commands, or flags are unknown.
- Read [references/CONTEXT_CONTINUITY.md](references/CONTEXT_CONTINUITY.md) before starting a new Codex session or when deciding between `resume`, `fork`, and a fresh run.
- Read [references/VERSION_POLICY.md](references/VERSION_POLICY.md) when the detected CLI version differs from `0.115.0` or expected commands are missing.
- Read [references/MODEL_SELECTION.md](references/MODEL_SELECTION.md) when choosing a model or reasoning effort.
- Read [references/REQUEST_COMPOSITION.md](references/REQUEST_COMPOSITION.md) when preparing the actual Codex CLI review request.
- Read [references/QUESTION_POLICY.md](references/QUESTION_POLICY.md) before asking the user anything.
- Read [references/REVIEW_WORKFLOW.md](references/REVIEW_WORKFLOW.md) for review scope, bug-finding priorities, and fallback paths.
- Read [references/OUTPUT_FORMAT.md](references/OUTPUT_FORMAT.md) before writing the final review.
