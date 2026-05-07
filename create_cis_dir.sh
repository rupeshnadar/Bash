#!/bin/bash
# ================================================================
# create_cis_dir.sh
# Creates CIS Auditor project skeleton
# Works on: RHEL 7/8/9, CentOS 7/8/9, Ubuntu 18.04/20.04/22.04
# Usage: bash create_cis_auditor.sh
# ================================================================

set -e

# ----------------------------------------------------------
# Configuration
# ----------------------------------------------------------
PROJECT_NAME="cis-ds"
BASE_DIR="${HOME}/Projects"
PROJECT_DIR="${BASE_DIR}/${PROJECT_NAME}"

# ----------------------------------------------------------
# Detect OS for display purposes only
# ----------------------------------------------------------
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "${NAME} ${VERSION_ID}"
    elif [ -f /etc/redhat-release ]; then
        cat /etc/redhat-release
    else
        echo "Linux (unknown)"
    fi
}

OS_DETECTED=$(detect_os)

echo ""
echo "=============================================================="
echo "  CIS Auditor - Project Skeleton"
echo "  Detected OS: ${OS_DETECTED}"
echo "  Location: ${PROJECT_DIR}"
echo "=============================================================="
echo ""

# ----------------------------------------------------------
# Create directory structure (no delete, only create if missing)
# ----------------------------------------------------------
echo "[1/4] Creating directories (missing only)..."

mkdir -p "${PROJECT_DIR}/core"
mkdir -p "${PROJECT_DIR}/cis_plugins"
mkdir -p "${PROJECT_DIR}/reporters"
mkdir -p "${PROJECT_DIR}/utils"
mkdir -p "${PROJECT_DIR}/output/reports"
mkdir -p "${PROJECT_DIR}/output/backups"
mkdir -p "${PROJECT_DIR}/tests"

echo "      Done."
echo ""

# ----------------------------------------------------------
# Create files using touch (only if they don't exist)
# ----------------------------------------------------------
echo "[2/4] Creating files (missing only)..."

# --- Root level files ---
touch "${PROJECT_DIR}/main.py"
touch "${PROJECT_DIR}/build.py"
touch "${PROJECT_DIR}/build.spec"
touch "${PROJECT_DIR}/requirements.txt"
touch "${PROJECT_DIR}/setup_build_env.sh"
touch "${PROJECT_DIR}/README.md"
touch "${PROJECT_DIR}/.gitignore"

# --- core/ ---
touch "${PROJECT_DIR}/core/__init__.py"
touch "${PROJECT_DIR}/core/engine.py"

# --- cis_plugins/ ---
touch "${PROJECT_DIR}/cis_plugins/__init__.py"
touch "${PROJECT_DIR}/cis_plugins/plugins.py"

# --- reporters/ ---
touch "${PROJECT_DIR}/reporters/__init__.py"
touch "${PROJECT_DIR}/reporters/writer.py"

# --- utils/ ---
touch "${PROJECT_DIR}/utils/__init__.py"
touch "${PROJECT_DIR}/utils/helpers.py"

# --- tests/ ---
touch "${PROJECT_DIR}/tests/__init__.py"
touch "${PROJECT_DIR}/tests/test_plugins.py"

echo "      Done."
echo ""

# ----------------------------------------------------------
# Set permissions (on all files/dirs, existing or new)
# ----------------------------------------------------------
echo "[3/4] Setting permissions..."

# Directories: 755 (rwxr-xr-x)
find "${PROJECT_DIR}" -type d -exec chmod 755 {} \;

# Python files: 644 (rw-r--r--)
find "${PROJECT_DIR}" -name "*.py" -exec chmod 644 {} \;

# Shell scripts: 755 (rwxr-xr-x)
find "${PROJECT_DIR}" -name "*.sh" -exec chmod 755 {} \;

# Build spec, requirements, text files: 644
find "${PROJECT_DIR}" -name "*.spec" -exec chmod 644 {} \;
find "${PROJECT_DIR}" -name "*.txt" -exec chmod 644 {} \;
find "${PROJECT_DIR}" -name "*.md" -exec chmod 644 {} \;
find "${PROJECT_DIR}" -name ".gitignore" -exec chmod 644 {} \;

# output/ directory: 755
chmod 755 "${PROJECT_DIR}/output"
chmod 755 "${PROJECT_DIR}/output/reports"
chmod 755 "${PROJECT_DIR}/output/backups"

echo "      Done."
echo ""

# ----------------------------------------------------------
# Create .gitignore (only if it doesn't exist or is empty)
# ----------------------------------------------------------
echo "[4/4] Creating .gitignore (if empty or missing)..."

GITIGNORE="${PROJECT_DIR}/.gitignore"

if [ ! -s "${GITIGNORE}" ]; then
    cat > "${GITIGNORE}" << 'EOF'
# Bytecode
__pycache__/
*.py[cod]
*$py.class

# Build artifacts
build/
dist/
*.spec.bak

# Output (generated at runtime)
output/reports/*
output/backups/*
!output/reports/.gitkeep
!output/backups/.gitkeep

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Virtual environment
venv/
env/
.venv/

# PyInstaller
*.manifest
EOF
    echo "      Created."
else
    echo "      Already exists, keeping existing."
fi

# ----------------------------------------------------------
# Display final structure
# ----------------------------------------------------------
echo ""
echo "=============================================================="
echo "  PROJECT SKELETON READY"
echo "=============================================================="
echo ""
echo "  ${PROJECT_DIR}/"
echo "  ├── main.py"
echo "  ├── build.py"
echo "  ├── build.spec"
echo "  ├── requirements.txt"
echo "  ├── setup_build_env.sh"
echo "  ├── README.md"
echo "  ├── .gitignore"
echo "  │"
echo "  ├── core/"
echo "  │   ├── __init__.py"
echo "  │   └── engine.py"
echo "  │"
echo "  ├── cis_plugins/"
echo "  │   ├── __init__.py"
echo "  │   └── plugins.py"
echo "  │"
echo "  ├── reporters/"
echo "  │   ├── __init__.py"
echo "  │   └── writer.py"
echo "  │"
echo "  ├── utils/"
echo "  │   ├── __init__.py"
echo "  │   └── helpers.py"
echo "  │"
echo "  ├── output/"
echo "  │   ├── reports/
echo "  │   └── backups/
echo "  │"
echo "  └── tests/"
echo "      ├── __init__.py"
echo "      └── test_plugins.py"
echo ""
echo "  Permissions:"
echo "    Directories:   755 (rwxr-xr-x)"
echo "    Python files:  644 (rw-r--r--)"
echo "    Shell scripts: 755 (rwxr-xr-x)"
echo ""
echo "  NEXT: Populate source files with code"
echo "=============================================================="
