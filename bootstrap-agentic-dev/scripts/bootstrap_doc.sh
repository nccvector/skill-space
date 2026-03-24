#!/usr/bin/env bash
# bootstrap_doc.sh — Create a doc from template and update the parent index.
# Usage: ./scripts/bootstrap_doc.sh <type> <title> [--agent <name>] [--author <name>]
#   type:   rfc, adr, spec, research, backlog, plan
#   title:  human-readable title (auto-normalized to ALL_CAPS_WITH_UNDERSCORES)
#   --agent: agent name (required for plan type)
#   --author: author name (default: git user.name)

set -euo pipefail

# Source shared library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB="$SCRIPT_DIR/lib.sh"
source "$LIB"

# Check if reference templates are available (skill directory vs copied repo)
REFS_DIR="$SCRIPT_DIR/../references"
ARTIFACTS_FILE="$REFS_DIR/TEMPLATES_ARTIFACTS.md"
HAS_REFS=false
[[ -f "$ARTIFACTS_FILE" ]] && HAS_REFS=true

# --- Parse arguments ---
if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <type> <title> [--agent <name>] [--author <name>]"
  echo "  type:  rfc, adr, spec, research, backlog, plan"
  echo "  title: human-readable (e.g. \"new ipc layer\")"
  exit 1
fi

DOC_TYPE="$1"
shift
TITLE=""
AGENT=""
AUTHOR=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --agent)  AGENT="$2"; shift 2 ;;
    --author) AUTHOR="$2"; shift 2 ;;
    *)
      if [[ -n "$TITLE" ]]; then
        TITLE="$TITLE $1"
      else
        TITLE="$1"
      fi
      shift
      ;;
  esac
done

if [[ -z "$TITLE" ]]; then
  echo "Error: title is required."
  exit 1
fi

if [[ "$DOC_TYPE" == "plan" ]] && [[ -z "$AGENT" ]]; then
  # Try reading default agent from bootstrap.env
  AGENT="$(read_bootstrap_env AGENTS "" | cut -d, -f1)"
  if [[ -z "$AGENT" ]]; then
    echo "Error: --agent is required for plan type."
    exit 1
  fi
fi

if [[ -z "$AUTHOR" ]]; then
  AUTHOR="$(git config user.name 2>/dev/null || echo "Unknown")"
fi

# --- Find repo root ---
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$REPO_ROOT"

TODAY="$(date +%Y-%m-%d)"
TODAY_UNDER="$(date +%Y_%m_%d)"

NORM_TITLE="$(normalize_title "$TITLE")"

# --- Determine file path and index file ---
case "$DOC_TYPE" in
  rfc)
    DIR="docs/design"
    NUM="$(next_number RFC "$DIR")"
    FILENAME="RFC_${NUM}_${NORM_TITLE}.md"
    INDEX_FILE="DESIGN.md"
    DEFAULT_STATUS="DRAFT"
    TEMPLATE_SECTION="RFC Template"
    ;;
  adr)
    DIR="docs/design"
    NUM="$(next_number ADR "$DIR")"
    FILENAME="ADR_${NUM}_${NORM_TITLE}.md"
    INDEX_FILE="DESIGN.md"
    DEFAULT_STATUS="ACCEPTED"
    TEMPLATE_SECTION="ADR Template"
    ;;
  spec)
    DIR="docs/design"
    FILENAME="SPEC_${NORM_TITLE}.md"
    INDEX_FILE="DESIGN.md"
    DEFAULT_STATUS="DRAFT"
    TEMPLATE_SECTION="Spec Template"
    ;;
  research)
    DIR="docs/research"
    FILENAME="RESEARCH_${TODAY_UNDER}_${NORM_TITLE}.md"
    INDEX_FILE="RESEARCH.md"
    DEFAULT_STATUS="ACTIVE"
    TEMPLATE_SECTION="Research Note Template"
    ;;
  backlog)
    DIR="docs/backlog"
    FILENAME="BACKLOG_${NORM_TITLE}.md"
    INDEX_FILE="BACKLOG.md"
    DEFAULT_STATUS="IDEA"
    TEMPLATE_SECTION="Backlog Item Template"
    ;;
  plan)
    DIR="docs/plans"
    NORM_AGENT="$(normalize_title "$AGENT")"
    FILENAME="PLAN_${NORM_AGENT}_${NORM_TITLE}.md"
    INDEX_FILE="PLANS.md"
    DEFAULT_STATUS="PENDING_APPROVAL"
    TEMPLATE_SECTION="Plan File Template"
    ;;
  *)
    echo "Error: unknown type '$DOC_TYPE'. Must be: rfc, adr, spec, research, backlog, plan"
    exit 1
    ;;
esac

FILEPATH="$DIR/$FILENAME"

if [[ -f "$FILEPATH" ]]; then
  echo "Error: $FILEPATH already exists."
  exit 1
