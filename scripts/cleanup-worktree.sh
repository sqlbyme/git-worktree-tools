#!/bin/bash
set -e

AGENT_NAME=$1

PROJECT_ROOT=$(git rev-parse --show-toplevel)
WORKTREE_CONTAINER="${PROJECT_ROOT}-worktrees"
WORKTREE_PATH="$WORKTREE_CONTAINER/$AGENT_NAME"
AGENTS_YAML="$WORKTREE_CONTAINER/agents.yaml"

if [ -z "$AGENT_NAME" ]; then
    echo "Usage: $0 <agent-name>"
    echo ""
    echo "Available agents:"
    if [ -f "$AGENTS_YAML" ]; then
        grep -E "^  [a-zA-Z]" "$AGENTS_YAML" | sed 's/://' | sed 's/^  /  - /'
    else
        echo "  No agents registered"
    fi
    echo ""
    echo "All worktrees:"
    git worktree list
    exit 1
fi

if [ ! -d "$WORKTREE_PATH" ]; then
    echo "Agent worktree not found: $WORKTREE_PATH"
    exit 1
fi

# Show agent info before removal
echo "Agent: $AGENT_NAME"
echo "Path: $WORKTREE_PATH"
if [ -f "$AGENTS_YAML" ]; then
    DEV_PORT=$(grep -A3 "^  $AGENT_NAME:" "$AGENTS_YAML" | grep "dev_port:" | awk '{print $2}')
    FRONTEND_PORT=$(grep -A3 "^  $AGENT_NAME:" "$AGENTS_YAML" | grep "frontend_port:" | awk '{print $2}')
    echo "Dev Port: $DEV_PORT"
    echo "Frontend Port: $FRONTEND_PORT"
fi
echo ""

read -p "Remove agent worktree '$AGENT_NAME'? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Remove the worktree (force needed because of venv and other generated files)
    git worktree remove --force "$WORKTREE_PATH"
    echo "Worktree removed: $WORKTREE_PATH"

    # Remove agent from agents.yaml
    if [ -f "$AGENTS_YAML" ]; then
        # Create temp file without this agent's entry
        # This removes the agent name line and all indented lines that follow until the next agent
        awk -v agent="  $AGENT_NAME:" '
            $0 == agent { skip = 1; next }
            /^  [a-zA-Z]/ { skip = 0 }
            !skip { print }
        ' "$AGENTS_YAML" > "$AGENTS_YAML.tmp"
        mv "$AGENTS_YAML.tmp" "$AGENTS_YAML"
        echo "Agent removed from registry: $AGENT_NAME"

        # Remove agents.yaml if no agents remain
        if ! grep -q "^  [a-zA-Z]" "$AGENTS_YAML" 2>/dev/null; then
            rm "$AGENTS_YAML"
            echo "Registry file removed (no remaining agents)"
        fi
    fi
fi
