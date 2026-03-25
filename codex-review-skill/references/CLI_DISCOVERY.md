# CLI Discovery

Start by discovering what the installed Codex CLI can actually do on this system.
Do not assume command names, flags, or model controls match the tested baseline.

## What To Inspect First

Collect these facts before choosing a review command:

- installed Codex CLI version
- available top-level commands
- help output for review-related commands
- whether the CLI exposes a dedicated review command
- whether model selection is supported
- whether reasoning or effort controls are exposed directly

## Preferred Discovery Order

Use the lightest commands first:

1. `codex --version`
2. `codex --help`
3. `codex review --help` if `review` exists
4. `codex exec --help` if `exec` exists
5. additional focused help commands only if needed

Keep discovery targeted. You are mapping capability, not auditioning every flag in the binary.

## Capability Checklist

Record the answers to these questions:

- Is there a native `review` command?
- Can the CLI review uncommitted changes directly?
- Can the CLI review against a base branch or specific commit?
- Is there a `--model` flag or equivalent config override?
- Is there any explicit effort, reasoning, or thinking control?
- If there is no native review command, can `exec` still be used to run a review-style prompt?

## Model Discovery

Model discovery may move around across versions. Try these options in order:

1. inspect top-level help for `--model`
2. inspect review or exec help for model flags
3. inspect config or feature help only if needed
4. infer from documented examples only as a last resort

If the CLI exposes a concrete way to list or validate models, use it.
If model availability is only partially visible, choose the newest clearly supported review-capable model you can confirm.

## Effort Discovery

Effort controls are unstable across versions. Look for:

- explicit `--effort`, `--reasoning-effort`, or similar flags
- documented config keys related to reasoning or thinking effort
- review-specific help text that exposes low, medium, or high options

If none of these are visible, treat effort control as unavailable.
Do not invent a flag because the docs would have been nicer that way.

## If Discovery Is Incomplete

If some capabilities remain unclear:

- continue with the best supported review path you can verify
- ask the user a clarifying question only if the ambiguity materially affects review quality
- note the limitation briefly if it affects the chosen workflow

Discovery should reduce uncertainty, not become the main event.
