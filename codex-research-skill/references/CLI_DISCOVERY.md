# CLI Discovery

Start by discovering what the installed Codex CLI can actually do on this system.
Do not assume command names, search flags, model controls, or continuation features match the tested baseline.

## What To Inspect First

Collect these facts before running a research task:

- installed Codex CLI version
- available top-level commands
- whether `exec` is available
- whether `resume` and `fork` are available
- whether `--search` is supported
- whether model selection is supported
- whether explicit reasoning or effort controls are exposed

## Preferred Discovery Order

Use the lightest commands first:

1. `codex --version`
2. `codex --help`
3. `codex exec --help` if `exec` exists
4. other focused help commands only if needed

Keep discovery focused on research-relevant capability.

## Capability Checklist

Record the answers to these questions:

- Can Codex run non-interactively with `exec`?
- Can Codex continue prior work with `resume` or `fork`?
- Can Codex web search be enabled explicitly?
- Is there a `--model` flag or equivalent config override?
- Is there any explicit effort, reasoning, or thinking control?
- Can research output be shaped through prompt instructions alone?

## Search Discovery

Research quality depends heavily on search.
Look for:

- top-level `--search`
- any research-capable command that inherits top-level options
- help text that confirms the native web search tool is available

If search is supported, enable it explicitly for research runs.
Do not hope the model will improvise external evidence from the void.

## Model And Effort Discovery

Inspect help output for:

- `--model`
- config overrides related to model choice
- explicit `--effort`, `--reasoning-effort`, or similar controls
- config surfaces that expose reasoning or thinking options

If no effort control is visible, treat it as unavailable and continue.

## If Discovery Is Incomplete

If some capability remains unclear:

- continue with the best supported research path you can verify
- ask the user a clarifying question only if the ambiguity materially affects research quality
- note the limitation briefly if it changed the workflow

Research should be adaptable, not fragile.
