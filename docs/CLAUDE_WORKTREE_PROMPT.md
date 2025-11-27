# Claude Code Agent Worktree Prompt Template

Copy and customize this when starting Claude Code in an agent worktree:

---

You are working in a persistent agent worktree for parallel development on this project.

## Agent Context
- **Agent Name**: `[AGENT_NAME]`
- **Worktree Location**: `[PATH_TO_WORKTREE]`
- **Dev Port**: `[DEV_PORT]` (from .env.local)
- **Frontend Port**: `[FRONTEND_PORT]` (from .env.local)

## Your Workspace

This is a **persistent worktree** that you will use across multiple tasks. You start in detached HEAD mode on main and create feature branches when given tasks.

## Before Starting Any Task

1. Check your current state:
   ```bash
   git status
   cat .env.local
   ```

2. Update to latest main:
   ```bash
   git fetch origin
   git checkout main
   git reset --hard origin/main
   ```

3. Verify your environment:
   ```bash
   source .venv/bin/activate
   python --version
   ```

## Task Workflow

When given a task:

1. **Create a feature branch:**
   ```bash
   git checkout -b feature/task-description
   ```

2. **Do your work:**
   - Make changes
   - Commit frequently with clear messages
   - Run tests: `tox -e test`
   - Check formatting: `tox -e format-check`

3. **Complete the task:**
   ```bash
   git push -u origin feature/task-description
   gh pr create --title "feat: description" --body "Details"
   ```

4. **Return to main for next task:**
   ```bash
   git checkout main
   git pull
   ```

## Development Commands
- Start backend: `tox -e dev` (uses port from .env.local)
- Run tests: `tox -e test`
- Format code: `tox -e format`
- Lint code: `tox -e lint`
- Type check: `tox -e type`

## Working Guidelines

- Stay focused on the assigned task
- Use your assigned ports (check .env.local)
- Make frequent, small commits with clear messages
- Run tests before pushing
- If you need to modify files outside your task scope, check with the user first

## Completion Checklist

When you've completed your work:
- [ ] All tests passing
- [ ] Code formatted and linted
- [ ] Type checking passes
- [ ] Changes committed with clear messages
- [ ] Branch pushed to origin
- [ ] PR created (if requested)

---

Ready to start! What task would you like me to work on?
