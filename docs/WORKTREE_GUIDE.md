# Git Worktree Workflow Guide

## Quick Start

### Creating a New Worktree

```bash
./scripts/create-worktree.sh <worktree-name> [branch-name]
```

Example:
```bash
./scripts/create-worktree.sh feature-auth feature/auth-endpoints
```

This will:
1. Create a new worktree in `../<project>-worktrees/feature-auth/`
2. Create and checkout branch `feature/auth-endpoints`
3. Set up a fresh virtual environment
4. Install all dependencies
5. Create a `.env.local` file

### Working in a Worktree

1. Navigate to the worktree:
   ```bash
   cd ../<project>-worktrees/feature-auth
   ```

2. Activate the virtual environment:
   ```bash
   source .venv/bin/activate
   ```

3. Check the assigned port in `.env.local` and adjust if needed

4. Start development:
   ```bash
   tox -e dev
   ```

### Port Assignments

To avoid conflicts, each worktree should use different ports:

| Worktree | Backend Port | Frontend Port |
|----------|-------------|---------------|
| main     | 8000        | 3000          |
| worktree-1 | 8001      | 3001          |
| worktree-2 | 8002      | 3002          |
| worktree-3 | 8003      | 3003          |

Edit `.env.local` in each worktree to set unique ports.

### Coordination with Claude Code

When starting Claude Code in a worktree, provide this context:

```
You are working in a git worktree for parallel development.

Worktree location: ../<project>-worktrees/<name>
Branch: <branch-name>
Ports: Backend=<port>, Frontend=<port>

Scope: <describe specific feature/area>

Before starting work:
1. Run: git status
2. Check for WORKING.lock file
3. Review recent commits: git log -5 --oneline

Focus on the specified scope to avoid conflicts with other parallel work.
```

### Merging Back to Main

When your work is complete:

1. Ensure all tests pass:
   ```bash
   tox -e test,lint,type
   ```

2. Commit your changes:
   ```bash
   git add .
   git commit -m "feat: your feature description"
   ```

3. Push your branch:
   ```bash
   git push -u origin <branch-name>
   ```

4. Create a pull request on GitHub:
   ```bash
   gh pr create --title "Your feature title" --body "Description"
   ```

5. After merging, clean up the worktree:
   ```bash
   cd ../../<project>
   ./scripts/cleanup-worktree.sh <worktree-name>
   ```

### Listing Active Worktrees

```bash
./scripts/list-worktrees.sh
```

Or directly:
```bash
git worktree list
```

### Best Practices

1. **One feature per worktree**: Keep worktrees focused on a single feature or task
2. **Clear naming**: Use descriptive worktree names like `feature-auth`, `bugfix-login`, `refactor-api`
3. **Regular commits**: Commit frequently in your worktree branch
4. **Avoid conflicts**: Coordinate with other developers/Claude instances on what files you're modifying
5. **Clean up**: Remove worktrees after merging to keep things tidy
6. **Lock file**: Create a `WORKING.lock` file with your name/task when starting work on shared areas

## Troubleshooting

### Port already in use
Edit `.env.local` in your worktree and change the port numbers.

### Worktree won't remove
```bash
git worktree remove --force <worktree-path>
```

### Lost track of worktrees
```bash
git worktree list
git worktree prune  # Clean up deleted worktrees
```

### Virtual environment issues
If the virtual environment is corrupted, you can recreate it:
```bash
cd <worktree-path>
rm -rf .venv
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### Branch already exists
If creating a worktree fails because the branch exists:
```bash
# Delete the existing branch first
git branch -D <branch-name>
# Then try creating the worktree again
```

## Advanced Usage

### Creating a worktree from a remote branch
```bash
git fetch origin
./scripts/create-worktree.sh my-worktree origin/feature-branch
```

### Sharing work between worktrees
All worktrees share the same git repository, so:
- Commits in one worktree are immediately visible in others
- You can switch between worktrees and see all branches
- Stashing works across worktrees

### Using with git hooks
If you have shared git hooks configured, they'll automatically be applied to new worktrees. The create-worktree script checks for hooks at `/Users/medwards/Documents/git-hooks/python-tox`.

### Database isolation
Each worktree gets its own SQLite database by default (configured in `.env.local`). This prevents conflicts when running migrations or tests.
