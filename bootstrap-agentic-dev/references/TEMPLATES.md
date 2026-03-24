# TEMPLATES.md

Root-level file templates for the repo-bootstrap system.
See [TEMPLATES_ARTIFACTS.md](TEMPLATES_ARTIFACTS.md) for design artifact,
research, backlog, and plan file templates.

All filenames follow `ALL_CAPS_WITH_UNDERSCORES` convention.
All templates respect the documented 400-line and 8000-word limits.

---

## README Template

File: `README.md`

```markdown
# Project Name

One sentence. What this is and why it exists.

## Quick Start

\`\`\`bash
# How to build
make build

# How to run
make run
\`\`\`

## Requirements

- Dependency A >= version X
- Dependency B

## Documentation

- [Design overview](DESIGN.md)
- [Research overview](RESEARCH.md)
- [Backlog](BACKLOG.md)
- [Agent rules](AGENTS.md)

<!-- Include this section only if CONTRIBUTING.md exists -->
## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).
```

---

## CLAUDE.md Template

File: `CLAUDE.md`

```markdown
# CLAUDE.md

See [AGENTS.md](AGENTS.md) for all agent rules, roles,
and documentation conventions.
```

That's it. Nothing else goes in this file.

---

## DESIGN.md Template

File: `DESIGN.md`

```markdown
# DESIGN.md

Overview of all design artifacts in `docs/design/`.
Agents must keep this file in sync with the current implementation.

## Active Design Artifacts

| File | Title | Status | Last Updated |
|------|-------|--------|--------------|
| [RFC_0001_...](docs/design/RFC_0001_....md) | ... | UNDER_REVIEW | YYYY-MM-DD |
| [ADR_0001_...](docs/design/ADR_0001_....md) | ... | IMPLEMENTED | YYYY-MM-DD |

## Status Reference

- DRAFT — being written, not yet reviewed
- UNDER_REVIEW — open for feedback
- ACCEPTED — approved, not yet implemented
- IMPLEMENTED — accepted and in production
- ARCHIVED — superseded or abandoned
- REJECTED — explicitly decided against

## Archived Artifacts

| File | Title | Reason |
|------|-------|--------|
| _(none)_ | — | — |
```

---

## RESEARCH.md Template

File: `RESEARCH.md`

```markdown
# RESEARCH.md

Overview of all research in `docs/research/`.

## Active Research

| File | Topic | Status | Last Updated |
|------|-------|--------|--------------|
| [RESEARCH_...](docs/research/RESEARCH_....md) | ... | ACTIVE | YYYY-MM-DD |

## Status Reference

- ACTIVE — ongoing research
- EXPERIMENT — live experiment, results pending
- IDEA — not yet formally pursued
- COMPLETE — findings documented
- IMPLEMENTED — findings were acted on
- ARCHIVED — no longer relevant
```

---

## BACKLOG.md Template

File: `BACKLOG.md`

```markdown
# BACKLOG.md

Overview of all backlog items in `docs/backlog/`.

## Priority Order

1. [BACKLOG_...](docs/backlog/BACKLOG_....md) — `IN_PROGRESS`
2. [BACKLOG_...](docs/backlog/BACKLOG_....md) — `PLANNED`
3. [BACKLOG_...](docs/backlog/BACKLOG_....md) — `IDEA`

## Status Reference

- PLANNED — prioritized, will be worked on
- IDEA — not yet prioritized
- IN_PROGRESS — currently being worked on
- DONE — completed
- ARCHIVED — decided against or no longer relevant

## Archived Items

| File | Summary | Reason |
|------|---------|--------|
| _(none)_ | — | — |
```

---

## PLANS.md Template

File: `PLANS.md`

```markdown
# PLANS.md

Overview of all plan files in `docs/plans/`.

## Active Plans

| File | Goal | Status | Last Updated |
|------|------|--------|--------------|
| [PLAN_...](docs/plans/PLAN_....md) | ... | PENDING_APPROVAL | YYYY-MM-DD |

## Completed Plans

| File | Goal | Final Status | Last Updated |
|------|------|--------------|--------------|
| _(none)_ | — | — | — |
```

---

## CHANGELOG.md Template

File: `CHANGELOG.md`

```markdown
# CHANGELOG.md

All notable changes to this project are documented here.

## Unreleased

### Added

- _(none yet)_

### Changed

- _(none yet)_

### Fixed

- _(none yet)_
```

---

## LICENSE Guidance

File: `LICENSE`

Use a standard license text selected for the project:
- MIT for simple permissive open source projects
- Apache-2.0 when an explicit patent grant is desired
- Proprietary/internal repos may omit `LICENSE`

Do not invent custom license wording unless the user explicitly asks for it.
