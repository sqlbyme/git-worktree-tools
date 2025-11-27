#!/bin/bash

PROJECT_ROOT=$(git rev-parse --show-toplevel)
WORKTREE_CONTAINER="${PROJECT_ROOT}-worktrees"
AGENTS_YAML="$WORKTREE_CONTAINER/agents.yaml"

echo "Active Agent Worktrees"
echo "======================"
echo ""

if [ -f "$AGENTS_YAML" ]; then
    # Parse agents.yaml and display formatted output
    current_agent=""
    while IFS= read -r line; do
        # Check for agent name (starts with two spaces, ends with colon)
        if [[ $line =~ ^\ \ ([a-zA-Z0-9_-]+):$ ]]; then
            current_agent="${BASH_REMATCH[1]}"
            echo "Agent: $current_agent"
        elif [[ -n "$current_agent" ]]; then
            # Parse properties
            if [[ $line =~ worktree_path:\ (.+) ]]; then
                echo "  Path: ${BASH_REMATCH[1]}"
            elif [[ $line =~ dev_port:\ ([0-9]+) ]]; then
                echo "  Dev Port: ${BASH_REMATCH[1]}"
            elif [[ $line =~ frontend_port:\ ([0-9]+) ]]; then
                echo "  Frontend Port: ${BASH_REMATCH[1]}"
            elif [[ $line =~ created:\ (.+) ]]; then
                echo "  Created: ${BASH_REMATCH[1]}"
                echo ""
                current_agent=""
            fi
        fi
    done < "$AGENTS_YAML"
else
    echo "No agents registered (agents.yaml not found)"
    echo ""
fi

echo "Git Worktrees"
echo "============="
git worktree list

echo ""
echo "Local Branches"
echo "=============="
git branch | grep -v "remotes"
