---
name: bootstrap-agentic-dev
description: Use this skill whenever a user wants to set up, structure, or reorganize a programming or engineering project repository. Trigger for: bootstrapping a new project from scratch, figuring out where to put files, organizing documentation, asking where research notes or technical decisions belong, setting up agent workflow files (AGENTS.md, CLAUDE.md, plans), creating backlog structure, or questions about documentation conventions and constraints. Also trigger for: "how should I structure this", "what files do I need in my repo", "where does X go", "set up a new project for me", "help me organize my codebase", "scaffold this project". Use even when the user doesn't say "repo" explicitly — if they're starting or restructuring an engineering project and structure is relevant, use this skill.
---

# Repo Bootstrap & Project Structure Skill

Opinionated, enforced conventions — not suggestions.
This skill gives Claude a concrete framework for bootstrapping
and structuring programming and engineering repos.

**Core philosophy:**
A repo's structure is a contract with your future self and your teammates.
These conventions exist because the alternatives have all been tried and they hurt.
Follow them by default.
If the user pushes back, explain the tradeoff clearly, then fold if they persist.

---

## Step 1: Understand the Project First

Ask (or infer from context) before producing a structure:
- **Language/stack** — determines tooling config files and `src/` internals
- **Project type** — library, application, embedded, research, service, monorepo
- **Team / agent setup** — which agents will work on this? (for Agent Roles section)
- **Maturity stage** — greenfield prototype vs. long-lived production system

Don't generate a monorepo scaffold for someone building a weekend script.
Match the structure to the reality.

---

## Step 2: Root-Level Files

### Always Required

Every repo, no exceptions:

| File | Purpose | Constraint |
|------|---------|------------|
| `README.md` | Human entry point | Max 150 lines. Billboard, not a manual. |
| `AGENTS.md` | Agent rules and roles | Generated from template. See Step 4. |
| `CLAUDE.md` | Claude-specific entry point | References AGENTS.md only. No duplicated rules. |
| `DESIGN.md` | Overview of `design/` dir | Kept in sync with current implementation. |
| `RESEARCH.md` | Overview of `research/` dir | Summary of status of all research items. |
| `BACKLOG.md` | Overview of `backlog/` dir | Priorities and statuses. Links to `backlog/`. |
| `.gitignore` | Exclude build artifacts and secrets | Never ignore source files. Never commit secrets. |
| `LICENSE` | Legal clarity | Omit only for internal proprietary repos. |
| `CHANGELOG.md` | Notable changes over time | Even solo projects need this. |

### Conditionally Required

| File | When to add |
|------|------------|
| `.env.example` | Any time the project uses env vars. `.env` is never committed. |
| `Makefile` or `justfile` | 2+ common commands that users need to run |
| `docker-compose.yml` | Local dev needs multi-service orchestration |
| `CONTRIBUTING.md` | More than one human will ever touch this |
| `CODEOWNERS` | Repo has clear ownership zones by directory |
| `SECURITY.md` | Public-facing project with vulnerability disclosure |

---

## Step 3: Directory Structure

### Universal Layout

```
project-root/
├── README.md
├── AGENTS.md             # Agent rules, roles, doc conventions
├── CLAUDE.md             # References AGENTS.md only
├── DESIGN.md             # Overview of docs/design/ dir
├── RESEARCH.md           # Overview of docs/research/ dir
├── BACKLOG.md            # Overview of docs/backlog/ dir
├── CHANGELOG.md
├── LICENSE
├── .gitignore
├── .env.example
│
├── src/                  # All production source code
├── tests/                # Tests (colocated or centralized — pick one)
│
├── docs/                 # Human-readable documentation
│   ├── design/           # RFCs, ADRs, specs, design artifacts
│   ├── research/         # Research notes, benchmarks, experiments
│   ├── backlog/          # Individual backlog item files
│   └── plans/            # Agent execution plan files
│
├── scripts/              # Build helpers, dev utilities, automation
└── config/               # Non-secret configuration files
```

### Directory-Specific Rules

**`src/`** — All and only production source code.
Internal structure follows language conventions.
Don't scatter source files at the repo root.

