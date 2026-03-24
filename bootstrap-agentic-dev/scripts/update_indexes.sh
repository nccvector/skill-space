#!/usr/bin/env bash
# update_indexes.sh — Rebuild root overview files from docs/ contents.
# Usage: ./scripts/update_indexes.sh [--dry-run] [design|research|backlog|plans]
#   No args: rebuild all indexes.
#   Named arg: rebuild only that index.
#   --dry-run: print what would be written without modifying files.

set -euo pipefail

DRY_RUN=false
TARGETS=""

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    design|research|backlog|plans) TARGETS="$TARGETS $arg" ;;
    *) echo "Unknown argument: $arg"; exit 1 ;;
  esac
done

if [[ -z "$TARGETS" ]]; then
  TARGETS="design research backlog plans"
fi

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$REPO_ROOT"

# --- Extract a field value from a markdown metadata table ---
# Reads the first table in a file and extracts the value for a given field name.
extract_field() {
  local file="$1"
  local field="$2"
  awk -F'|' -v field="$field" '
    /^\|/ && !/^\|--/ {
      gsub(/^[ \t]+|[ \t]+$/, "", $2)
      gsub(/^[ \t]+|[ \t]+$/, "", $3)
      if (tolower($2) == tolower(field)) { print $3; exit }
    }
  ' "$file" | sed 's/^[ \t]*//;s/[ \t]*$//'
}

# --- Extract title from first H1 heading ---
extract_title() {
  local file="$1"
  head -5 "$file" | grep -m1 '^# ' | sed 's/^# //' | sed 's/^[A-Z]*-[0-9]*: //' | sed 's/^Backlog: //' | sed 's/^Research: //' | sed 's/^Plan: //'
}

# --- Write or print output ---
write_output() {
  local target_file="$1"
  local content="$2"
  if $DRY_RUN; then
    echo "=== Would write to: $target_file ==="
    echo "$content"
    echo ""
  else
    echo "$content" > "$target_file"
    echo "Updated: $target_file"
  fi
}

# ============================================================
# Rebuild DESIGN.md
# ============================================================
rebuild_design() {
  local dir="docs/design"
  if [[ ! -d "$dir" ]]; then
    echo "Skipping design: $dir does not exist"
    return
  fi

  local active_rows=""
  local archived_rows=""

  while IFS= read -r -d '' f; do
    local basename
    basename="$(basename "$f")"
    local title status updated
    title="$(extract_title "$f")"
    status="$(extract_field "$f" "Status")"
    updated="$(extract_field "$f" "Updated")"
    [[ -z "$updated" ]] && updated="$(extract_field "$f" "Last Updated")"
    [[ -z "$updated" ]] && updated="$(extract_field "$f" "Date")"
    [[ -z "$updated" ]] && updated="—"
    [[ -z "$status" ]] && status="DRAFT"
    [[ -z "$title" ]] && title="$basename"

    if [[ "$status" == "ARCHIVED" ]] || [[ "$status" == "REJECTED" ]]; then
      archived_rows="${archived_rows}| [${basename}](${dir}/${basename}) | ${title} | ${status} |\n"
    else
      active_rows="${active_rows}| [${basename}](${dir}/${basename}) | ${title} | ${status} | ${updated} |\n"
    fi
  done < <(find "$dir" -name '*.md' -print0 2>/dev/null | sort -z)

  [[ -z "$active_rows" ]] && active_rows="| _(none)_ | — | — | — |\n"
  [[ -z "$archived_rows" ]] && archived_rows="| _(none)_ | — | — |\n"

  local content
  content=$(printf '%s\n' \
"# DESIGN.md" \
"" \
"Overview of all design artifacts in \`docs/design/\`." \
"Agents must keep this file in sync with the current implementation." \
"" \
"## Active Design Artifacts" \
"" \
"| File | Title | Status | Last Updated |" \
"|------|-------|--------|--------------|")
  content="${content}"$'\n'"$(printf "%b" "$active_rows" | sed '/^$/d')"
  content="${content}"$'\n'$'\n'"$(printf '%s\n' \
"## Status Reference" \
"" \
"- DRAFT — being written, not yet reviewed" \
"- UNDER_REVIEW — open for feedback" \
"- ACCEPTED — approved, not yet implemented" \
"- IMPLEMENTED — accepted and in production" \
"- ARCHIVED — superseded or abandoned" \
"- REJECTED — explicitly decided against" \
"" \
"## Archived Artifacts" \
"" \
"| File | Title | Reason |" \
"|------|-------|--------|")"
  content="${content}"$'\n'"$(printf "%b" "$archived_rows" | sed '/^$/d')"

  write_output "DESIGN.md" "$content"
}

