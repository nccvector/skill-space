# TEMPLATES_ARTIFACTS.md

Templates for design artifacts, research notes, backlog items, and plan files.
See [TEMPLATES.md](TEMPLATES.md) for root-level file templates.

All filenames follow `ALL_CAPS_WITH_UNDERSCORES` convention.
All templates respect the documented 400-line and 8000-word limits.

---

## RFC Template

File: `docs/design/RFC_XXXX_SHORT_TITLE.md`

```markdown
# RFC-XXXX: Short Title

| Field | Value |
|-------|-------|
| Status | DRAFT |
| Author | Name |
| Created | YYYY-MM-DD |
| Updated | YYYY-MM-DD |

## Problem Statement

What is wrong or missing?
Why does it matter?
Be specific — vague problems produce vague solutions.

## Proposed Solution

Concrete description of what you're proposing.
What changes. What doesn't change.
How it works at a high level.

## Design Details

Deeper dive into the implementation.
Diagrams welcome as ASCII or mermaid blocks.

## Alternatives Considered

### Alternative 1: Name

Description. Why this wasn't chosen.

### Alternative 2: Name

Description. Why this wasn't chosen.

## Open Questions

- [ ] Question that needs resolution before acceptance
- [ ] Another open question

## References

- Link to related issue, ADR, or prior art
```

---

## ADR Template

File: `docs/design/ADR_XXXX_SHORT_TITLE.md`

```markdown
# ADR-XXXX: Short Title

| Field | Value |
|-------|-------|
| Status | ACCEPTED |
| Date | YYYY-MM-DD |
| Deciders | Name, Name |
| Supersedes | — |
| Superseded by | — |

## Context

What situation required a decision?
What constraints applied?
What was the driving force?

## Decision

We chose **[option]** because [reason].

## Consequences

**Good:**
- Benefit 1
- Benefit 2

**Bad / Tradeoffs:**
- Cost or limitation 1

**Neutral:**
- Things that changed but aren't clearly good or bad

## References

- [RFC_XXXX](RFC_XXXX_....md) — the proposal that led here
```

ADRs are write-once.
To reverse a decision, write a new ADR.
Mark the old one `Superseded by ADR-XXXX`.

---

## Spec Template

File: `docs/design/SPEC_COMPONENT_NAME.md`

```markdown
# Component Name Specification

| Field | Value |
|-------|-------|
| Version | 0.1.0 |
| Status | DRAFT |
| Last Updated | YYYY-MM-DD |
| Owner | Name |

## Scope

This document covers: [what's in scope]

This document does NOT cover: [explicitly out of scope]

## Definitions

| Term | Definition |
|------|-----------|
| Term A | What it means in this context |

## Overview

High-level description. One paragraph.
If you can't summarize in a paragraph, the scope is too wide.

## Specification

### Section 1

...

### Section 2

...

## Interface

Concrete interface definitions, schema, or protocol description.

## Error Handling

How errors are represented and propagated.

## Open Questions

- [ ] Unresolved design question

## Changelog

| Date | Version | Change |
|------|---------|--------|
| YYYY-MM-DD | 0.1.0 | Initial draft |
```

---

## Research Note Template

File: `docs/research/RESEARCH_YYYY_MM_DD_TOPIC.md`

```markdown
# Research: Topic Description

| Field | Value |
|-------|-------|
| Date | YYYY-MM-DD |
| Author | Name |
| Status | ACTIVE |

## Motivation

Why was this research done?
What question was being answered?

## Findings

What was discovered?

## Data / Benchmarks

Include tables, numbers, or links to raw data if applicable.

## Conclusions

What do the findings imply?
What decision does this inform?

## Next Steps

What should happen based on this research?
Link to any RFC or ADR created as a result.

## References

- Source 1
- Source 2
```

---

## Backlog Item Template

File: `docs/backlog/BACKLOG_SHORT_SUMMARY.md`

```markdown
# Backlog: Short Summary

| Field | Value |
|-------|-------|
| Status | IDEA |
| Priority | — |
| Created | YYYY-MM-DD |

## Summary

One sentence. What is this item about?

## Motivation

Why should this be done?
What problem does it solve?

## Proposed Approach

High-level description of how this could be implemented.
This is not a spec — it's a starting point.

## Constraints

- Constraint or non-goal
- Compatibility or scope boundary

## Definition Of Done

- Observable outcome that must be true
- Required verification or artifact update

## Reporting Expectations

- What the implementing agent should report back
- Any follow-up risk, limitation, or deferred work to call out

## Open Questions

- [ ] Question that needs resolution before starting

## References

- Related backlog items, ADRs, or research notes
```

---

## Plan File Template

File: `docs/plans/PLAN_<AGENT>_<SUMMARY>.md`

```markdown
# Plan: Short Summary

| Field | Value |
|-------|-------|
| Agent | Claude / Codex / ... |
| Created | YYYY-MM-DD |
| Status | PENDING_APPROVAL |

---

## Section 1: The Plan

**Goal:** One sentence describing what this plan achieves.

**Steps:**
1. Step one
2. Step two
3. Step three

**Constraints:**
- Constraint or non-goal 1
- Constraint or non-goal 2

**Definition Of Done:**
- Observable outcome 1
- Observable outcome 2

**Reporting Expectations:**
- Report the key outcome
- Report verification performed
- Call out follow-up work or remaining risks

**Dependencies / Risks:**
- Risk or dependency 1
- Risk or dependency 2

---

## Section 2: Progress

_(This section is appended by the agent after execution.)_
_(Do not edit earlier entries — append only.)_
```
