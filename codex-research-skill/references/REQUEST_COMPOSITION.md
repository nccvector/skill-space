# Request Composition

When you invoke Codex CLI for research, constrain the request just enough to preserve quality without over-specifying the method.
Define the topic, the research goal, and the output contract. Leave room for the model to investigate.

## Core Rule

Most research requests should include:

- topic or question
- research objective
- explicit search instruction
- output expectations

Add extra focus areas only when the topic justifies them.

## Required Ingredients

### Topic Or Question

State what should be researched:

- a technical question
- a design concern
- a dependency or vendor choice
- an implementation risk
- a recent event, change, or capability

### Research Objective

Use a compact objective centered on evidence:

- gather current facts
- compare credible options
- identify tradeoffs
- surface risks, unknowns, and open questions

### Explicit Search Instruction

Tell Codex to use web search directly.
Do not leave this implicit.

Good examples:

- `Use web search aggressively.`
- `Perform multiple web searches and refine queries as needed.`
- `Use live web search to gather current evidence before concluding.`

### Output Expectations

Tell Codex what shape to return:

- evidence-backed summary
- cited or attributed source notes when relevant
- key options or findings
- open questions
- residual uncertainty

## Optional Focus Areas

Add these only when relevant:

- performance
- security or privacy
- compliance or standards
- migration risk
- implementation complexity
- cost or operational burden

Do not attach every possible angle to every research prompt.

## Composition Style

Prefer short direct requests.
Do not turn the prompt into a giant procedure manual.
Do explicitly tell Codex to search broadly and thoroughly.

Good pattern:

`Research <topic>. Use web search aggressively and perform multiple searches until you have enough current evidence. Focus on <goal>. Return an evidence-backed summary, key findings or options, open questions, and residual uncertainty.`

Adjust the focus clause only when the topic calls for something more specific.

## Small Examples

General research:

`Research <topic>. Use web search aggressively and perform multiple searches until you have enough current evidence. Focus on current facts, tradeoffs, and major risks. Return an evidence-backed summary, key findings, open questions, and residual uncertainty.`

Comparison:

`Compare <option A> and <option B> for <use case>. Use web search aggressively and gather current evidence from primary or official sources where possible. Return the main tradeoffs, recommendation criteria, open questions, and residual uncertainty.`

Recent changes:

`Research the latest state of <product or policy>. Use live web search aggressively and verify recency with concrete dates. Return the current position, important changes, source-backed evidence, and any remaining uncertainty.`

## Anti-Patterns

Avoid:

- vague prompts that never explicitly request web search
- one-shot prompts that imply shallow investigation is enough
- long canned prompts listing every possible concern
- forcing exact wording when equivalent wording is clearer
- instructing the model so tightly that it cannot adapt the investigation

The request should frame the research, not suffocate it.
