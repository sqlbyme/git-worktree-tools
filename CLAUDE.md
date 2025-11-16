# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Git Worktree Tools is a collection of shell scripts and templates for managing parallel development using git worktrees in Python projects. It enables multiple developers and AI assistants to work simultaneously on different features without conflicts by providing automated worktree creation with isolated Python environments.

## Development Commands

### Testing Scripts
```bash
# Test worktree creation (uses tmp_ prefix)
./scripts/create-worktree.sh tmp-test feature/test-branch main

# List all worktrees
./scripts/list-worktrees.sh

# Clean up test worktree
./scripts/cleanup-worktree.sh tmp-test
```

### Working Guidelines
**IMPORTANT:** ALWAYS:
- Test scripts thoroughly before committing changes
- Use `tmp_` prefix for any temporary test files or worktrees
- Ensure scripts remain POSIX-compliant where possible
- Maintain backward compatibility with existing integrations
- Update relevant documentation when changing scripts

**IMPORTANT:** NEVER:
- Create additional files beyond what was asked
- Add extra features or functionality without approval
- Break existing script functionality
- Commit test worktrees or temporary files
- Make scripts platform-specific without clear justification

### Development Workflow

When working on this project:
1. Create a feature branch following: `type/description` (e.g., `feature/add-git-hooks`, `fix/cleanup-script`)
2. Make changes to scripts or documentation
3. Test changes with actual worktree operations
4. Update relevant documentation if behavior changes
5. Once all edits are complete, stage the files for commit
6. ALWAYS Follow this commit workflow:
   1. Commit staged files
   2. Review changes for shell script best practices
   3. Test scripts manually to ensure they work
   4. If any issues are found, fix those and amend the previous commit
   5. Open a pull request in GitHub

#### Reset Branch
If you're told to "reset branch":
1. Switch to the main branch
2. Fetch from origin and prune remote branches
3. Pull main from origin to get up to date
4. Delete the local working branch

**IMPORTANT:** When deleting local branches, always use `git branch -D` (capital D) if the upstream merge strategy is rebase and merge. Using lowercase `-d` will fail because the branch history has been rewritten.

### Committing Code
**IMPORTANT:** NEVER commit directly to the main branch:
- Main branch is protected and does not allow direct pushes
- All code must go through a pull request and review process
- Even small changes must be committed to a branch and PR'd

**Commit message guidelines:**
- NEVER include any mention of the use of Claude or Anthropic systems
- Keep commit messages concise and focused on what changed and why
- Keep Pull Request summaries concise and focused on what changed
- Never include code snippets in commit or PR messages

### Commit and PR Size Limits
**IMPORTANT:** Keep commits and pull requests small and focused:
- When more than 200 lines of code have changed, it's time to commit and create a PR
- **Target commit size:** Strive for less than 150 lines of code per commit
- Smaller commits are easier to review, test, and debug
- Break large features into multiple smaller PRs when possible

### Code Style and Verbosity
**IMPORTANT:** Keep code and comments minimal and focused:
- Write concise, clear shell scripts that accomplish the required task
- Follow existing code style in the scripts
- Comments should explain why, not what (unless the what is complex)
- Strive for the minimum viable implementation that meets requirements
- Use consistent error handling patterns across scripts

### Pull Requests
When creating pull requests:
- Include what changed and why in PR descriptions
- Test scripts thoroughly before submitting PR
- Document any new script parameters or behaviors
- Update INTEGRATION.md or other docs if user-facing changes

### Temporary Files
Always prefix temporary files with `tmp_` to clearly identify them as safe to remove later. This includes:
- Temporary test scripts
- Temporary test worktrees
- Any files created for debugging or testing purposes

Example: `tmp_test`, `tmp_worktree_auth`, `tmp_test_script.sh`

## Architecture Overview

### Core Components
1. **create-worktree.sh** - Creates new worktrees with complete environment setup
   - Validates parameters and git state
   - Creates worktree directory structure
   - Sets up Python virtual environment
   - Installs dependencies from requirements.txt, pyproject.toml, or setup.py
   - Configures unique development ports
   - Handles frontend dependencies if present

2. **list-worktrees.sh** - Lists all active worktrees and their branches
   - Shows worktree paths and associated branches
   - Helps users track active parallel development

3. **cleanup-worktree.sh** - Removes worktrees and optionally their branches
   - Safely removes worktree directories
   - Optionally deletes associated git branches
   - Validates before deletion

### Directory Structure
```
git-worktree-tools/
├── scripts/           # Core shell scripts
├── templates/         # Configuration templates for integration
├── docs/             # User and developer documentation
├── INTEGRATION.md    # Integration guide for other projects
└── README.md         # Project overview
```

## Important Implementation Notes

### Shell Script Best Practices
- Always use `set -e` to exit on error
- Use `set -u` to catch undefined variables
- Validate all input parameters
- Provide clear error messages
- Use functions for reusable code blocks
- Quote variable expansions to handle spaces in paths
- Use consistent formatting and indentation

### Git Operations
- Always validate git repository state before operations
- Use `git worktree list` to check existing worktrees
- Handle both absolute and relative paths correctly
- Ensure proper cleanup on script failure

### Python Environment Setup
- Support multiple Python dependency formats:
  - requirements.txt (most common)
  - pyproject.toml (modern Python projects)
  - setup.py (legacy projects)
- Always create isolated virtual environments
- Activate venv before installing dependencies
- Handle missing dependency files gracefully

### Port Configuration
- Each worktree needs unique development ports
- Template-based port assignment to avoid conflicts
- Document port ranges in .env.local files
- Support projects without port requirements

### Cross-Platform Considerations
- Primary target: macOS/Linux (Bash)
- Use POSIX-compliant syntax where possible
- Document any platform-specific requirements
- Test on multiple shells if making significant changes

## Documentation Structure

- **README.md** - Project overview and quick start
- **INTEGRATION.md** - How to integrate into other projects
- **docs/WORKTREE_GUIDE.md** - Complete user guide for worktrees
- **docs/CLAUDE_WORKTREE_PROMPT.md** - Template for starting Claude in a worktree
- **docs/PARALLEL_DEVELOPMENT_EXAMPLES.md** - Example workflows and use cases

## Project Status

This project is designed to be integrated into other projects as a git submodule or by copying scripts. When making changes:
- Consider impact on existing integrations
- Maintain backward compatibility when possible
- Document breaking changes clearly
- Update integration instructions if needed
- Test with real-world project integrations when possible

## Integration Points

This tool is designed to integrate with:
- Python projects (any version 3.8+)
- Projects using requirements.txt, pyproject.toml, or setup.py
- Projects with frontend components (npm/yarn)
- Projects using Claude Code or other AI development tools
- Teams practicing parallel development workflows
