# Git Worktree Tools

A collection of scripts and templates for managing parallel development using git worktrees. This enables multiple AI agents (like Claude Code) to work simultaneously on different tasks without conflicts by providing persistent, isolated workspaces with automatic port management.

## Overview

Git worktrees allow you to have multiple working directories attached to the same repository. This tool provides:

- **Per-agent worktrees**: Each agent gets a persistent workspace in detached HEAD mode
- **Automatic port assignment**: Ports are tracked in `agents.yaml` to prevent conflicts
- **Isolated environments**: Each worktree has its own Python virtual environment
- **Branch-per-task workflow**: Agents create feature branches when given tasks

## Key Concepts

### Per-Agent Model

Unlike traditional per-feature worktrees that are created and destroyed with each task, this tool creates **persistent workspaces per agent**:

1. Create an agent worktree once (e.g., `claude-alpha`)
2. The worktree starts in detached HEAD mode on main
3. When given a task, the agent creates a feature branch
4. After completing work, the agent can take on new tasks
5. The worktree persists across many tasks

### Port Registry

The `agents.yaml` file tracks port assignments for all active agents:

```yaml
agents:
  claude-alpha:
    worktree_path: /path/to/project-worktrees/claude-alpha
    dev_port: 8001
    frontend_port: 3001
    created: 2025-01-15T10:30:00
```

This prevents port conflicts when multiple agents run development servers.

## Quick Start

### Create an Agent Worktree

```bash
./scripts/create-worktree.sh claude-alpha
```

This will:
1. Create a worktree in `../project-worktrees/claude-alpha/`
2. Checkout main in detached HEAD mode
3. Assign unique ports (auto-incremented from 8001/3001)
4. Register the agent in `agents.yaml`
5. Set up Python virtual environment
6. Create `.env.local` with assigned ports

### List Active Agents

```bash
./scripts/list-worktrees.sh
```

Shows all registered agents with their paths and port assignments.

### Remove an Agent Worktree

```bash
./scripts/cleanup-worktree.sh claude-alpha
```

Removes the worktree and frees up the ports for reuse.

## Directory Structure

```
project/                      # Main repo (main branch)
project-worktrees/            # Agent worktrees container
├── agents.yaml               # Port registry (not committed)
├── claude-alpha/             # Agent workspace
├── claude-beta/              # Agent workspace
└── ...
```

## Agent Workflow

1. **Setup**: Create agent worktree (one-time)
   ```bash
   ./scripts/create-worktree.sh my-agent
   cd ../project-worktrees/my-agent
   source .venv/bin/activate
   ```

2. **Start task**: Create a branch for the work
   ```bash
   git checkout -b feature/implement-oauth
   ```

3. **Work**: Make changes, run tests, commit
   ```bash
   # ... make changes ...
   git add .
   git commit -m "feat: implement OAuth flow"
   ```

4. **Complete**: Push and create PR
   ```bash
   git push -u origin feature/implement-oauth
   gh pr create
   ```

5. **Next task**: Return to main and create new branch
   ```bash
   git checkout main
   git pull
   git checkout -b feature/next-task
   ```

## Scripts

- **create-worktree.sh**: Creates a new agent worktree with environment setup and port assignment
- **list-worktrees.sh**: Lists all active agents with their port assignments
- **cleanup-worktree.sh**: Removes an agent worktree and frees its ports

## Use Cases

### Multiple Claude Code Instances

Run multiple AI agents in parallel, each with isolated workspaces:

```bash
# Create agents
./scripts/create-worktree.sh claude-backend
./scripts/create-worktree.sh claude-frontend
./scripts/create-worktree.sh claude-tests

# Each agent works in their own worktree
# Ports auto-assigned: 8001/3001, 8002/3002, 8003/3003
```

### Human + AI Collaboration

Work on critical fixes in main while agents handle other tasks in worktrees.

### Team Development

Multiple developers can have their own persistent worktrees without port conflicts.

## Documentation

- [INTEGRATION.md](./docs/INTEGRATION.md) - Integrate into your project
- [WORKTREE_GUIDE.md](./docs/WORKTREE_GUIDE.md) - Complete user guide
- [CLAUDE_WORKTREE_PROMPT.md](./docs/CLAUDE_WORKTREE_PROMPT.md) - Template for agent context
- [PARALLEL_DEVELOPMENT_EXAMPLES.md](./docs/PARALLEL_DEVELOPMENT_EXAMPLES.md) - Example workflows

## Requirements

- Git 2.5+
- Python 3.8+
- Bash shell (macOS/Linux)

## License

MIT License - see LICENSE file for details

## Contributing

Contributions welcome! Please open an issue or submit a pull request.