# ============================================================
# Rebuild RESEARCH.md
# ============================================================
rebuild_research() {
  local dir="docs/research"
  if [[ ! -d "$dir" ]]; then
    echo "Skipping research: $dir does not exist"
    return
  fi

  local active_rows=""

  while IFS= read -r -d '' f; do
    local basename
    basename="$(basename "$f")"
    local title status updated
    title="$(extract_title "$f")"
    status="$(extract_field "$f" "Status")"
    updated="$(extract_field "$f" "Date")"
    [[ -z "$updated" ]] && updated="—"
    [[ -z "$status" ]] && status="ACTIVE"
    [[ -z "$title" ]] && title="$basename"

    active_rows="${active_rows}| [${basename}](${dir}/${basename}) | ${title} | ${status} | ${updated} |\n"
  done < <(find "$dir" -name '*.md' -print0 2>/dev/null | sort -z)

  [[ -z "$active_rows" ]] && active_rows="| _(none)_ | — | — | — |\n"

  local content
  content=$(printf '%s\n' \
"# RESEARCH.md" \
"" \
"Overview of all research in \`docs/research/\`." \
"" \
"## Active Research" \
"" \
"| File | Topic | Status | Last Updated |" \
"|------|-------|--------|--------------|")
  content="${content}"$'\n'"$(printf "%b" "$active_rows" | sed '/^$/d')"
  content="${content}"$'\n'$'\n'"$(printf '%s\n' \
"## Status Reference" \
"" \
"- ACTIVE — ongoing research" \
"- EXPERIMENT — live experiment, results pending" \
"- IDEA — not yet formally pursued" \
"- COMPLETE — findings documented" \
"- IMPLEMENTED — findings were acted on" \
"- ARCHIVED — no longer relevant")"

  write_output "RESEARCH.md" "$content"
}

