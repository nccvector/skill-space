#!/usr/bin/env bash
# check_docs.sh — Policy linter for repo doc conventions.
# Enforces naming, line/word limits, required files, and index references.
# Profile-aware: reads PROFILE from bootstrap.env to adjust required files.
# Usage: ./scripts/check_docs.sh [--ci]
#   --ci  Exit 1 on any violation. Machine-readable output (no color).

set -euo pipefail

# Source shared library
LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
source "$LIB"

CI_MODE=false
if [[ "${1:-}" == "--ci" ]]; then
  CI_MODE=true
fi

# --- Colors ---
if $CI_MODE || [[ ! -t 1 ]]; then
  RED="" GREEN="" YELLOW="" BOLD="" RESET=""
else
  RED="\033[0;31m" GREEN="\033[0;32m" YELLOW="\033[0;33m"
  BOLD="\033[1m" RESET="\033[0m"
fi

VIOLATIONS=0
WARNINGS=0

fail() {
  VIOLATIONS=$((VIOLATIONS + 1))
  printf "${RED}FAIL${RESET} %s\n" "$1"
}

warn() {
  WARNINGS=$((WARNINGS + 1))
  printf "${YELLOW}WARN${RESET} %s\n" "$1"
}

pass() {
  printf "${GREEN}OK${RESET}   %s\n" "$1"
}

# --- Find repo root and read profile ---
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$REPO_ROOT"

PROFILE="$(read_bootstrap_env PROFILE "standard")"

echo "${BOLD}Checking docs in: ${REPO_ROOT} (profile: ${PROFILE})${RESET}"
echo ""

# ============================================================
# Check 1: Required root-level files (profile-dependent)
# ============================================================
echo "${BOLD}--- Required Files ---${RESET}"

# All profiles require these
REQUIRED_FILES="README.md AGENTS.md CLAUDE.md .gitignore CHANGELOG.md"

# Standard and agentic profiles additionally require index files
if [[ "$PROFILE" != "minimal" ]]; then
  REQUIRED_FILES="$REQUIRED_FILES DESIGN.md RESEARCH.md BACKLOG.md"
fi

for f in $REQUIRED_FILES; do
  if [[ -f "$f" ]]; then
    pass "$f exists"
  else
    fail "$f is missing"
  fi
done

# LICENSE is soft-required for non-minimal profiles
if [[ "$PROFILE" != "minimal" ]]; then
  if [[ -f "LICENSE" ]]; then
    pass "LICENSE exists"
  else
    warn "LICENSE is missing (required unless internal/proprietary)"
  fi
fi

# PLANS.md is required only for agentic profile
if [[ "$PROFILE" == "agentic" ]]; then
  if [[ -f "PLANS.md" ]]; then
    pass "PLANS.md exists"
  else
    fail "PLANS.md is missing (required for agentic profile)"
  fi
fi

echo ""

# ============================================================
# Check 2: Naming conventions
# ============================================================
echo "${BOLD}--- Naming Conventions ---${RESET}"

ALLOWED_ROOT_NAMES="README.md CHANGELOG.md CONTRIBUTING.md CODEOWNERS SECURITY.md LICENSE"

check_md_naming() {
  local file="$1"
  local basename
  basename="$(basename "$file")"

  for allowed in $ALLOWED_ROOT_NAMES; do
    if [[ "$basename" == "$allowed" ]]; then
      return 0
    fi
  done

  if [[ "$basename" =~ ^[A-Z][A-Z0-9_]*\.md$ ]]; then
    return 0
  else
    fail "Bad filename: $file (must be ALL_CAPS_WITH_UNDERSCORES.md)"
    return 1
  fi
}

while IFS= read -r -d '' mdfile; do
  check_md_naming "$mdfile"
done < <(find . -name '*.md' -not -path './.git/*' -not -path './node_modules/*' \
  -not -path './vendor/*' -not -path './.venv/*' -not -path './target/*' \
  -not -path './.claude/*' -print0 2>/dev/null)

echo ""

# ============================================================
# Check 3: Line and word limits
# ============================================================
echo "${BOLD}--- Line & Word Limits ---${RESET}"

