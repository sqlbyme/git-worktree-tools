#!/bin/bash
set -e

# Usage: ./scripts/create-worktree.sh <worktree-name> [branch-name] [base-branch]

WORKTREE_NAME=$1
BRANCH_NAME=${2:-$WORKTREE_NAME}
BASE_BRANCH=${3:-main}

if [ -z "$WORKTREE_NAME" ]; then
    echo "Usage: $0 <worktree-name> [branch-name] [base-branch]"
    echo "Example: $0 feature-auth feature/auth-endpoints main"
    exit 1
fi

# Get project paths
PROJECT_ROOT=$(git rev-parse --show-toplevel)
PROJECT_NAME=$(basename "$PROJECT_ROOT")
WORKTREE_CONTAINER="${PROJECT_ROOT}-worktrees"
WORKTREE_PATH="$WORKTREE_CONTAINER/$WORKTREE_NAME"

# Ensure worktree container exists
mkdir -p "$WORKTREE_CONTAINER"

# Create worktree with new branch
echo "Creating worktree at: $WORKTREE_PATH"
git worktree add "$WORKTREE_PATH" -b "$BRANCH_NAME" "$BASE_BRANCH"

# Configure shared hooks path if it exists
if [ -d "/Users/medwards/Documents/git-hooks/python-tox" ]; then
    echo "Configuring shared git hooks..."
    cd "$WORKTREE_PATH"
    git config core.hooksPath /Users/medwards/Documents/git-hooks/python-tox
    cd "$PROJECT_ROOT"
fi

# Setup Python venv
echo "Setting up Python virtual environment..."
cd "$WORKTREE_PATH"
python3 -m venv .venv
source .venv/bin/activate

# Install dependencies (checks multiple possible configurations)
if [ -f "requirements.txt" ]; then
    echo "Installing from requirements.txt..."
    pip install -r requirements.txt
elif [ -f "pyproject.toml" ]; then
    echo "Installing from pyproject.toml..."
    pip install -e ".[dev]"
elif [ -f "setup.py" ]; then
    echo "Installing from setup.py..."
    pip install -e ".[dev]"
fi

# Install tox if needed
if command -v tox &> /dev/null; then
    pip install tox
fi

# Setup npm dependencies if frontend exists
if [ -f "package.json" ]; then
    echo "Installing npm dependencies..."
    npm install
fi

# Create environment configuration
cat > .env.local <<EOF
# Worktree-specific environment variables
WORKTREE_NAME=$WORKTREE_NAME
DEV_PORT=8000
FRONTEND_PORT=3000
DATABASE_URL=sqlite:///./dev_${WORKTREE_NAME}.db

# Adjust ports to avoid conflicts (you may need to manually set these)
# DEV_PORT=8001
# FRONTEND_PORT=3001
EOF

echo ""
echo "✓ Worktree created successfully!"
echo "  Path: $WORKTREE_PATH"
echo "  Branch: $BRANCH_NAME"
echo ""
echo "To start working:"
echo "  cd $WORKTREE_PATH"
echo "  source .venv/bin/activate"
echo ""
echo "Remember to adjust ports in .env.local to avoid conflicts!"
