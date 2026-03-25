# Model Selection

Model names and controls change.
The objective is stable behavior: use the newest suitable review-capable model the installed CLI clearly supports.

## Official Model Source

The canonical reference for Codex-compatible models is:

- `https://developers.openai.com/codex/models`

Use that page when model naming is unclear or when the CLI does not expose a way to enumerate models.
Do not guess from unrelated OpenAI model names. `o3` is an example of a model name that may be valid elsewhere but is not listed on the Codex models page.
Treat local model availability as unclear by default unless you have stronger evidence than help-text examples.

## Selection Rules

Choose the model in this order:

1. a user-specified model, if one was explicitly requested
2. the newest clearly supported review-capable model confirmed by a trustworthy source
3. the CLI default, if model availability cannot be determined confidently

Do not downgrade to an older model just because the skill was tested on a different CLI version.
If there is real confusion about model availability, omit `-m` and let Codex use its default model.
In practice, ambiguity is the normal case. Prefer the default model unless you can verify a specific Codex model cleanly.

## How To Determine "Latest Available"

Use only trustworthy signals:

- an explicit local model-listing or validation mechanism, if the CLI provides one
- the official Codex models page
- a user-specified model

Do not treat example model names shown in `codex --help` or subcommand help as proof that those models are available locally.

If the CLI exposes a model listing command or equivalent, use it.
If it does not, consult the official Codex models page.
If local acceptance is still ambiguous after that, use the default model by omitting `-m`.

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

- prefer the documented CLI default by omitting `-m`
- continue the review workflow
- mention the limitation only if it meaningfully affected the path you chose

The review quality matters more than pretending the model catalog is stable.
