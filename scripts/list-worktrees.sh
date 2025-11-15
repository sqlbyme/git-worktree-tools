#!/bin/bash

echo "Active Git Worktrees:"
echo "===================="
git worktree list

echo ""
echo "Branches:"
echo "========="
git branch -a | grep -v "remotes"
