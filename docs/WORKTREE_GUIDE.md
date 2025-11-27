# Git Worktree Workflow Guide

## Quick Start

### Creating an Agent Worktree

```bash
./scripts/create-worktree.sh <agent-name> [base-branch]
```

Example:
```bash
./scripts/create-worktree.sh claude-alpha main
```

This will:
1. Create a new worktree in `../<project>-worktrees/claude-alpha/`
2. Checkout in detached HEAD mode at `main`
3. Auto-assign unique ports (tracked in `agents.yaml`)
4. Set up a fresh virtual environment
5. Install all dependencies
6. Create a `.env.local` file with assigned ports

### Working in an Agent Worktree

1. Navigate to the worktree:
   ```bash
   cd ../<project>-worktrees/claude-alpha
   ```

2. Activate the virtual environment:
   ```bash
   source .venv/bin/activate
   ```

3. When given a task, create a feature branch:
   ```bash
   git checkout -b feature/my-task
   ```

4. Check your assigned ports in `.env.local`:
   ```bash
   cat .env.local
   ```

5. Start development:
   ```bash
   tox -e dev
   ```

### Port Assignments

Ports are automatically assigned and tracked in `agents.yaml`:

| Agent | Dev Port | Frontend Port |
|-------|----------|---------------|
| main  | 8000     | 3000          |
| agent-1 | 8001   | 3001          |
| agent-2 | 8002   | 3002          |
| agent-3 | 8003   | 3003          |

The `create-worktree.sh` script automatically finds the next available ports.

### Listing Active Agents

```bash
./scripts/list-worktrees.sh
```

This shows:
- All registered agents with their port assignments
- Git worktree status
- Local branches

### Starting a New Task

When you receive a new task in your agent worktree:

1. Make sure you're on the latest main:
   ```bash
   git checkout main
   git pull origin main
   ```

2. Create a branch for the task:
   ```bash
   git checkout -b feature/implement-oauth
   ```

3. Do your work, committing frequently:
   ```bash
   git add .
   git commit -m "feat: add OAuth configuration"
   ```

### Completing Work

When your work is complete:

1. Ensure all tests pass:
   ```bash
   tox -e test,lint,type
   ```

2. Push your branch:
   ```bash
   git push -u origin feature/implement-oauth
   ```

3. Create a pull request:
   ```bash
   gh pr create --title "feat: implement OAuth" --body "Description of changes"
   ```

4. Return to main for the next task:
   ```bash
   git checkout main
   git pull
   ```

### Removing an Agent Worktree

When an agent is no longer needed:

```bash
cd ../../<project>
./scripts/cleanup-worktree.sh claude-alpha
```

This removes the worktree and frees up the ports for reuse.

## Best Practices

1. **One agent per worktree**: Each worktree is dedicated to a single agent
2. **One task at a time**: Complete and push work before starting new tasks
3. **Clear naming**: Use descriptive agent names like `claude-backend`, `claude-frontend`
4. **Regular commits**: Commit frequently within your task branch
5. **Clean branches**: Delete merged branches to keep the repo tidy
6. **Use assigned ports**: Always use the ports in your `.env.local`

## Troubleshooting

### Port already in use
Check which agent has the port:
```bash
./scripts/list-worktrees.sh
```

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
Recreate the virtual environment:
```bash
cd <worktree-path>
rm -rf .venv
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### Detached HEAD state
This is expected! Create a branch when starting a task:
```bash
git checkout -b feature/my-task
```

## Advanced Usage

### Updating main in your worktree
```bash
git fetch origin
git checkout main
git reset --hard origin/main
```

### Sharing work between worktrees
All worktrees share the same git repository, so:
- Commits in one worktree are immediately visible in others
- You can cherry-pick commits between worktrees
- Branches are shared across all worktrees

### Using with git hooks
If you have shared git hooks configured, they're automatically applied to new worktrees. The create-worktree script checks for hooks at `/Users/medwards/Documents/git-hooks/python-tox`.

### Database isolation
Each agent gets its own SQLite database by default (configured in `.env.local`). This prevents conflicts when running migrations or tests.
