#!/usr/bin/env bash
# smoke_test.sh — End-to-end tests for the bootstrap system.
# Tests all profiles × representative stacks.
# Usage: ./scripts/smoke_test.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOOTSTRAP="$SCRIPT_DIR/bootstrap_repo.sh"

TMPDIR_BASE="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_BASE"' EXIT

PASSED=0
FAILED=0
TOTAL=0

pass() {
  PASSED=$((PASSED + 1))
  TOTAL=$((TOTAL + 1))
  printf "  \033[0;32mPASS\033[0m %s\n" "$1"
}

fail() {
  FAILED=$((FAILED + 1))
  TOTAL=$((TOTAL + 1))
  printf "  \033[0;31mFAIL\033[0m %s\n" "$1"
}

assert_file_exists() {
  if [[ -f "$1" ]]; then
    pass "$1 exists"
  else
    fail "$1 should exist but doesn't"
  fi
}

assert_file_missing() {
  if [[ ! -f "$1" ]]; then
    pass "$1 correctly absent"
  else
    fail "$1 should not exist but does"
  fi
}

assert_dir_exists() {
  if [[ -d "$1" ]]; then
    pass "$1/ exists"
  else
    fail "$1/ should exist but doesn't"
  fi
}

assert_dir_missing() {
  if [[ ! -d "$1" ]]; then
    pass "$1/ correctly absent"
  else
    fail "$1/ should not exist but does"
  fi
}

