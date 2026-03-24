#!/usr/bin/env bash
# bootstrap_repo.sh — Create a full repo skeleton with all required files.
# Usage: ./scripts/bootstrap_repo.sh --name <project> --stack <stack> [options]
#   --name    Project name (required)
#   --stack   python, rust, node, cpp, ros2, embedded, none (required)
#   --agents  Comma-separated agent names (default: claude)
#   --license mit, apache-2.0, none (default: mit)
#   --plans   Include docs/plans/ and PLANS.md (optional, off by default)
#   --dir     Target directory (default: ./<name>)

set -euo pipefail

# --- Parse arguments ---
NAME="" STACK="" AGENTS="claude" LICENSE_TYPE="mit" TARGET_DIR="" WITH_PLANS=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --name)    NAME="$2"; shift 2 ;;
    --stack)   STACK="$2"; shift 2 ;;
    --agents)  AGENTS="$2"; shift 2 ;;
    --license) LICENSE_TYPE="$2"; shift 2 ;;
    --plans)   WITH_PLANS=true; shift ;;
    --dir)     TARGET_DIR="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

if [[ -z "$NAME" ]]; then
  echo "Error: --name is required."
  echo "Usage: $0 --name <project> --stack <stack> [--agents <a,b>] [--license mit|apache-2.0|none] [--dir <path>]"
  exit 1
fi

if [[ -z "$STACK" ]]; then
  echo "Error: --stack is required. Options: python, rust, node, cpp, ros2, embedded, none"
  exit 1
fi

[[ -z "$TARGET_DIR" ]] && TARGET_DIR="./$NAME"
TODAY="$(date +%Y-%m-%d)"
YEAR="$(date +%Y)"
AUTHOR="$(git config user.name 2>/dev/null || echo "Unknown")"

# Resolve script directory BEFORE cd-ing into the target
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_FILE="$SCRIPT_DIR/../references/AGENTS_TEMPLATE.md"

# --- Validate ---
case "$STACK" in
  python|rust|node|cpp|ros2|embedded|none) ;;
  *) echo "Error: unknown stack '$STACK'."; exit 1 ;;
esac

case "$LICENSE_TYPE" in
  mit|apache-2.0|none) ;;
  *) echo "Error: unknown license '$LICENSE_TYPE'. Use: mit, apache-2.0, none"; exit 1 ;;
esac

if [[ -d "$TARGET_DIR" ]] && [[ "$(ls -A "$TARGET_DIR" 2>/dev/null)" ]]; then
  echo "Error: $TARGET_DIR already exists and is not empty."
  exit 1
fi

echo "Bootstrapping project: $NAME"
echo "  Stack:   $STACK"
echo "  Agents:  $AGENTS"
echo "  License: $LICENSE_TYPE"
echo "  Plans:   $WITH_PLANS"
echo "  Dir:     $TARGET_DIR"
echo ""

# --- Create directory structure ---
mkdir -p "$TARGET_DIR"/{src,tests,docs/{design,research,backlog},scripts,config}
if $WITH_PLANS; then
  mkdir -p "$TARGET_DIR/docs/plans"
fi

cd "$TARGET_DIR"

# ============================================================
# Root-level files
# ============================================================

# --- README.md ---
cat > README.md << EOF
# ${NAME}

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

## Documentation

- [Design overview](DESIGN.md)
- [Research overview](RESEARCH.md)
- [Backlog](BACKLOG.md)
- [Agent rules](AGENTS.md)
EOF

# --- CLAUDE.md ---
cat > CLAUDE.md << 'EOF'
# CLAUDE.md

See [AGENTS.md](AGENTS.md) for all agent rules, roles, and documentation conventions.
EOF

# --- DESIGN.md ---
cat > DESIGN.md << 'EOF'
# DESIGN.md

Overview of all design artifacts in `docs/design/`.
Agents must keep this file in sync with the current implementation.

## Active Design Artifacts

| File | Title | Status | Last Updated |
|------|-------|--------|--------------|
| _(none)_ | — | — | — |

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
EOF

# --- RESEARCH.md ---
cat > RESEARCH.md << 'EOF'
# RESEARCH.md

Overview of all research in `docs/research/`.

## Active Research

