# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

[PROJECT_NAME] is a [brief description of what the project does and its main purpose].

## Development Commands

### Environment Setup
```bash
# Add your environment setup commands here
# Examples:
# python -m venv .venv
# source .venv/bin/activate
# pip install -r requirements.txt
# npm install
```

### Testing and Linting
**IMPORTANT:** Always run tests and linting before committing:

```bash
# Add your testing commands here
# Examples:
# pytest
# npm test
# tox -e py312
# tox -e lint
```

### Working Guidelines
**IMPORTANT:** ALWAYS:
- [Add project-specific requirements]
- Use `tmp_` prefix for any temporary test files
- [Add any other important guidelines]

**IMPORTANT:** NEVER:
- Create additional files beyond what was asked
- Add extra features or functionality without approval
- Make suggestions and then implement them without approval
- Continue working on related tasks without being asked
- [Add any other project-specific restrictions]

### Development Workflow

When working on this project:
1. [Describe your workflow - e.g., ticket systems, branch naming]
2. Make the changes required to complete the work
3. Once all edits are complete, stage the files for commit
4. ALWAYS Follow this commit workflow:
   1. Commit staged files
   2. Run linting: [your lint command]
   3. Run tests: [your test command]
   4. If any issues are found, fix those and amend the previous commit
   5. [Add any additional steps - code review, etc.]
   6. Open a pull request in GitHub

#### Reset Branch
If you're told to "reset branch":
1. [Optional: Comment in the current ticket with a link to the merge commit for the PR]
2. [Optional: Mark the current ticket as Done]
3. Switch to the main branch
4. Fetch from origin and prune remote branches
5. Pull main from origin to get up to date
6. Delete the local working branch

**IMPORTANT:** When deleting local branches, always use `git branch -D` (capital D) if the upstream merge strategy is rebase and merge. Using lowercase `-d` will fail because the branch history has been rewritten.

### Branch Naming Convention
Branch naming should follow: `type/description` or `type/ticket/description`
- Types: `feature`, `fix`, `task`, `docs`, `refactor`
- Examples: `feature/user-auth`, `fix/login-bug`, `task/SQL-123/update-deps`

### Git Worktrees for Parallel Development (Optional)

[If your project supports git worktrees, include this section. Otherwise remove it.]

This project supports git worktrees for parallel development. Use worktrees when:
- You need to work on multiple features simultaneously
- Testing or experimenting without disrupting the main workspace
- User explicitly requests parallel development
- Working on urgent fixes while other work is in progress

**Available Commands:**
```bash
./scripts/create-worktree.sh <name> <branch> [base]  # Create new worktree
./scripts/list-worktrees.sh                           # List all worktrees
./scripts/cleanup-worktree.sh <name>                  # Remove worktree
```

**Documentation:**
- Complete guide: `docs/WORKTREE_GUIDE.md`
- Claude prompts: `docs/CLAUDE_WORKTREE_PROMPT.md`
- Examples: `docs/PARALLEL_DEVELOPMENT_EXAMPLES.md`

### Committing Code
**IMPORTANT:** NEVER commit directly to the main branch:
- Main branch is protected and does not allow direct pushes
- All code must go through a pull request and review process
- Even small changes must be committed to a branch and PR'd

**Commit message guidelines:**
- NEVER include any mention of the use of Claude or Anthropic systems
- NEVER include test status in commit messages (e.g., "All tests passing")
- Keep commit messages concise and focused on what changed and why
- Keep Pull Request summaries concise and focused on what changed
- Never include code snippets in commit or PR messages

### Commit and PR Size Limits
**IMPORTANT:** Keep commits and pull requests small and focused:
- When more than 350 lines of code have changed, it's time to commit and create a PR
- **Maximum PR size:** 400 lines of code
- **Target commit size:** Strive for less than 250 lines of code per commit
- Smaller commits are easier to review, test, and debug
- Break large features into multiple smaller PRs when possible

### Code Style and Verbosity
**IMPORTANT:** Keep code and comments minimal and focused:
- Write concise, clear code that accomplishes the required task with minimal additions
- Avoid verbose or overly detailed comments - code should be self-documenting when possible
- Strive for the minimum viable implementation that meets requirements
- [Add any project-specific style guidelines]

### Pull Requests
When creating pull requests:
- [Customize based on your PR requirements]
- Do not include "Test plan" or "Testing" sections in PR descriptions (optional)
- Keep PR descriptions focused on what changed and why
- **ALWAYS run code-review before opening a PR** (optional)

### Temporary Files
Always prefix temporary files with `tmp_` to clearly identify them as safe to remove later. This includes:
- Temporary scripts for analysis or testing
- Temporary data files
- Any files created for debugging or exploration purposes

Example: `tmp_test_script.py`, `tmp_test_data.json`

## Architecture Overview

### Core Components
[Describe your main components/modules]
1. **[Component 1]** (`path/to/file.py`) - [description]
2. **[Component 2]** (`path/to/file.py`) - [description]

### [Processing Flow / Request Flow / Data Flow]
1. [Step 1]
2. [Step 2]
3. [Step 3]

## Important Implementation Notes

### [Technology/Framework Specific Guidelines]
- [Add important implementation details]
- [Configuration requirements]
- [Best practices for this project]

### [API Integration / Database / External Services]
- [Document any external integrations]
- [Authentication requirements]
- [Rate limits or quotas]

### Environment Variables
List all environment variables used in the project:
- `VARIABLE_NAME`: Description (default: value)
- `ANOTHER_VAR`: Description (default: value)

### [Logging / Error Handling / Security]
- [Document logging strategy]
- [Error handling patterns]
- [Security considerations]

## Project Status

[Describe the current state of the project]
- [What's implemented]
- [What's in progress]
- [What's planned]

## [Additional Sections as Needed]

Add any project-specific sections that would help Claude understand:
- Deployment procedures
- Database migrations
- API documentation
- Common troubleshooting steps
- Links to external documentation