**`tests/`** — Two valid strategies, pick ONE and commit to it:
1. **Colocated** — preferred for Rust, Go, C++, smaller projects
2. **Centralized** (`tests/`) — preferred for Python, larger projects

Never mix both in the same repo.

**`docs/design/`** — Design artifacts only.
RFCs, ADRs, specs. No source code. No binaries. Markdown only.

**`docs/research/`** — Exploratory work.
Literature reviews, benchmarks, feasibility studies, experiment logs.

**`docs/backlog/`** — Individual backlog item files.
Named `BACKLOG_<SUMMARY>.md`.

**`docs/plans/`** — Agent execution plans.
Named `PLAN_<AGENT_NAME>_<PLAN_SUMMARY>.md`.

**`scripts/`** — Automation that isn't the product.
If a script grows beyond ~200 lines, reconsider whether it belongs in `src/`.

**`config/`** — Non-secret configuration.
Schema definitions, default configs, environment-specific configs.

### Stack-Specific Additions

Layer these on top of the universal layout:

**Python:**
```
pyproject.toml        # single source of truth for deps + tooling
requirements.txt      # only if pyproject.toml isn't sufficient
```

**Rust:**
```
Cargo.toml
Cargo.lock            # commit for binaries; gitignore for libraries
```

**Node.js / TypeScript:**
```
package.json
tsconfig.json
.nvmrc                # pin the Node version
```

**C / C++:**
```
CMakeLists.txt or BUILD.bazel — pick one, don't switch
include/              # public headers only
```

**ROS 2 / Robotics:**
```
package.xml
CMakeLists.txt or setup.py
launch/               # launch files
config/               # parameter YAML files
```

**Embedded / Firmware:**
```
CMakeLists.txt or platformio.ini
linker/               # linker scripts
hal/                  # hardware abstraction layer
```

---

## Step 4: Documentation Rules (Enforced)

These are hard constraints, not recommendations.
Generate all docs following these rules.
If the user deviates, note the exception in `AGENTS.md`.

### Format Rule

All documentation must be written in Markdown (`.md`).

Exception process:
- User requests a specific document in a non-Markdown format.
- Record the exception in the `## Format Exceptions` section of `AGENTS.md`.
- Include: document name, format, reason, and who approved it.
- Proceed with the requested format for that document only.

### Naming Convention

All `.md` filenames use `ALL_CAPS_WITH_UNDERSCORES`:

```
DESIGN.md
RESEARCH.md
BACKLOG.md
AGENTS.md
CLAUDE.md
MY_COMPONENT_SPEC.md
BACKLOG_ADD_GPU_SUPPORT.md
PLAN_CLAUDE_REFACTOR_PLANNER.md
ADR_0001_CHOOSE_PROTOBUF.md
RFC_0002_NEW_IPC_LAYER.md
```

No kebab-case, no camelCase, no spaces in filenames.
`README.md` and `CHANGELOG.md` follow this convention naturally.

### Line Limits

| Constraint | Limit | Consequence of violation |
|-----------|-------|--------------------------|
| Lines per file | 400 | Split into sub-files, reference from main |
| Total words per file | 8000 | Split into sub-files, reference from main |

Both limits are independent — a file can trip either one.
Individual lines may be as long as needed.

When a file exceeds 400 lines or 8000 total words:
1. Identify logical sub-sections.
2. Extract each into a new `ALL_CAPS_SUBFILE.md`.
3. Replace the content in the main file with a reference link.
4. The main file becomes an index/overview document.

### Cross-Referencing Model

Multiple `.md` files may reference the same `.md` file.
Referencing forms a **graph**, not a strict tree.
Wikipedia-style linking is encouraged and expected.

