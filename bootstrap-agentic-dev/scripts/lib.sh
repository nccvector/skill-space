#!/usr/bin/env bash
# lib.sh — Shared functions for bootstrap scripts.
# Source this file, do not execute it directly.
#
# Usage from sibling scripts:
#   LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
#   source "$LIB"

# Guard against double-sourcing
[[ -n "${_BOOTSTRAP_LIB_LOADED:-}" ]] && return 0
_BOOTSTRAP_LIB_LOADED=1

# ============================================================
# Metadata extraction
# ============================================================

# Extract a field value from the first markdown metadata table in a file.
# Usage: extract_field <file> <field_name>
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

# Extract title from the first H1 heading, stripping common prefixes.
# Usage: extract_title <file>
extract_title() {
  local file="$1"
  head -5 "$file" | grep -m1 '^# ' | \
    sed 's/^# //' | \
    sed 's/^[A-Z]*-[0-9]*: //' | \
    sed 's/^Backlog: //' | \
    sed 's/^Research: //' | \
    sed 's/^Plan: //'
}

# ============================================================
# Text normalization
# ============================================================

# Normalize a human title to ALL_CAPS_WITH_UNDERSCORES.
# Usage: normalize_title "new ipc layer"  →  NEW_IPC_LAYER
normalize_title() {
  echo "$1" | tr '[:lower:]' '[:upper:]' | \
    sed 's/[^A-Z0-9]/_/g' | \
    sed 's/__*/_/g' | \
    sed 's/^_//;s/_$//'
}

# ============================================================
# Auto-numbering
# ============================================================

# Find the next sequential number for a prefix in a directory.
# Usage: next_number <prefix> <dir>  →  0001
next_number() {
  local prefix="$1"
  local dir="$2"
  local max=0
  if [[ -d "$dir" ]]; then
    for f in "$dir"/${prefix}_[0-9]*; do
      [[ -e "$f" ]] || continue
      num="$(basename "$f" | sed "s/^${prefix}_//" | grep -oE '^[0-9]+' || echo 0)"
      if [[ "$num" -gt "$max" ]]; then
        max="$num"
      fi
    done
  fi
  printf "%04d" $((max + 1))
}

# ============================================================
# Template extraction from reference .md files
# ============================================================

# Extract content between ```markdown fences under a ## heading.
# Usage: extract_template <file> <section_heading>
# Example: extract_template TEMPLATES.md "DESIGN.md Template"
extract_template() {
  local file="$1"
  local heading="$2"
  awk -v heading="$heading" '
    BEGIN { found=0; in_fence=0 }
    $0 ~ "^## " heading "$" { found=1; next }
    found && /^## / { exit }
    found && /^```markdown/ { in_fence=1; next }
    found && in_fence && /^```/ { exit }
    in_fence { print }
  ' "$file"
}

# ============================================================
# Config file reading
# ============================================================

# Read a value from bootstrap.env (KEY=VALUE format).
# Usage: read_bootstrap_env <key> [<default>]
# Returns the value or the default if not found / file missing.
read_bootstrap_env() {
  local key="$1"
  local default="${2:-}"
  local env_file
  env_file="$(git rev-parse --show-toplevel 2>/dev/null || pwd)/bootstrap.env"

  if [[ -f "$env_file" ]]; then
    local val
    val=$(grep -E "^${key}=" "$env_file" 2>/dev/null | head -1 | cut -d= -f2-)
    if [[ -n "$val" ]]; then
      echo "$val"
      return
    fi
  fi
  echo "$default"
}

# ============================================================
# Output helpers
# ============================================================

# Write content to a file or print it (dry-run mode).
# Usage: write_output <file> <content> <dry_run_bool>
write_output() {
  local target_file="$1"
  local content="$2"
  local dry_run="${3:-false}"
  if $dry_run; then
    echo "=== Would write to: $target_file ==="
    echo "$content"
    echo ""
  else
    echo "$content" > "$target_file"
    echo "Updated: $target_file"
  fi
}
