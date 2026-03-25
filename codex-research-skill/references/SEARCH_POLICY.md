# Search Policy

For this skill, web search is not optional decoration.
When the installed Codex CLI supports search, enable it explicitly and use it aggressively.

## Core Rule

If `--search` or an equivalent live web-search capability is available:

- enable it explicitly
- tell Codex to perform multiple searches
- tell Codex to keep searching until it has enough evidence to answer well

Do not assume the model will search on its own just because search is available.

## Search Expectations

Research runs should normally:

- perform multiple search queries
- refine queries as new evidence appears
- compare sources rather than stopping at the first plausible result
- use more searches when the topic is broad, recent, disputed, or high-stakes

`As many as it can` should be interpreted sensibly: enough to cover the question thoroughly, not one search and a shrug.

## Source Quality

Prefer:

- primary sources
- official documentation
- standards bodies
- vendor documentation for vendor-specific behavior
- reputable technical publications when primary sources are unavailable

Treat forums, summaries, and AI-generated content as lower-trust unless corroborated.

## Recency Rules

Use extra search depth when the topic is time-sensitive:

- recent product behavior
- pricing
- policies
- release notes
- regulations
- security issues

When recency matters, mention concrete dates in the answer.

## If Search Is Unavailable

If live web search is not available in the installed CLI:

- say so briefly
- continue with local materials and stable knowledge only
- distinguish clearly between verified evidence and unverified recollection

No search means reduced confidence, not pretend confidence.
