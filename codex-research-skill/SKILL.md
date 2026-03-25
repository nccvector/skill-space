---
name: codex-research-skill
description: "Use this skill whenever an agent needs Codex CLI to perform thorough research on a topic, concern, decision, dependency, technology, incident, standard, or implementation question. Trigger for: researching options before implementation, investigating technical questions, gathering recent information with web search, comparing tools or approaches, producing evidence-backed summaries, writing research markdown files, or continuing an existing research thread with Codex context. Use even when the user says 'research this', 'look this up', 'investigate', 'do web searches', 'compare these options', or similar. Do not use for pure implementation-only requests unless research is explicitly part of the task."
---

# Codex Research Skill

Use this skill to make Codex a serious research partner.
The goal is thorough, evidence-backed investigation, not a quick guess with nice formatting.

## Tested Baseline

- Tested with Codex CLI version: `0.115.0`
- Last verified: `2026-03-25`
- If the installed Codex CLI version differs, briefly inform the user in chat and continue using [references/VERSION_POLICY.md](references/VERSION_POLICY.md).

## Non-Negotiable Rules

- Prefer continuing Codex context over starting fresh. Reuse context unless there is a real reason not to.
- Research mode should aggressively use web search when available. Do not rely only on prior model memory for topics that can benefit from external verification.
- Explicitly enable Codex web search when the installed CLI supports it.
- Prefer high reasoning effort whenever the installed CLI exposes an effort control. If the user already specified a different effort level explicitly, follow the user.
- Use `AskUserQuestion` for every clarification prompt shown to the user.
- Ask only when the ambiguity materially affects research quality and cannot be resolved locally.
- Keep every markdown file in this skill under `400` lines and `5000` words. Load references selectively.

## Research Sequence

1. Detect the installed Codex CLI version and relevant capabilities using [references/CLI_DISCOVERY.md](references/CLI_DISCOVERY.md).
2. Preserve or recover task context using [references/CONTEXT_CONTINUITY.md](references/CONTEXT_CONTINUITY.md).
3. Compare the detected version against the tested baseline and apply [references/VERSION_POLICY.md](references/VERSION_POLICY.md).
4. Select a model and prefer high effort if available using [references/MODEL_SELECTION.md](references/MODEL_SELECTION.md).
5. Turn on web search and apply [references/SEARCH_POLICY.md](references/SEARCH_POLICY.md).
6. Compose a concise research request using [references/REQUEST_COMPOSITION.md](references/REQUEST_COMPOSITION.md).
7. Ask only the minimum necessary clarifying questions via `AskUserQuestion`, following [references/QUESTION_POLICY.md](references/QUESTION_POLICY.md).
8. Run the research workflow in [references/RESEARCH_WORKFLOW.md](references/RESEARCH_WORKFLOW.md).
9. Return output using [references/OUTPUT_FORMAT.md](references/OUTPUT_FORMAT.md).

## Reference Map

- Read [references/CLI_DISCOVERY.md](references/CLI_DISCOVERY.md) first when the installed CLI version, commands, or flags are unknown.
- Read [references/CONTEXT_CONTINUITY.md](references/CONTEXT_CONTINUITY.md) before starting a new Codex session or when deciding between `resume`, `fork`, and a fresh run.
- Read [references/VERSION_POLICY.md](references/VERSION_POLICY.md) when the detected CLI version differs from `0.115.0` or expected commands are missing.
- Read [references/MODEL_SELECTION.md](references/MODEL_SELECTION.md) when choosing a model or reasoning effort.
- Read [references/SEARCH_POLICY.md](references/SEARCH_POLICY.md) before running the research prompt.
- Read [references/REQUEST_COMPOSITION.md](references/REQUEST_COMPOSITION.md) when preparing the actual Codex CLI research request.
- Read [references/QUESTION_POLICY.md](references/QUESTION_POLICY.md) before asking the user anything.
- Read [references/RESEARCH_WORKFLOW.md](references/RESEARCH_WORKFLOW.md) for scope, evidence standards, and fallback paths.
- Read [references/OUTPUT_FORMAT.md](references/OUTPUT_FORMAT.md) before writing the final research summary.
