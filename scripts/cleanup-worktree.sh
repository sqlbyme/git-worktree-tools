#!/bin/bash
set -e

WORKTREE_NAME=$1

if [ -z "$WORKTREE_NAME" ]; then
    echo "Usage: $0 <worktree-name>"
    echo ""
    echo "Available worktrees:"
    git worktree list
    exit 1
fi

PROJECT_ROOT=$(git rev-parse --show-toplevel)
WORKTREE_CONTAINER="${PROJECT_ROOT}-worktrees"
WORKTREE_PATH="$WORKTREE_CONTAINER/$WORKTREE_NAME"

if [ ! -d "$WORKTREE_PATH" ]; then
    echo "Worktree not found: $WORKTREE_PATH"
    exit 1
fi

# Get the branch name
cd "$WORKTREE_PATH"
BRANCH_NAME=$(git branch --show-current)
cd "$PROJECT_ROOT"

read -p "Remove worktree '$WORKTREE_NAME' (branch: $BRANCH_NAME)? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    git worktree remove "$WORKTREE_PATH"
    echo "Worktree removed: $WORKTREE_PATH"

    read -p "Delete branch '$BRANCH_NAME'? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git branch -d "$BRANCH_NAME" || git branch -D "$BRANCH_NAME"
        echo "Branch deleted: $BRANCH_NAME"
    fi
fi
