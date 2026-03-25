# Model Selection

Model names and controls change.
The objective is stable behavior: use the newest suitable review-capable model the installed CLI clearly supports.

## Selection Rules

Choose the model in this order:

1. a user-specified model, if one was explicitly requested
2. the newest clearly supported review-capable model exposed by the installed CLI
3. the CLI default, if model availability cannot be determined confidently

Do not downgrade to an older model just because the skill was tested on a different CLI version.

## How To Determine "Latest Available"

Use the installed CLI's observable signals:

- model flags in help output
- subcommand help that mentions model selection
- config or validation surfaces that confirm supported model names

If the CLI exposes a model listing command or equivalent, use it.
If it does not, use the newest model you can confirm from the local CLI surface.

## Effort Selection

If the installed CLI exposes explicit reasoning or effort controls:

- ask the user to choose `Low`, `Medium`, or `High` using `AskUserQuestion`
- skip the question if the user already specified the effort level in the current request

If the installed CLI does not expose effort controls:

- proceed without asking
- note briefly that no explicit effort selector was detected if that matters to the workflow

## Ambiguity Handling

Ask the user only when multiple models are materially plausible and the choice could affect review quality.
If one model is clearly the newest suitable option, pick it and move on.

## Fallback Rule

If model discovery is incomplete:

- prefer the documented CLI default
- continue the review workflow
- mention the limitation only if it meaningfully affected the path you chose

The review quality matters more than pretending the model catalog is stable.