Example: `ADR_0003_USE_ZENOH.md` may be referenced by:
- `DESIGN.md`
- `RESEARCH.md` (if there's related research)
- `RFC_0001_REDESIGN_IPC.md` (as prior context)
- `BACKLOG_MIGRATE_TO_ZENOH.md`

Every document must be reachable from at least one root-level file.

### Root-Level Overview Files

**`DESIGN.md`** — Overview of all content in `docs/design/`.
Must reflect current implementation state.
Contains: status of each design artifact (Draft, Accepted, Implemented, Archived).
Agents must update this whenever implementation changes.

**`RESEARCH.md`** — Overview of all content in `docs/research/`.
Contains: status of each item (Active, Experiment, Idea, Archived, Implemented).

**`BACKLOG.md`** — Overview of all content in `docs/backlog/`.
Contains: priorities and statuses for all backlog items.
Links to individual files in `docs/backlog/`.

---

## Step 5: Agent Workflow Files

### AGENTS.md

The single source of truth for all agent behavior in this repo.
Generated at repo creation using the bundled template.
See `references/AGENTS_TEMPLATE.md` for the full ready-to-copy file.

Sections in AGENTS.md:
- Documentation Rules (the full rule set from Step 4)
- Design Sync Rule
- Backlog Management
- Planning Workflow
- Format Exceptions
- Agent Roles

### CLAUDE.md

Two lines. That's it. Here is the full content:

```markdown
# CLAUDE.md

See [AGENTS.md](AGENTS.md) for all agent rules, roles, and documentation conventions.
```

No duplicated rules. No additional instructions.
If Claude-specific rules are ever needed, add a `## Claude-Specific` section to `AGENTS.md`.

### Backlog Files

`BACKLOG.md` at root — the index:
- Lists all backlog items with status and priority.
- Links to individual files in `docs/backlog/`.

`docs/backlog/BACKLOG_<SUMMARY>.md` — individual items:
- One item per file.
- Summary of the idea, motivation, approach, and open questions.
- Status: `PLANNED`, `IDEA`, `IN_PROGRESS`, `DONE`, `ARCHIVED`.

Backlog files may be deleted when no longer relevant.
Committing them is encouraged — they are a record of thinking.

### Plan Files

Location: `docs/plans/PLAN_<AGENT_NAME>_<PLAN_SUMMARY>.md`

When to create:
- Before starting any significant or multi-step task.
- When in "plan mode" awaiting user approval.

File structure — two sections:

**Top section (written before approval, never modified after):**
- Goal
- Numbered steps
- Dependencies or risks

**Bottom section (appended after execution):**
- Status report: bullet list of `DONE`, `IN_PROGRESS`, `TODO`.
- Written after task completion by the same agent.
- Append-only — do not modify earlier entries.

Plan files may be deleted when no longer relevant.
Committing them is encouraged — they are an agent activity log.

---

## Step 6: CI/CD and Tooling Config

Place CI config where the platform expects it:
- GitHub Actions: `.github/workflows/`
- GitLab CI: `.gitlab-ci.yml` at root
- Jenkins: `Jenkinsfile` at root

Consolidate tooling config:
- Python: everything into `pyproject.toml`
- Node.js: everything into `package.json` where possible
- Rust: everything into `Cargo.toml`

If a CI file exceeds 200 lines, factor into reusable workflow files.

---

## Output Format

When bootstrapping a repo for a user:

1. **Ask** about stack, project type, and agents in use (if not clear from context)
2. **Generate** the directory tree as a fenced code block
3. **Generate** the content of key files:
   - `CLAUDE.md` (two lines, always)
   - `AGENTS.md` (from `references/AGENTS_TEMPLATE.md`, fill in Agent Roles)
   - `DESIGN.md` and `RESEARCH.md` stubs
   - `BACKLOG.md` stub
   - `.gitignore` and stack-specific config files
4. **Note** which optional files apply and why
5. **Offer** to generate specific design artifact templates on request

Lead with structure. Offer to go deeper on any section.
Don't dump everything at once if the project is simple.

---

## Reference Files

- `references/AGENTS_TEMPLATE.md` — Ready-to-copy AGENTS.md for any project.
  Load this when generating the AGENTS.md for a new repo.

- `references/TEMPLATES.md` — Templates for RFC, ADR, spec, research note,
  backlog item, and plan files. Load when the user asks for a template
  or when generating design artifacts.