while IFS= read -r -d '' mdfile; do
  lines=$(wc -l < "$mdfile")
  words=$(wc -w < "$mdfile")
  basename="$(basename "$mdfile")"

  if [[ "$basename" == "README.md" ]] && [[ "$lines" -gt 150 ]]; then
    fail "$mdfile: $lines lines (max 150 for README)"
  elif [[ "$lines" -gt 400 ]]; then
    fail "$mdfile: $lines lines (max 400)"
  fi

  if [[ "$words" -gt 8000 ]]; then
    fail "$mdfile: $words words (max 8000)"
  fi
done < <(find . -name '*.md' -not -path './.git/*' -not -path './node_modules/*' \
  -not -path './vendor/*' -not -path './.venv/*' -not -path './target/*' \
  -not -path './.claude/*' -print0 2>/dev/null)

echo ""

# ============================================================
# Check 4: No binary files in docs/
# ============================================================
echo "${BOLD}--- docs/ Content ---${RESET}"

if [[ -d "docs" ]]; then
  binary_found=false
  while IFS= read -r -d '' docfile; do
    if file --mime-type "$docfile" 2>/dev/null | grep -qvE 'text/|application/json|inode/empty'; then
      fail "Binary file in docs/: $docfile"
      binary_found=true
    fi
  done < <(find docs -type f -not -name '*.md' -print0 2>/dev/null)

  if ! $binary_found; then
    non_md=$(find docs -type f -not -name '*.md' 2>/dev/null | head -5)
    if [[ -n "$non_md" ]]; then
      while IFS= read -r f; do
        warn "Non-markdown file in docs/: $f"
      done <<< "$non_md"
    else
      pass "docs/ contains only .md files"
    fi
  fi
elif [[ "$PROFILE" != "minimal" ]]; then
  warn "docs/ directory does not exist"
fi

echo ""

# ============================================================
# Check 5: Index references — every doc is reachable
# ============================================================
echo "${BOLD}--- Index References ---${RESET}"

check_index_refs() {
  local subdir="$1"
  local index_file="$2"

  if [[ ! -d "docs/$subdir" ]]; then
    return 0
  fi

  if [[ ! -f "$index_file" ]]; then
    local count
    count=$(find "docs/$subdir" -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$count" -gt 0 ]]; then
      fail "$index_file missing but docs/$subdir/ has $count files"
    fi
    return 0
  fi

  local index_content
  index_content=$(cat "$index_file")

  while IFS= read -r -d '' docfile; do
    local basename
    basename="$(basename "$docfile")"
    if echo "$index_content" | grep -qF "$basename"; then
      :
    else
      fail "$docfile not referenced in $index_file"
    fi
  done < <(find "docs/$subdir" -name '*.md' -print0 2>/dev/null)
}

if [[ "$PROFILE" != "minimal" ]]; then
  check_index_refs "design"   "DESIGN.md"
  check_index_refs "research" "RESEARCH.md"
  check_index_refs "backlog"  "BACKLOG.md"
  check_index_refs "plans"    "PLANS.md"

  for subdir in design research backlog plans; do
    if [[ -d "docs/$subdir" ]]; then
      count=$(find "docs/$subdir" -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
      if [[ "$count" -gt 0 ]]; then
        case "$subdir" in
          design)   [[ -f "DESIGN.md" ]]   && pass "DESIGN.md indexes docs/design/"   || : ;;
          research) [[ -f "RESEARCH.md" ]]  && pass "RESEARCH.md indexes docs/research/" || : ;;
          backlog)  [[ -f "BACKLOG.md" ]]   && pass "BACKLOG.md indexes docs/backlog/"  || : ;;
          plans)    [[ -f "PLANS.md" ]]     && pass "PLANS.md indexes docs/plans/"     || : ;;
        esac
      fi
    fi
  done
fi

echo ""

# ============================================================
# Summary
# ============================================================
echo "${BOLD}--- Summary ---${RESET}"

if [[ "$VIOLATIONS" -eq 0 ]] && [[ "$WARNINGS" -eq 0 ]]; then
  echo "${GREEN}All checks passed.${RESET}"
elif [[ "$VIOLATIONS" -eq 0 ]]; then
  echo "${YELLOW}$WARNINGS warning(s), 0 violations.${RESET}"
else
  echo "${RED}$VIOLATIONS violation(s), $WARNINGS warning(s).${RESET}"
fi

if $CI_MODE && [[ "$VIOLATIONS" -gt 0 ]]; then
  exit 1
fi

exit 0
