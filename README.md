# Git Worktree Tools

A collection of scripts and templates for managing parallel development using git worktrees in Python projects. This enables multiple developers and AI assistants to work simultaneously on different features without conflicts.

## Overview

Git worktrees allow you to have multiple working directories attached to the same repository, each checked out to a different branch. This tool provides:

- Automated worktree creation with isolated Python environments
- Easy cleanup and management of worktrees
- Configuration templates for Python projects
- Documentation templates for teams using Claude Code or other AI assistants

## Features

- **Automated Setup**: Creates worktrees with complete Python virtual environments
- **Dependency Management**: Automatically installs dependencies from requirements.txt, pyproject.toml, or setup.py
- **Port Isolation**: Each worktree gets unique development ports to avoid conflicts
- **Git Hooks Support**: Optionally integrates with shared git hooks
- **Frontend Support**: Handles npm/yarn dependencies if present
- **Easy Cleanup**: Simple scripts to remove worktrees and branches when done

## Quick Start

### As a Git Submodule

1. Add to your project:
```bash
git submodule add https://github.com/yourusername/git-worktree-tools.git tools/worktree
git submodule update --init --recursive
```

2. Follow the integration instructions in [INTEGRATION.md](./INTEGRATION.md)

### Standalone Usage

1. Clone this repository:
```bash
git clone https://github.com/yourusername/git-worktree-tools.git
cd git-worktree-tools
```

2. Copy scripts to your project:
```bash
cp -r scripts /path/to/your/project/
chmod +x /path/to/your/project/scripts/*.sh
```

## Scripts

- **create-worktree.sh**: Creates a new worktree with complete environment setup
- **list-worktrees.sh**: Lists all active worktrees and branches
- **cleanup-worktree.sh**: Removes a worktree and optionally its branch

## Documentation

- [INTEGRATION.md](./INTEGRATION.md) - Step-by-step guide for integrating into your project
- [WORKTREE_GUIDE.md](./docs/WORKTREE_GUIDE.md) - Complete user guide for working with worktrees
- [CLAUDE_WORKTREE_PROMPT.md](./docs/CLAUDE_WORKTREE_PROMPT.md) - Template for starting Claude Code in a worktree
- [PARALLEL_DEVELOPMENT_EXAMPLES.md](./docs/PARALLEL_DEVELOPMENT_EXAMPLES.md) - Example workflows

## Requirements

- Git 2.5+
- Python 3.8+
- Bash shell (macOS/Linux)

## Directory Structure After Integration

```
your-project/                  # Main development (main branch)
your-project-worktrees/        # Parallel worktrees
├── feature-auth/              # Authentication feature
├── feature-api/               # API improvements
└── bugfix-login/              # Login bug fix
```

Each worktree is a complete, isolated workspace with:
- Its own git branch
- Dedicated Python virtual environment
- Unique development server ports
- Separate environment configuration

## Use Cases

### Multiple Claude Code Instances
Run multiple AI assistants in parallel, each working on different features:
- Claude 1: Backend API development
- Claude 2: Frontend UI components
- Claude 3: Test coverage and documentation

### Human + AI Collaboration
Work on critical fixes while Claude handles refactoring or testing in a separate worktree.

### Team Development
Multiple developers can work on different features without stepping on each other's toes.

## License

MIT License - see LICENSE file for details

## Contributing

Contributions welcome! Please open an issue or submit a pull request.

## Support

For issues or questions, please file a GitHub issue.