fi

mkdir -p "$DIR"

# ============================================================
# Template rendering
# ============================================================

# Apply placeholder substitutions to a template string.
# Replaces: XXXX (number), Short Title, YYYY-MM-DD, Name, etc.
render_template() {
  local tmpl="$1"
  echo "$tmpl" | sed \
    -e "s/XXXX/${NUM:-0000}/g" \
    -e "s/Short Title/${TITLE}/g" \
    -e "s/Short Summary/${TITLE}/g" \
    -e "s/Topic Description/${TITLE}/g" \
    -e "s/Component Name/${TITLE}/g" \
    -e "s/YYYY-MM-DD/${TODAY}/g" \
    -e "s/YYYY_MM_DD/${TODAY_UNDER}/g" \
    -e "s/| Status | DRAFT |/| Status | ${DEFAULT_STATUS} |/" \
    -e "s/| Status | ACCEPTED |/| Status | ${DEFAULT_STATUS} |/" \
    -e "s/| Status | IDEA |/| Status | ${DEFAULT_STATUS} |/" \
    -e "s/| Status | ACTIVE |/| Status | ${DEFAULT_STATUS} |/" \
    -e "s/| Status | PENDING_APPROVAL |/| Status | ${DEFAULT_STATUS} |/" \
    -e "s/| Author | Name |/| Author | ${AUTHOR} |/" \
    -e "s/| Owner | Name |/| Owner | ${AUTHOR} |/" \
    -e "s/| Deciders | Name, Name |/| Deciders | ${AUTHOR} |/" \
    -e "s/| Agent | Claude \/ Codex \/ \.\.\. |/| Agent | ${AGENT:-—} |/"
}

if $HAS_REFS; then
  # Extract from canonical reference files
  RAW_TEMPLATE="$(extract_template "$ARTIFACTS_FILE" "$TEMPLATE_SECTION")"
  if [[ -z "$RAW_TEMPLATE" ]]; then
    echo "Error: could not extract '$TEMPLATE_SECTION' from $ARTIFACTS_FILE"
    exit 1
  fi
  render_template "$RAW_TEMPLATE" > "$FILEPATH"
else
  # Fallback: baked templates (this block is replaced at copy time by bootstrap_repo.sh)
  # __BAKED_TEMPLATES_START__
  case "$DOC_TYPE" in
    rfc)
      cat > "$FILEPATH" << TEMPLATE
# RFC-${NUM}: ${TITLE}

| Field | Value |
|-------|-------|
| Status | ${DEFAULT_STATUS} |
| Author | ${AUTHOR} |
| Created | ${TODAY} |
| Updated | ${TODAY} |

## Problem Statement

What is wrong or missing?
Why does it matter?

## Proposed Solution

Concrete description of what you're proposing.

## Design Details

Deeper dive into the implementation.

## Alternatives Considered

### Alternative 1: Name

Description. Why this wasn't chosen.

## Open Questions

- [ ] Question that needs resolution before acceptance

## References

- Link to related issue, ADR, or prior art
TEMPLATE
      ;;

    adr)
      cat > "$FILEPATH" << TEMPLATE
# ADR-${NUM}: ${TITLE}

| Field | Value |
|-------|-------|
| Status | ${DEFAULT_STATUS} |
| Date | ${TODAY} |
| Deciders | ${AUTHOR} |
| Supersedes | — |
| Superseded by | — |

## Context

What situation required a decision?

## Decision

We chose **[option]** because [reason].

## Consequences

**Good:**
- Benefit 1

**Bad / Tradeoffs:**
- Cost or limitation 1

**Neutral:**
- Things that changed but aren't clearly good or bad

## References

- Link to related RFC or prior art
TEMPLATE
      ;;

    spec)
      cat > "$FILEPATH" << TEMPLATE
# ${TITLE} Specification

| Field | Value |
|-------|-------|
| Version | 0.1.0 |
| Status | ${DEFAULT_STATUS} |
| Last Updated | ${TODAY} |
| Owner | ${AUTHOR} |

## Scope

This document covers: [what's in scope]

This document does NOT cover: [explicitly out of scope]

## Definitions

| Term | Definition |
|------|-----------|
| Term A | What it means in this context |

## Overview

High-level description. One paragraph.

## Specification

### Section 1

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
| ${TODAY} | 0.1.0 | Initial draft |
TEMPLATE
      ;;

    research)
      cat > "$FILEPATH" << TEMPLATE
# Research: ${TITLE}

| Field | Value |
|-------|-------|
| Date | ${TODAY} |
| Author | ${AUTHOR} |
| Status | ${DEFAULT_STATUS} |

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

## References

- Source 1
TEMPLATE
      ;;

    backlog)
      cat > "$FILEPATH" << TEMPLATE
# Backlog: ${TITLE}

