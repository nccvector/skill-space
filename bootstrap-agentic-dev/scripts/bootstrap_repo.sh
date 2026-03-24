#!/usr/bin/env bash
# bootstrap_repo.sh — Create a full repo skeleton with all required files.
# Usage: ./scripts/bootstrap_repo.sh --name <project> --stack <stack> [options]
#   --name      Project name (required)
#   --stack     python, rust, node, cpp, ros2, embedded, none (required)
#   --profile   minimal, standard, agentic (default: standard)
#   --agents    Comma-separated agent names (default: claude)
#   --license   mit, apache-2.0, none (default: mit)
#   --plans     Shorthand for --profile agentic
#   --dir       Target directory (default: ./<name>)

set -euo pipefail

# Resolve script/skill directory BEFORE anything else
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REFS_DIR="$SCRIPT_DIR/../references"

# Source shared library
LIB="$SCRIPT_DIR/lib.sh"
source "$LIB"

# --- Parse arguments ---
NAME="" STACK="" PROFILE="standard" AGENTS="claude" LICENSE_TYPE="mit" TARGET_DIR=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --name)    NAME="$2"; shift 2 ;;
    --stack)   STACK="$2"; shift 2 ;;
    --profile) PROFILE="$2"; shift 2 ;;
    --agents)  AGENTS="$2"; shift 2 ;;
    --license) LICENSE_TYPE="$2"; shift 2 ;;
    --plans)   PROFILE="agentic"; shift ;;
    --dir)     TARGET_DIR="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

if [[ -z "$NAME" ]]; then
  echo "Error: --name is required."
  echo "Usage: $0 --name <project> --stack <stack> [--profile minimal|standard|agentic] [--agents <a,b>] [--license mit|apache-2.0|none]"
  exit 1
fi

if [[ -z "$STACK" ]]; then
  echo "Error: --stack is required. Options: python, rust, node, cpp, ros2, embedded, none"
  exit 1
fi

# --- Validate ---
case "$STACK" in
  python|rust|node|cpp|ros2|embedded|none) ;;
  *) echo "Error: unknown stack '$STACK'."; exit 1 ;;
esac

case "$LICENSE_TYPE" in
  mit|apache-2.0|none) ;;
  *) echo "Error: unknown license '$LICENSE_TYPE'. Use: mit, apache-2.0, none"; exit 1 ;;
esac

case "$PROFILE" in
  minimal|standard|agentic) ;;
  *) echo "Error: unknown profile '$PROFILE'. Use: minimal, standard, agentic"; exit 1 ;;
esac

[[ -z "$TARGET_DIR" ]] && TARGET_DIR="./$NAME"
TODAY="$(date +%Y-%m-%d)"
YEAR="$(date +%Y)"
AUTHOR="$(git config user.name 2>/dev/null || echo "Unknown")"

# --- Reference files ---
TEMPLATES_FILE="$REFS_DIR/TEMPLATES.md"
ARTIFACTS_FILE="$REFS_DIR/TEMPLATES_ARTIFACTS.md"
AGENTS_TEMPLATE="$REFS_DIR/AGENTS_TEMPLATE.md"

for ref in "$TEMPLATES_FILE" "$ARTIFACTS_FILE" "$AGENTS_TEMPLATE"; do
  if [[ ! -f "$ref" ]]; then
    echo "Error: Cannot find $ref"
    echo "bootstrap_repo.sh must be run from the skill directory."
    exit 1
  fi
done

if [[ -d "$TARGET_DIR" ]] && [[ "$(ls -A "$TARGET_DIR" 2>/dev/null)" ]]; then
  echo "Error: $TARGET_DIR already exists and is not empty."
  exit 1
fi

echo "Bootstrapping project: $NAME"
echo "  Stack:   $STACK"
echo "  Profile: $PROFILE"
echo "  Agents:  $AGENTS"
echo "  License: $LICENSE_TYPE"
echo "  Dir:     $TARGET_DIR"
echo ""

# ============================================================
# Create directory structure (profile-dependent)
# ============================================================
mkdir -p "$TARGET_DIR"/{src,tests,scripts}

if [[ "$PROFILE" != "minimal" ]]; then
  mkdir -p "$TARGET_DIR"/{docs/{design,research,backlog},config}
fi

if [[ "$PROFILE" == "agentic" ]]; then
  mkdir -p "$TARGET_DIR/docs/plans"
fi

cd "$TARGET_DIR"

# ============================================================
# Root-level files (all profiles)
# ============================================================