# ============================================================
# Test a single profile + stack combination
# ============================================================
run_test() {
  local profile="$1"
  local stack="$2"
  local name="smoke-${profile}-${stack}"
  local dir="$TMPDIR_BASE/$name"

  printf "\n\033[1m=== Testing: profile=%s stack=%s ===\033[0m\n" "$profile" "$stack"

  # 1. Bootstrap
  if ! "$BOOTSTRAP" --name "$name" --stack "$stack" --profile "$profile" \
       --agents "claude,codex" --license mit --dir "$dir" > /dev/null 2>&1; then
    fail "bootstrap_repo.sh failed"
    return
  fi
  pass "bootstrap_repo.sh succeeded"

  cd "$dir"

  # 2. check_docs passes on fresh repo
  if ./scripts/check_docs.sh --ci > /dev/null 2>&1; then
    pass "check_docs.sh --ci passes on fresh repo"
  else
    fail "check_docs.sh --ci failed on fresh repo"
  fi

  # 3. Verify bootstrap.env
  assert_file_exists "bootstrap.env"
  local env_profile
  env_profile=$(grep '^PROFILE=' bootstrap.env | cut -d= -f2-)
  if [[ "$env_profile" == "$profile" ]]; then
    pass "bootstrap.env PROFILE=$profile"
  else
    fail "bootstrap.env PROFILE expected '$profile' got '$env_profile'"
  fi

  # 4. Profile-specific file assertions
  # All profiles
  assert_file_exists "README.md"
  assert_file_exists "AGENTS.md"
  assert_file_exists "CLAUDE.md"
  assert_file_exists "CHANGELOG.md"
  assert_file_exists ".gitignore"
  assert_file_exists "scripts/lib.sh"
  assert_file_exists "scripts/check_docs.sh"

  case "$profile" in
    minimal)
      assert_file_missing "DESIGN.md"
      assert_file_missing "RESEARCH.md"
      assert_file_missing "BACKLOG.md"
      assert_file_missing "PLANS.md"
      assert_dir_missing "docs"
      assert_file_missing "scripts/bootstrap_doc.sh"
      assert_file_missing "scripts/update_indexes.sh"
      ;;
    standard)
      assert_file_exists "DESIGN.md"
      assert_file_exists "RESEARCH.md"
      assert_file_exists "BACKLOG.md"
      assert_file_missing "PLANS.md"
      assert_dir_exists "docs/design"
      assert_dir_exists "docs/research"
      assert_dir_exists "docs/backlog"
      assert_dir_missing "docs/plans"
      assert_file_exists "scripts/bootstrap_doc.sh"
      assert_file_exists "scripts/update_indexes.sh"
      ;;
    agentic)
      assert_file_exists "DESIGN.md"
      assert_file_exists "RESEARCH.md"
      assert_file_exists "BACKLOG.md"
      assert_file_exists "PLANS.md"
      assert_dir_exists "docs/plans"
      assert_file_exists "scripts/bootstrap_doc.sh"
      assert_file_exists "scripts/update_indexes.sh"
      ;;
  esac

  # 5. AGENTS.md template alignment (minus role rows)
  local agents_template="$SCRIPT_DIR/../references/AGENTS_TEMPLATE.md"
  if [[ -f "$agents_template" ]]; then
    local diff_output
    diff_output=$(diff \
      <(sed -e '/^\| Claude /d' -e '/^\| Codex /d' -e '/^\| _(add more)_ /d' "$agents_template") \
      <(sed -e '/^\| Claude /d' -e '/^\| Codex /d' AGENTS.md) 2>&1 || true)

    # For non-agentic profiles, expect PLANS.md lines to be stripped
    if [[ "$profile" != "agentic" ]]; then
      diff_output=$(echo "$diff_output" | grep -v 'PLANS\.md' | grep -v 'docs/plans/' || true)
    fi

    if [[ -z "$(echo "$diff_output" | grep '^[<>]' || true)" ]]; then
      pass "AGENTS.md matches canonical template"
    else
      fail "AGENTS.md diverges from template"
    fi
  fi

  # 6. Doc generation (standard and agentic only)
  if [[ "$profile" != "minimal" ]]; then
    # Create an RFC
    if ./scripts/bootstrap_doc.sh rfc "test design" > /dev/null 2>&1; then
      pass "bootstrap_doc.sh rfc succeeded"
      assert_file_exists "docs/design/RFC_0001_TEST_DESIGN.md"
    else
      fail "bootstrap_doc.sh rfc failed"
    fi

    # Create a backlog item
    if ./scripts/bootstrap_doc.sh backlog "test item" > /dev/null 2>&1; then
      pass "bootstrap_doc.sh backlog succeeded"
      assert_file_exists "docs/backlog/BACKLOG_TEST_ITEM.md"
    else
      fail "bootstrap_doc.sh backlog failed"
    fi

    # Create a plan (agentic only — should succeed; standard — should skip index)
    if [[ "$profile" == "agentic" ]]; then
      if ./scripts/bootstrap_doc.sh plan "test plan" --agent claude > /dev/null 2>&1; then
        pass "bootstrap_doc.sh plan succeeded"
        assert_file_exists "docs/plans/PLAN_CLAUDE_TEST_PLAN.md"
      else
        fail "bootstrap_doc.sh plan failed"
      fi
    fi

    # Rebuild indexes
    if ./scripts/update_indexes.sh > /dev/null 2>&1; then
      pass "update_indexes.sh succeeded"
    else
      fail "update_indexes.sh failed"
    fi

    # Verify RFC appears in DESIGN.md
    if grep -q "RFC_0001_TEST_DESIGN" DESIGN.md 2>/dev/null; then
      pass "DESIGN.md references RFC after update"
    else
      fail "DESIGN.md missing RFC reference after update"
    fi

    # check_docs still passes after mutations
    if ./scripts/check_docs.sh --ci > /dev/null 2>&1; then
      pass "check_docs.sh --ci passes after mutations"
    else
      fail "check_docs.sh --ci failed after mutations"
    fi
  fi

  cd "$TMPDIR_BASE"
}

# ============================================================
# Run all test combinations
# ============================================================
echo "Bootstrap System Smoke Tests"
echo "============================"

# Profile × Stack matrix (representative subset)
run_test minimal none
run_test standard python
run_test standard node
run_test agentic python

# ============================================================
# Summary
# ============================================================
printf "\n\033[1m=== Summary ===\033[0m\n"
printf "Total: %d  Passed: \033[0;32m%d\033[0m  Failed: \033[0;31m%d\033[0m\n" "$TOTAL" "$PASSED" "$FAILED"

if [[ "$FAILED" -gt 0 ]]; then
  exit 1
fi