| File | Topic | Status | Last Updated |
|------|-------|--------|--------------|
| _(none)_ | — | — | — |

## Status Reference

- ACTIVE — ongoing research
- EXPERIMENT — live experiment, results pending
- IDEA — not yet formally pursued
- COMPLETE — findings documented
- IMPLEMENTED — findings were acted on
- ARCHIVED — no longer relevant
EOF

# --- BACKLOG.md ---
cat > BACKLOG.md << 'EOF'
# BACKLOG.md

Overview of all backlog items in `docs/backlog/`.

## Priority Order

_(no items yet)_

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
EOF

# --- PLANS.md (only if --plans) ---
if $WITH_PLANS; then
  cat > PLANS.md << 'EOF'
# PLANS.md

Overview of all plan files in `docs/plans/`.

## Active Plans

| File | Goal | Status | Last Updated |
|------|------|--------|--------------|
| _(none)_ | — | — | — |

## Completed Plans

| File | Goal | Final Status | Last Updated |
|------|------|--------------|--------------|
| _(none)_ | — | — | — |
EOF
fi

# --- CHANGELOG.md ---
cat > CHANGELOG.md << 'EOF'
# CHANGELOG.md

All notable changes to this project are documented here.

## Unreleased

### Added

- _(none yet)_

### Changed

- _(none yet)_

### Fixed

- _(none yet)_
EOF

# --- AGENTS.md (generated from canonical template) ---
if [[ ! -f "$TEMPLATE_FILE" ]]; then
  echo "Error: Cannot find AGENTS_TEMPLATE.md at $TEMPLATE_FILE"
  echo "bootstrap_repo.sh must be run from the skill directory."
  exit 1
fi

# Build agent roles table rows
build_agent_roles() {
  local agents_csv="$1"
  IFS=',' read -ra agent_list <<< "$agents_csv"
  local first=true
  for agent in "${agent_list[@]}"; do
    agent="$(echo "$agent" | sed 's/^[ \t]*//;s/[ \t]*$//')"
    local cap_agent
    cap_agent="$(echo "${agent:0:1}" | tr '[:lower:]' '[:upper:]')${agent:1}"
    if $first; then
      echo "| ${cap_agent} | Engineer, Debugger | Default implementer |"
      first=false
    else
      echo "| ${cap_agent} | Researcher, Reviewer | — |"
    fi
  done
}

AGENT_ROWS_FILE="$(mktemp)"
build_agent_roles "$AGENTS" > "$AGENT_ROWS_FILE"

# Read template, replace the placeholder roles table, and conditionally
# strip PLANS.md references if --plans was not passed.
awk '
  /^\| Claude \|/ { next }
  /^\| Codex \|/ { next }
  /^\| _\(add more\)_ \|/ {
    while ((getline line < "'"$AGENT_ROWS_FILE"'") > 0) print line
    next
  }
  { print }
' "$TEMPLATE_FILE" > AGENTS.md
rm -f "$AGENT_ROWS_FILE"

# If plans are disabled, strip PLANS.md and docs/plans/ references
if ! $WITH_PLANS; then
  # Remove lines that reference PLANS.md or docs/plans/
  sed -i '' \
    -e '/^- `PLANS\.md`/d' \
    -e '/^- `docs\/plans\/`/d' \
    AGENTS.md
fi

# --- .gitignore ---
cat > .gitignore << 'EOF'
# OS
.DS_Store
Thumbs.db

# Editors
*.swp
*.swo
*~
.idea/
.vscode/

# Environment
.env
.env.*
!.env.example

# Build
build/
dist/
out/

# Dependencies (stack-specific entries added below)
EOF

# --- Stack-specific files ---
case "$STACK" in
  python)
    cat >> .gitignore << 'EOF'

# Python
__pycache__/
*.pyc
*.pyo
*.egg-info/
.venv/
venv/
.pytest_cache/
.mypy_cache/
EOF
    cat > pyproject.toml << PYEOF
[project]
name = "${NAME}"
version = "0.1.0"
description = ""
requires-python = ">=3.11"
dependencies = []

[project.optional-dependencies]
dev = [
    "pytest",
    "ruff",
]

[tool.ruff]
line-length = 100

[tool.pytest.ini_options]
testpaths = ["tests"]
PYEOF
    ;;

  rust)
    cat >> .gitignore << 'EOF'

