# AGENTS.md

This file is the single source of truth for all agent behavior in this repo.
All agents (Claude, Codex, Gemini, GPT, etc.) must read this file before acting.
Rules here are enforced, not suggested.

---

## Documentation Rules

### Format

All documentation must be written in Markdown (`.md`).

If a user requests a specific document in a non-Markdown format:
- Record the exception in [Format Exceptions](#format-exceptions) below.
- Include: document name, format, reason, and who approved it.
- Apply the exception only to that specific document.

### File Naming

All `.md` filenames must use `ALL_CAPS_WITH_UNDERSCORES` format.

```
DESIGN.md
RESEARCH.md
MY_COMPONENT_SPEC.md
ADR_0001_CHOOSE_PROTOBUF.md
RFC_0002_NEW_IPC_LAYER.md
BACKLOG_ADD_GPU_SUPPORT.md
PLAN_CLAUDE_REFACTOR_PLANNER.md
```

No kebab-case. No camelCase. No spaces in filenames.

### Line Limits

| Constraint | Limit |
|-----------|-------|
| Lines per `.md` file | **400** |
| Total words per `.md` file | **8000** |

Both limits are independent — a file can trip either one.
Individual lines may be as long as needed.

If a file exceeds 400 lines or 8000 total words:
1. Identify logical sub-sections.
2. Extract each into a new `ALL_CAPS_SUBFILE.md`.
3. Replace the content in the main file with a reference link.
4. The main file becomes an index document.

### Cross-Referencing Model

Multiple `.md` files may reference the same `.md` file.
Referencing forms a **graph**, not a strict tree.
Wikipedia-style cross-linking is encouraged.
Every document must be reachable from at least one root-level overview file.

### Directory Organization

Group related docs into subdirectories:

| Directory | Contents |
|-----------|---------|
| `docs/design/` | Design artifacts: RFCs, ADRs, specs |
| `docs/research/` | Research notes, benchmarks, experiments |
| `docs/backlog/` | Individual backlog item files |
| `docs/plans/` | Agent execution plan files |

No source code in `docs/`. No binary files in `docs/`. Markdown only.

### Root-Level Overview Files

These files must always exist at the repo root:

**`DESIGN.md`** — Overview of all content in `docs/design/`.
Contains the status of each design artifact.

Possible statuses for design artifacts:
- `DRAFT` — being written, not yet reviewed
- `UNDER_REVIEW` — open for feedback
- `ACCEPTED` — approved, may or may not be implemented yet
- `IMPLEMENTED` — accepted and in production
- `ARCHIVED` — superseded or abandoned
- `REJECTED` — explicitly decided against

**`RESEARCH.md`** — Overview of all content in `docs/research/`.
Contains the status of each research item.

Possible statuses for research items:
- `ACTIVE` — ongoing research
- `EXPERIMENT` — live experiment, results pending
- `IDEA` — not yet formally pursued
- `COMPLETE` — findings documented, no further work needed
- `IMPLEMENTED` — findings were acted on
- `ARCHIVED` — no longer relevant

**`BACKLOG.md`** — Overview of all content in `docs/backlog/`.
Contains priorities and statuses for all backlog items.
Links to individual files in `docs/backlog/`.

---

## Design Sync Rule

**Agents must keep `DESIGN.md` in sync with the current implementation.**

When an implementation changes:
1. Update the relevant artifact in `docs/design/`.
2. Update `DESIGN.md` if the change affects the overview or status.
3. Never leave `DESIGN.md` describing a state that no longer exists.

A `DESIGN.md` that lags the implementation is a liability, not an asset.
It misleads other agents and future contributors.
Keeping it current is not optional.

---

## Backlog Management

### Structure

- `BACKLOG.md` at root: the index file with priorities and statuses.
- `docs/backlog/` directory: one file per item, named `BACKLOG_<SUMMARY>.md`.

`BACKLOG.md` references items in `docs/backlog/` by link.
It may also contain notes on relative priorities and groupings.

### Backlog Item Statuses

| Status | Meaning |
|--------|---------|
| `PLANNED` | Prioritized, will be worked on |
| `IDEA` | Not yet prioritized, under consideration |
| `IN_PROGRESS` | Currently being worked on |
| `DONE` | Completed |
| `ARCHIVED` | Decided against or no longer relevant |

### Lifecycle

- Items may be deleted when no longer relevant.
- Committing backlog files is encouraged — they are a record of thinking.
- Archived items should be kept briefly for traceability, then deleted.

---

## Planning Workflow

### When to Create a Plan

Create a plan file before any significant or multi-step task.
When operating in "plan mode", write the plan and **wait for user approval**
before taking any action.

### Plan File Format

- Location: `docs/plans/`
- Filename: `PLAN_<AGENT_NAME>_<PLAN_SUMMARY>.md`
- Example: `PLAN_CLAUDE_REFACTOR_TRAJECTORY_PLANNER.md`

### Plan File Structure

A plan file has exactly two sections:

**Section 1 — The Plan** (written before approval):
- Goal: one sentence describing what this plan achieves
- Steps: numbered list of concrete actions
- Dependencies or risks: anything that could block execution

**Section 2 — Progress** (appended after execution):
- Written by the same agent after task completion
- Format: bullet list tagged with `DONE`, `IN_PROGRESS`, or `TODO`
- Append-only — do not edit earlier progress entries

### Rules

- Agents must NOT modify Section 1 after the user approves it.
- Agents MUST append Section 2 after completing the task.
- Plan files may be deleted when no longer relevant.
- Committing plan files is encouraged — they are an agent activity log.

---

## Format Exceptions

Record any user-approved exceptions to the Markdown-only rule here.
All agents must honor these exceptions.

| Document | Format | Reason | Approved By | Date |
|----------|--------|--------|-------------|------|
| _(none)_ | — | — | — | — |

---

## Agent Roles

This section defines the role of each agent in this repository.
Update this section at repo creation, or at any time when roles change.
Agents must respect role boundaries.
An agent assigned "Researcher" should not push implementation code
without explicit user approval.

### Role Definitions

| Role | Responsibilities |
|------|----------------|
| **Engineer** | Implements features, writes code, manages PRs |
| **Debugger** | Investigates failures, fixes bugs, writes regression tests |
| **Researcher** | Reviews literature, benchmarks alternatives, writes research notes |
| **Designer** | Authors RFCs, ADRs, specs; makes architectural decisions |
| **Reviewer** | Reviews code and design docs before merge |
| **Planner** | Breaks down tasks into plans, identifies dependencies and risks |

### Assigned Roles

Update the table below to reflect your project's agent configuration.

| Agent | Role(s) | Notes |
|-------|---------|-------|
| Claude | Engineer, Debugger | Default implementer and debugger |
| Codex | Researcher, Reviewer, Designer | Default for design review and research |
| _(add more)_ | — | — |

Role assignments are not permanent.
The user may reassign roles at any time by updating this table.
When in doubt about whether an action is in-role, ask the user.
