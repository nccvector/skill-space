# Model Selection

Model names and controls change.
The objective is stable behavior: use the newest suitable research-capable model the installed CLI clearly supports.

## Selection Rules

Choose the model in this order:

1. a user-specified model, if one was explicitly requested
2. the newest clearly supported research-capable model exposed by the installed CLI
3. the CLI default, if model availability cannot be determined confidently

## Effort Policy

If the installed CLI exposes explicit reasoning or effort controls:

- prefer `High` by default for this skill
- do not ask the user to choose between low, medium, and high unless the user asked for that choice
- if the user explicitly requested a different effort level, follow the user

Research quality benefits from depth. This skill should not timidly choose a cheaper brain when a better one is available.

If the installed CLI does not expose effort controls:

- proceed without asking
- note briefly that no explicit effort selector was detected only if that matters to the workflow

## How To Determine "Latest Available"

Use the installed CLI's observable signals:

- model flags in help output
- subcommand help that mentions model selection
- config or validation surfaces that confirm supported model names

If the CLI exposes a model listing command or equivalent, use it.
If it does not, use the newest model you can confirm from the local CLI surface.

## Ambiguity Handling

Ask the user only when multiple models are materially plausible and the choice could affect research quality.
If one model is clearly the newest suitable option, pick it and move on.

## Fallback Rule

If model discovery is incomplete:

- prefer the documented CLI default
- continue the research workflow
- mention the limitation only if it meaningfully affected the path you chose