# Rust
target/
Cargo.lock
EOF
    cat > Cargo.toml << RSEOF
[package]
name = "${NAME}"
version = "0.1.0"
edition = "2021"

[dependencies]
RSEOF
    # For binaries, commit Cargo.lock
    sed -i '' '/Cargo.lock/d' .gitignore 2>/dev/null || true
    ;;

  node)
    cat >> .gitignore << 'EOF'

# Node.js
node_modules/
npm-debug.log*
yarn-error.log*
.env.local
EOF
    cat > package.json << NODEEOF
{
  "name": "${NAME}",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "build": "echo 'Add build command'",
    "test": "echo 'Add test command'",
    "start": "echo 'Add start command'"
  }
}
NODEEOF
    cat > tsconfig.json << 'TSEOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "strict": true,
    "outDir": "dist",
    "rootDir": "src"
  },
  "include": ["src"]
}
TSEOF
    echo "lts/*" > .nvmrc
    ;;

  cpp)
    cat >> .gitignore << 'EOF'

# C/C++
build/
*.o
*.a
*.so
*.dylib
compile_commands.json
EOF
    mkdir -p include
    cat > CMakeLists.txt << CMAKEEOF
cmake_minimum_required(VERSION 3.20)
project(${NAME} LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

add_executable(\${PROJECT_NAME} src/main.cpp)
CMAKEEOF
    ;;

  ros2)
    cat >> .gitignore << 'EOF'

# ROS 2
build/
install/
log/
EOF
    mkdir -p launch config
    cat > package.xml << ROS2EOF
<?xml version="1.0"?>
<package format="3">
  <name>${NAME}</name>
  <version>0.1.0</version>
  <description>${NAME}</description>
  <maintainer email="todo@todo.com">${AUTHOR}</maintainer>
  <license>MIT</license>
  <buildtool_depend>ament_cmake</buildtool_depend>
</package>
ROS2EOF
    cat > CMakeLists.txt << CMAKEEOF
cmake_minimum_required(VERSION 3.8)
project(${NAME})

find_package(ament_cmake REQUIRED)

ament_package()
CMAKEEOF
    ;;

  embedded)
    cat >> .gitignore << 'EOF'

# Embedded
build/
.pio/
*.elf
*.hex
*.bin
*.map
EOF
    mkdir -p hal linker
    cat > platformio.ini << PIOEOF
[env:default]
platform = ststm32
board = genericSTM32F103C8
framework = cmsis
PIOEOF
    ;;

  none)
    ;;
esac

# --- LICENSE ---
case "$LICENSE_TYPE" in
  mit)
    cat > LICENSE << LICEOF
MIT License

Copyright (c) ${YEAR} ${AUTHOR}

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
LICEOF
    ;;
  apache-2.0)
    cat > LICENSE << LICEOF
                                 Apache License
                           Version 2.0, January 2004
                        http://www.apache.org/licenses/

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

   Copyright ${YEAR} ${AUTHOR}
LICEOF
    ;;
  none)
    # No license file for proprietary repos
    ;;
esac

# ============================================================
# Copy utility scripts into the new repo
# ============================================================

# --- Copy utility scripts (self-contained copies) ---
for script in check_docs.sh bootstrap_doc.sh update_indexes.sh; do
  if [[ -f "$SCRIPT_DIR/$script" ]]; then
    cp "$SCRIPT_DIR/$script" "scripts/$script"
    chmod +x "scripts/$script"
  fi
done

# ============================================================
# Git init and initial commit
# ============================================================
git init -q
git add -A
git commit -q -m "Initial repo scaffold

Stack: ${STACK}
Agents: ${AGENTS}
License: ${LICENSE_TYPE}

Generated by bootstrap_repo.sh"

echo ""
echo "Done! Project created at: $(pwd)"
echo ""
echo "Files created:"
find . -not -path './.git/*' -not -path './.git' -type f | sort | sed 's|^./|  |'
echo ""
echo "Next steps:"
echo "  cd $TARGET_DIR"
echo "  ./scripts/check_docs.sh          # verify doc conventions"
echo "  ./scripts/bootstrap_doc.sh rfc \"my first design\"  # create an RFC"