# --- README.md (needs variable substitution) ---
extract_template "$TEMPLATES_FILE" "README Template" | \
  sed "s/# Project Name/# ${NAME}/" > README.md

# --- CLAUDE.md ---
extract_template "$TEMPLATES_FILE" "CLAUDE.md Template" > CLAUDE.md

# --- CHANGELOG.md ---
extract_template "$TEMPLATES_FILE" "CHANGELOG.md Template" > CHANGELOG.md

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

# ============================================================
# Standard + Agentic profile files
# ============================================================
if [[ "$PROFILE" != "minimal" ]]; then
  extract_template "$TEMPLATES_FILE" "DESIGN.md Template" > DESIGN.md
  extract_template "$TEMPLATES_FILE" "RESEARCH.md Template" > RESEARCH.md
  extract_template "$TEMPLATES_FILE" "BACKLOG.md Template" > BACKLOG.md

  if [[ "$LICENSE_TYPE" != "none" ]]; then
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
    esac
  fi
fi

# ============================================================
# Agentic profile: PLANS.md
# ============================================================
if [[ "$PROFILE" == "agentic" ]]; then
  extract_template "$TEMPLATES_FILE" "PLANS.md Template" > PLANS.md
fi

# ============================================================
# AGENTS.md (from canonical template)
# ============================================================
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

awk '
  /^\| Claude \|/ { next }
  /^\| Codex \|/ { next }
  /^\| _\(add more\)_ \|/ {
    while ((getline line < "'"$AGENT_ROWS_FILE"'") > 0) print line
    next
  }
  { print }
' "$AGENTS_TEMPLATE" > AGENTS.md
rm -f "$AGENT_ROWS_FILE"

# Strip plan references for non-agentic profiles
if [[ "$PROFILE" != "agentic" ]]; then
  sed -i '' \
    -e '/^- `PLANS\.md`/d' \
    -e '/^- `docs\/plans\/`/d' \
    AGENTS.md
fi

# ============================================================
# Stack-specific files
# ============================================================
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
EOF
    cat > Cargo.toml << RSEOF
[package]
name = "${NAME}"
version = "0.1.0"
edition = "2021"

[dependencies]
RSEOF
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

# ============================================================
# bootstrap.env
# ============================================================
cat > bootstrap.env << ENVEOF
# bootstrap.env — project bootstrap defaults (passive, read-only by scripts)
PROJECT_NAME=${NAME}
STACK=${STACK}
PROFILE=${PROFILE}
AGENTS=${AGENTS}
LICENSE=${LICENSE_TYPE}
ENVEOF

# ============================================================
# Copy utility scripts into the new repo
# ============================================================

# lib.sh is always copied (all profiles need it)
cp "$SCRIPT_DIR/lib.sh" "scripts/lib.sh"
chmod +x "scripts/lib.sh"

# check_docs.sh is always copied (all profiles)
if [[ -f "$SCRIPT_DIR/check_docs.sh" ]]; then
  cp "$SCRIPT_DIR/check_docs.sh" "scripts/check_docs.sh"
  chmod +x "scripts/check_docs.sh"
fi

# Standard and agentic profiles get doc generators and index rebuilders
if [[ "$PROFILE" != "minimal" ]]; then
  # Copy bootstrap_doc.sh and bake templates into it
  if [[ -f "$SCRIPT_DIR/bootstrap_doc.sh" ]]; then
    cp "$SCRIPT_DIR/bootstrap_doc.sh" "scripts/bootstrap_doc.sh"
    chmod +x "scripts/bootstrap_doc.sh"

    # Bake: replace the extract_template path check so HAS_REFS=false in copied version
    # This forces the copied script to use the fallback heredocs
    sed -i '' 's/^\[.*HAS_REFS=true$/HAS_REFS=false  # baked copy — uses fallback heredocs/' \
      "scripts/bootstrap_doc.sh" 2>/dev/null || true
  fi

  if [[ -f "$SCRIPT_DIR/update_indexes.sh" ]]; then
    cp "$SCRIPT_DIR/update_indexes.sh" "scripts/update_indexes.sh"
    chmod +x "scripts/update_indexes.sh"
  fi
fi

# ============================================================
# Git init and initial commit
# ============================================================
git init -q
git add -A
git commit -q -m "Initial repo scaffold

Profile: ${PROFILE}
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
if [[ "$PROFILE" != "minimal" ]]; then
  echo "  ./scripts/bootstrap_doc.sh rfc \"my first design\"  # create an RFC"
fi
