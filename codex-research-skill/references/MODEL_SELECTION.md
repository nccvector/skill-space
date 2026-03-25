# Model Selection

Model names and controls change.
The objective is stable behavior: use the newest suitable research-capable model the installed CLI clearly supports.

## Official Model Source

The canonical reference for Codex-compatible models is:

- `https://developers.openai.com/codex/models`

Use that page when model naming is unclear or when the CLI does not expose a way to enumerate models.
Do not guess from unrelated OpenAI model names. `o3` is an example of a name that may exist elsewhere but is not listed on the Codex models page.
Treat local model availability as unclear by default unless you have stronger evidence than help-text examples.

## Selection Rules

Choose the model in this order:

1. a user-specified model, if one was explicitly requested
2. the newest clearly supported research-capable model confirmed by a trustworthy source
3. the CLI default, if model availability cannot be determined confidently

In practice, ambiguity is the normal case. Prefer the default model unless you can verify a specific Codex model cleanly.

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

Use only trustworthy signals:

- an explicit local model-listing or validation mechanism, if the CLI provides one
- the official Codex models page
- a user-specified model

Do not treat example model names shown in `codex --help` or subcommand help as proof that those models are available locally.

If the CLI exposes a model listing command or equivalent, use it.
If it does not, consult the official Codex models page.
If local acceptance is still ambiguous after that, use the default model by omitting `-m`.

## Ambiguity Handling

Ask the user only when multiple models are materially plausible and the choice could affect research quality.
If one model is clearly the newest suitable option, pick it and move on.

## Fallback Rule

If model discovery is incomplete:

- prefer the documented CLI default by omitting `-m`
- continue the research workflow
- mention the limitation only if it meaningfully affected the path you chose