# ============================================================
# Rebuild BACKLOG.md
# ============================================================
rebuild_backlog() {
  local dir="docs/backlog"
  if [[ ! -d "$dir" ]]; then
    echo "Skipping backlog: $dir does not exist"
    return
  fi

  local active_items=""
  local archived_rows=""
  local count=0

  # Sort: IN_PROGRESS first, then PLANNED, then IDEA
  local in_progress="" planned="" ideas="" done_items=""

  while IFS= read -r -d '' f; do
    local basename
    basename="$(basename "$f")"
    local title status
    title="$(extract_title "$f")"
    status="$(extract_field "$f" "Status")"
    [[ -z "$status" ]] && status="IDEA"
    [[ -z "$title" ]] && title="$basename"

    local entry="[${basename}](${dir}/${basename}) — \`${status}\`"

    case "$status" in
      IN_PROGRESS) in_progress="${in_progress}${entry}\n" ;;
      PLANNED)     planned="${planned}${entry}\n" ;;
      IDEA)        ideas="${ideas}${entry}\n" ;;
      DONE)        done_items="${done_items}${entry}\n" ;;
      ARCHIVED)    archived_rows="${archived_rows}| [${basename}](${dir}/${basename}) | ${title} | Archived |\n" ;;
    esac
  done < <(find "$dir" -name '*.md' -print0 2>/dev/null | sort -z)

  # Build numbered list
  local numbered=""
  local num=0
  for group in "$in_progress" "$planned" "$ideas" "$done_items"; do
    while IFS= read -r line; do
      [[ -z "$line" ]] && continue
      num=$((num + 1))
      numbered="${numbered}${num}. ${line}\n"
    done < <(printf "%b" "$group")
  done

  [[ -z "$numbered" ]] && numbered="_(no items yet)_\n"
  [[ -z "$archived_rows" ]] && archived_rows="| _(none)_ | — | — |\n"

  local content
  content=$(printf '%s\n' \
"# BACKLOG.md" \
"" \
"Overview of all backlog items in \`docs/backlog/\`." \
"" \
"## Priority Order" \
"")
  content="${content}"$'\n'"$(printf "%b" "$numbered" | sed '/^$/d')"
  content="${content}"$'\n'$'\n'"$(printf '%s\n' \
"## Status Reference" \
"" \
"- PLANNED — prioritized, will be worked on" \
"- IDEA — not yet prioritized" \
"- IN_PROGRESS — currently being worked on" \
"- DONE — completed" \
"- ARCHIVED — decided against or no longer relevant" \
"" \
"## Archived Items" \
"" \
"| File | Summary | Reason |" \
"|------|---------|--------|")"
  content="${content}"$'\n'"$(printf "%b" "$archived_rows" | sed '/^$/d')"

  write_output "BACKLOG.md" "$content"
}

# ============================================================
# Rebuild PLANS.md
# ============================================================
rebuild_plans() {
  local dir="docs/plans"
  if [[ ! -d "$dir" ]]; then
    echo "Skipping plans: $dir does not exist"
    return
  fi

  local active_rows=""
  local completed_rows=""

  while IFS= read -r -d '' f; do
    local basename
    basename="$(basename "$f")"
    local title status updated
    title="$(extract_title "$f")"
    status="$(extract_field "$f" "Status")"
    updated="$(extract_field "$f" "Created")"
    [[ -z "$updated" ]] && updated="—"
    [[ -z "$status" ]] && status="PENDING_APPROVAL"
    [[ -z "$title" ]] && title="$basename"

    if [[ "$status" == "COMPLETED" ]] || [[ "$status" == "DONE" ]]; then
      completed_rows="${completed_rows}| [${basename}](${dir}/${basename}) | ${title} | ${status} | ${updated} |\n"
    else
      active_rows="${active_rows}| [${basename}](${dir}/${basename}) | ${title} | ${status} | ${updated} |\n"
    fi
  done < <(find "$dir" -name '*.md' -print0 2>/dev/null | sort -z)

  [[ -z "$active_rows" ]] && active_rows="| _(none)_ | — | — | — |\n"
  [[ -z "$completed_rows" ]] && completed_rows="| _(none)_ | — | — | — |\n"

  local content
  content=$(printf '%s\n' \
"# PLANS.md" \
"" \
"Overview of all plan files in \`docs/plans/\`." \
"" \
"## Active Plans" \
"" \
"| File | Goal | Status | Last Updated |" \
"|------|------|--------|--------------|")
  content="${content}"$'\n'"$(printf "%b" "$active_rows" | sed '/^$/d')"
  content="${content}"$'\n'$'\n'"$(printf '%s\n' \
"## Completed Plans" \
"" \
"| File | Goal | Final Status | Last Updated |" \
"|------|------|--------------|--------------|")"
  content="${content}"$'\n'"$(printf "%b" "$completed_rows" | sed '/^$/d')"

  write_output "PLANS.md" "$content"
}

# --- Run selected rebuilds ---
for target in $TARGETS; do
  case "$target" in
    design)   rebuild_design ;;
    research) rebuild_research ;;
    backlog)  rebuild_backlog ;;
    plans)    rebuild_plans ;;
  esac
done
