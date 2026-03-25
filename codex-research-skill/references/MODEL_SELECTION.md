# Model Selection

Model names and controls change.
The objective is stable behavior: use the newest suitable research-capable model the installed CLI clearly supports.

## Official Model Source

The canonical reference for Codex-compatible models is:

- `https://developers.openai.com/codex/models`

Use that page when model naming is unclear or when the CLI does not expose a way to enumerate models.
Do not guess from unrelated OpenAI model names. `o3` is an example of a name that may exist elsewhere but is not listed on the Codex models page.

## Selection Rules

Choose the model in this order:

1. a user-specified model, if one was explicitly requested
2. the newest clearly supported research-capable model confirmed by the installed CLI or the official Codex models page
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
- the official Codex models page when local enumeration is unavailable

If the CLI exposes a model listing command or equivalent, use it.
If it does not, consult the official Codex models page and use the newest suitable model you can confirm there.
If that still leaves ambiguity about what the local installation will accept, use the default model by omitting `-m`.

## Ambiguity Handling

Ask the user only when multiple models are materially plausible and the choice could affect research quality.
If one model is clearly the newest suitable option, pick it and move on.

## Fallback Rule

If model discovery is incomplete:

- prefer the documented CLI default by omitting `-m`
- continue the research workflow
- mention the limitation only if it meaningfully affected the path you chose
