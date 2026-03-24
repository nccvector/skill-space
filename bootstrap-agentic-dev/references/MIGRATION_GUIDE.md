# MIGRATION_GUIDE.md

How to adopt the bootstrap-agentic-dev conventions in an existing repo
without breaking everything.

---

## Principles

1. Treat existing files as authoritative inputs, not obstacles.
2. Prefer additive changes first — merge, don't replace.
3. Only rename or split files when there is a clear benefit.
4. Record temporary deviations in `AGENTS.md` during migration.
5. Never overwrite existing canonical docs without reading them.

---

## Step 1: Inventory the Current Repo

Before touching anything, understand what exists:

- Root-level docs: do `AGENTS.md`, `DESIGN.md`, `RESEARCH.md`,
  `BACKLOG.md` already exist? Under what names?
- Doc directories: is there an existing `docs/`, `doc/`, `design/`,
  `architecture/`, `notes/`, or similar?
- Naming conventions: are filenames kebab-case, camelCase, lowercase,
  or already ALL_CAPS?
- Agent files: does `CLAUDE.md` or `.cursorrules` or similar exist?
- Plans: does the team even want persistent plan files?

Map the existing structure before proposing the target.

---

## Step 2: Choose the Target Profile

| Profile | When to use |
|---------|------------|
| `minimal` | The repo is small, has few docs, and doesn't need design/research/backlog indexes |
| `standard` | The repo has or will have design docs, research notes, and a backlog |
| `agentic` | Multiple agents will work on this repo and plan files are actively used |

The profile determines which files are required. Don't force `standard`
on a repo that only needs `minimal`.

---

## Step 3: Add the Root Contract First

Create the new governance files without moving anything else yet:

1. **`AGENTS.md`** — If it already exists, merge the skill's rules into
   it. If the existing version has useful project-specific rules, keep
   them and add the missing sections (Documentation Rules, Design Sync,
   Backlog Management, etc.). If it doesn't exist, generate from template.

2. **`CLAUDE.md`** — If it exists and contains real rules, move those
   rules into `AGENTS.md` under a `## Claude-Specific` section, then
   replace `CLAUDE.md` with the two-line pointer. If it doesn't exist,
   create the two-line version.

3. **Root index files** — For `standard` and `agentic` profiles only,
   create `DESIGN.md`, `RESEARCH.md`, `BACKLOG.md` as indexes that point
   to both old and new locations. These files serve as bridges during the
   transition. For `minimal` profiles, skip this step entirely — those
   files are not required and should not be created.

4. **`bootstrap.env`** — Create it with the chosen profile so
   `check_docs.sh` knows what to enforce.

5. **Migration Exceptions** — Add a `## Migration Exceptions` section
   to `AGENTS.md` to track temporary deviations from naming or structure
   conventions. This is separate from the `Format Exceptions` section
   (which is only for non-Markdown format approvals). Example:

```
## Migration Exceptions

| File | Issue | Plan | Target Date |
|------|-------|------|-------------|
| old-design-doc.md | Legacy filename | Rename in PR #42 | 2025-04-01 |
| notes/ | Legacy directory | Move to docs/research/ | 2025-04-15 |
```

   Remove entries as migration completes.

---

## Step 4: Map Existing Docs to New Structure

Skip this step for `minimal` profiles — minimal repos don't use `docs/`.

For `standard` and `agentic` profiles, don't move files blindly. Map them:

| Existing content | Target location | Action |
|-----------------|----------------|--------|
| Architecture docs, design proposals | `docs/design/` | Move or symlink, rename gradually |
| Research notes, benchmarks, experiments | `docs/research/` | Move or symlink |
| Task lists, issue trackers in markdown | `docs/backlog/` | Convert format, one at a time |
| Meeting notes, decision logs | `docs/design/` as ADRs | Convert the ones that record decisions |
| Existing README | Keep at root | Trim to 150 lines if needed |
| Existing CHANGELOG | Keep at root | Adopt the `## Unreleased` format |

Key rule: **index first, move later.** Get the root overview files
pointing to existing docs before you start renaming.

---

## Step 5: Migrate Filenames Gradually

The skill requires `ALL_CAPS_WITH_UNDERSCORES.md` for doc files.
Don't rename everything in one commit if the repo has history you
care about.

Recommended sequence:
1. Add the new-convention filename as a copy or rename.
2. Update the root index file to point to the new name.
3. Update cross-references in other docs.
4. Remove the old file (or let it die naturally).

If a file is heavily linked externally, keep a redirect note at the
old path temporarily.

---

## Step 6: Handle Pre-existing AGENTS.md / DESIGN.md / etc.

**If `AGENTS.md` already exists:**
- Read it fully before changing anything.
- Identify which sections overlap with the template.
- Merge missing sections from the template into the existing file.
- Keep project-specific rules the existing file already has.
- Don't delete custom agent roles or project-specific conventions.

**If `DESIGN.md` already exists:**
- If it already serves as an architecture overview, keep it.
- Add the Status Reference section and table format if missing.
- Backfill status values for existing design artifacts.
- Don't regenerate it from template — adapt in place.

**If `RESEARCH.md` or `BACKLOG.md` already exist:**
- Same approach: read, merge, adapt. Don't replace.

**General rule:** If a file already does the job the skill expects,
normalize its format incrementally. Don't destroy and rebuild.

---

## Step 7: Run the Linter and Fix Violations

```bash
./scripts/check_docs.sh
```

Fix violations in priority order:
1. Missing required files (create stubs)
2. Naming violations (rename one at a time)
3. Line/word limit violations (split files)
4. Missing index references (add to overview files)

Use `--ci` mode only after the migration is substantially complete.
During migration, the non-CI mode gives warnings without blocking.

---

## Step 8: Generators and Rebuilders Come Last

Only after the structure has settled:

```bash
./scripts/update_indexes.sh          # rebuild indexes from actual files
./scripts/bootstrap_doc.sh rfc ...   # generate new artifacts going forward
```

Don't use `update_indexes.sh` to overwrite a carefully hand-migrated
`DESIGN.md`. Use it once the index files are in their final form and
you want the script to maintain them going forward.

---

## Recommended Commit Sequence

1. `Add AGENTS.md and CLAUDE.md` — governance files, no moves
2. `Add root index files (DESIGN.md, RESEARCH.md, BACKLOG.md)` — point to existing docs
3. `Add bootstrap.env and scripts` — tooling, no doc changes
4. `Migrate docs/design/` — move and rename design artifacts
5. `Migrate docs/research/` — move and rename research notes
6. `Migrate docs/backlog/` — convert task tracking files
7. `Normalize remaining filenames` — rename stragglers
8. `Run check_docs and fix remaining violations` — clean up

Each commit should be self-contained and reviewable. Don't combine
structural changes with content changes.

---

## Temporary Exception Policy

During migration, some files will violate conventions. That's expected.

Use the `## Migration Exceptions` section in `AGENTS.md` (added in
Step 3) to track these. This is distinct from `Format Exceptions`,
which only covers approved non-Markdown formats.

A migration is done when the Migration Exceptions table is empty.
