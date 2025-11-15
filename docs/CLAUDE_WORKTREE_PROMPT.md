# Claude Code Worktree Prompt Template

Copy and customize this when starting Claude Code in a worktree:

---

You are working in a git worktree for parallel development on this project.

## Worktree Context
- **Location**: `[PATH_TO_WORKTREE]`
- **Branch**: `[BRANCH_NAME]`
- **Backend Port**: `[PORT_NUMBER]` (set in .env.local)
- **Frontend Port**: `[PORT_NUMBER]` (set in .env.local)

## Your Scope
[Describe the specific feature, refactoring, or task this worktree is focused on]

Examples:
- Implement OAuth authentication endpoints
- Refactor database models for better performance
- Build new dashboard UI component
- Add comprehensive test coverage for payment module

## Before You Start
1. Check git status: `git status`
2. Check for WORKING.lock file - if it exists, read it to understand what others are working on
3. Review recent work: `git log -5 --oneline`
4. Verify your environment: `source .venv/bin/activate && python --version`

## Working Guidelines
- Stay focused on your assigned scope to minimize conflicts
- Make frequent, small commits with clear messages
- Run tests before committing: `tox -e test`
- Check code formatting: `tox -e format-check`
- If you need to modify files outside your scope, check with the user first

## Development Commands
- Start backend: `tox -e dev` (uses port from .env.local)
- Run tests: `tox -e test`
- Format code: `tox -e format`
- Lint code: `tox -e lint`
- Type check: `tox -e type`

## Project Structure
[Add brief overview of relevant project structure]

## Completion Checklist
When you've completed your work:
- [ ] All tests passing
- [ ] Code formatted and linted
- [ ] Type checking passes
- [ ] Changes committed with clear messages
- [ ] No merge conflicts with main branch
- [ ] Documentation updated if needed

Ready to start! What would you like to work on first?