| Field | Value |
|-------|-------|
| Status | ${DEFAULT_STATUS} |
| Priority | — |
| Created | ${TODAY} |

## Summary

One sentence. What is this item about?

## Motivation

Why should this be done?
What problem does it solve?

## Proposed Approach

High-level description of how this could be implemented.

## Constraints

- Constraint or non-goal

## Definition Of Done

- Observable outcome that must be true

## Reporting Expectations

- What the implementing agent should report back

## Open Questions

- [ ] Question that needs resolution before starting

## References

- Related backlog items, ADRs, or research notes
TEMPLATE
      ;;

    plan)
      cat > "$FILEPATH" << TEMPLATE
# Plan: ${TITLE}

| Field | Value |
|-------|-------|
| Agent | ${AGENT} |
| Created | ${TODAY} |
| Status | ${DEFAULT_STATUS} |

---

## Section 1: The Plan

**Goal:** One sentence describing what this plan achieves.

**Steps:**
1. Step one
2. Step two
3. Step three

**Constraints:**
- Constraint or non-goal 1

**Definition Of Done:**
- Observable outcome 1

**Reporting Expectations:**
- Report the key outcome
- Call out follow-up work or remaining risks

**Dependencies / Risks:**
- Risk or dependency 1

---

## Section 2: Progress

_(This section is appended by the agent after execution.)_
_(Do not edit earlier entries — append only.)_
TEMPLATE
      ;;
  esac
  # __BAKED_TEMPLATES_END__
fi

echo "Created: $FILEPATH"

# ============================================================
# Index update
# ============================================================

insert_table_row() {
  local index="$1"
  local row="$2"

  if [[ ! -f "$index" ]]; then
    echo "Skipped: $index does not exist (use --plans to enable plan indexing)"
    INDEX_UPDATED=false
    return
  fi

  awk -v row="$row" '
    BEGIN { found_header=0; in_first_table=0; replaced=0; last_table_line=0 }
    /^\| File/ && !found_header {
      found_header=1
      in_first_table=1
    }
    in_first_table && /^\|/ { last_table_line=NR }
    in_first_table && !/^\|/ && last_table_line > 0 { in_first_table=0 }
    { lines[NR] = $0 }
    END {
      for (i = 1; i <= NR; i++) {
        if (i <= last_table_line && lines[i] ~ /\(none\)_/ && !replaced) {
          print row
          replaced=1
        } else {
          print lines[i]
          if (i == last_table_line && !replaced) print row
        }
      }
    }
  ' "$index" > "${index}.tmp" && mv "${index}.tmp" "$index"
}

insert_backlog_entry() {
  local index="$1"
  local entry="$2"

  if [[ ! -f "$index" ]]; then
    echo "Skipped: $index does not exist"
    INDEX_UPDATED=false
    return
  fi

  if grep -q '_(no items yet)_' "$index"; then
    awk -v entry="$entry" '
      /\(no items yet\)/ { print entry; next }
      { print }
    ' "$index" > "${index}.tmp" && mv "${index}.tmp" "$index"
    return
  fi

  awk -v entry="$entry" '
    /^[0-9]+\./ { last_num = NR }
    { lines[NR] = $0 }
    END {
      for (i = 1; i <= NR; i++) {
        print lines[i]
        if (i == last_num) print entry
      }
    }
  ' "$index" > "${index}.tmp" && mv "${index}.tmp" "$index"
}

INDEX_UPDATED=true

case "$DOC_TYPE" in
  rfc|adr|spec)
    ROW="| [${FILENAME}](docs/design/${FILENAME}) | ${TITLE} | ${DEFAULT_STATUS} | ${TODAY} |"
    insert_table_row "$INDEX_FILE" "$ROW"
    ;;
  research)
    ROW="| [${FILENAME}](docs/research/${FILENAME}) | ${TITLE} | ${DEFAULT_STATUS} | ${TODAY} |"
    insert_table_row "$INDEX_FILE" "$ROW"
    ;;
  backlog)
    BL_COUNT=$(grep -cE '^[0-9]+\.' "$INDEX_FILE" 2>/dev/null || true)
    BL_COUNT="${BL_COUNT:-0}"
    BL_COUNT="$(echo "$BL_COUNT" | tr -d '[:space:]')"
    BL_NEXT=$((BL_COUNT + 1))
    ENTRY="${BL_NEXT}. [${FILENAME}](docs/backlog/${FILENAME}) — \`${DEFAULT_STATUS}\`"
    insert_backlog_entry "$INDEX_FILE" "$ENTRY"
    ;;
  plan)
    ROW="| [${FILENAME}](docs/plans/${FILENAME}) | ${TITLE} | ${DEFAULT_STATUS} | ${TODAY} |"
    insert_table_row "$INDEX_FILE" "$ROW"
    ;;
esac

if $INDEX_UPDATED; then
  echo "Updated: $INDEX_FILE"
fi
