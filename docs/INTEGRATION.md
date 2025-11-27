# Git Worktree Tools Integration Guide

This document provides step-by-step instructions for integrating git-worktree-tools into your Python project. You can provide this document to Claude Code or follow it manually.

## Prerequisites

- Python 3.8 or higher
- Git 2.5 or higher
- Your project uses one of: requirements.txt, pyproject.toml, or setup.py
- (Optional) tox for testing and automation

## Integration Steps

### Step 1: Add git-worktree-tools as a Submodule

Run from your project root:

```bash
git submodule add https://github.com/yourusername/git-worktree-tools.git tools/worktree
git submodule update --init --recursive
```

If you prefer not to use submodules, you can clone it locally and copy the scripts:

```bash
# Option B: Manual copy (if not using submodules)
git clone https://github.com/yourusername/git-worktree-tools.git /tmp/git-worktree-tools
cp -r /tmp/git-worktree-tools/scripts ./scripts
chmod +x ./scripts/*.sh
```

### Step 2: Create Symlinks to Scripts (for submodule approach)

From your project root:

```bash
mkdir -p scripts
ln -s ../tools/worktree/scripts/create-worktree.sh scripts/create-worktree.sh
ln -s ../tools/worktree/scripts/list-worktrees.sh scripts/list-worktrees.sh
ln -s ../tools/worktree/scripts/cleanup-worktree.sh scripts/cleanup-worktree.sh
```

### Step 3: Update .gitignore

Add these patterns to your `.gitignore` file:

```gitignore
# Virtual environments
venv/
env/
.venv/

# Environment files
.env
.env.local
.env.*.local

# Development databases
*.db
*.sqlite
*.sqlite3
dev_*.db

# Agent registry (local state)
agents.yaml

# Worktree coordination files
WORKING.lock
```

### Step 4: Create .env.example Template

Create a `.env.example` file in your project root:

```bash
# Server Configuration
DEV_PORT=8000
FRONTEND_PORT=3000

# Database
DATABASE_URL=sqlite:///./dev.db

# Application Settings
DEBUG=True
ENVIRONMENT=development

# Agent Identification (automatically set by create-worktree.sh)
AGENT_NAME=main

# Add your project-specific variables below
```

### Step 5: Update tox.ini (if using tox)

Add or update your `tox.ini` to support environment variables:

```ini
[tox]
envlist = py311,lint,type,test
skipsdist = False

[testenv]
description = Base environment configuration
setenv =
    AGENT_NAME = {env:AGENT_NAME:main}
    PYTHONPATH = {toxinidir}

[testenv:dev]
description = Run development server with hot reload
deps =
    -r requirements.txt
commands =
    uvicorn app.main:app --reload --host 0.0.0.0 --port {env:DEV_PORT:8000}

[testenv:test]
description = Run test suite
deps =
    -r requirements.txt
    pytest
    pytest-cov
commands =
    pytest {posargs:tests/} -v --cov=app --cov-report=term-missing
```

### Step 6: Copy Documentation to Your Project

Copy the documentation files to your project's docs directory:

```bash
mkdir -p docs
cp tools/worktree/docs/WORKTREE_GUIDE.md docs/
cp tools/worktree/docs/CLAUDE_WORKTREE_PROMPT.md docs/
cp tools/worktree/docs/PARALLEL_DEVELOPMENT_EXAMPLES.md docs/
```

### Step 7: Create .claude.md for Agent-Based Worktree Usage

Create a `.claude.md` file in your project root to configure agent behavior:

```markdown
# Claude Code Project Configuration

## Agent Worktree Model

This project uses persistent agent worktrees. Each Claude Code instance should have its own dedicated worktree created before starting work.

### Setting Up Your Agent Worktree

Before starting any development task, ensure you have an agent worktree:

1. **Check if you're in a worktree:**
   ```bash
   git worktree list
   cat .env.local  # Should show AGENT_NAME
   ```

2. **If not in a worktree, ask the user to create one:**
   ```bash
   ./scripts/create-worktree.sh <agent-name>
   ```

### Working on Tasks

When given a development task:

1. **Ensure you're on latest main:**
   ```bash
   git checkout main
   git pull origin main
   ```

2. **Create a branch for the task:**
   ```bash
   git checkout -b feature/task-description
   ```

3. **Do your work** following the project guidelines

4. **Complete the task:**
   ```bash
   git push -u origin feature/task-description
   gh pr create
   ```

5. **Return to main for next task:**
   ```bash
   git checkout main
   ```

### Rules

- ✅ **DO**: Work in your assigned agent worktree
- ✅ **DO**: Create a new branch for each task
- ✅ **DO**: Use ports from your `.env.local`
- ✅ **DO**: Push branches and create PRs when work is complete
- ❌ **NEVER**: Modify the main branch directly
- ❌ **NEVER**: Use ports assigned to other agents

### Port Management

Ports are auto-assigned when the worktree is created and tracked in `agents.yaml`. Check your assigned ports:
```bash
cat .env.local
```

### Available Commands

```bash
# List all agents and their ports (run from project root)
./scripts/list-worktrees.sh

# Create new agent worktree (run from project root)
./scripts/create-worktree.sh <agent-name>

# Remove agent worktree (run from project root)
./scripts/cleanup-worktree.sh <agent-name>
```
```

### Step 8: Update README.md

Add a section to your project's README.md:

```markdown
## Parallel Development with Git Worktrees

This project uses persistent agent worktrees for parallel development. Each Claude Code instance or developer gets their own isolated workspace with automatically assigned ports.

### For Claude Code Users

1. Have the user create an agent worktree:
   ```bash
   ./scripts/create-worktree.sh claude-alpha
   ```

2. Start Claude Code in the worktree:
   ```bash
   cd ../your-project-worktrees/claude-alpha
   claude-code
   ```

3. The agent will create feature branches for each task

### Directory Structure
```
project/                      # Main repo
project-worktrees/            # Agent worktrees
├── agents.yaml               # Port registry
├── claude-alpha/             # Agent workspace (ports 8001/3001)
├── claude-beta/              # Agent workspace (ports 8002/3002)
└── ...
```

### Running Multiple Agents

```bash
# Create multiple agent worktrees
./scripts/create-worktree.sh claude-backend
./scripts/create-worktree.sh claude-frontend
./scripts/create-worktree.sh claude-tests

# Each gets unique ports automatically
./scripts/list-worktrees.sh
```

See [docs/WORKTREE_GUIDE.md](docs/WORKTREE_GUIDE.md) for complete documentation.
```

### Step 9: Commit the Integration

Commit all the changes:

```bash
git add .gitignore .env.example .claude.md tox.ini README.md docs/ scripts/
git add .gitmodules tools/  # If using submodules
git commit -m "Add git-worktree-tools for parallel agent development

- Add git-worktree-tools as submodule
- Update .gitignore for agent registry
- Add .env.example template
- Create .claude.md for agent workflow
- Update tox.ini for port configuration
- Add worktree documentation"
```

### Step 10: Test the Integration

Test creating an agent worktree:

```bash
./scripts/create-worktree.sh tmp-test
```

Verify it was created:

```bash
git worktree list
./scripts/list-worktrees.sh
```

Navigate to it and test:

```bash
cd ../[project-name]-worktrees/tmp-test
source .venv/bin/activate
cat .env.local  # Check assigned ports
```

Clean up the test worktree:

```bash
cd ../../[project-name]
./scripts/cleanup-worktree.sh tmp-test
```

## Project-Specific Customizations

### Adjusting create-worktree.sh

If your project has specific setup requirements, customize the script:

1. **Custom dependency installation:**
   Add project-specific installation steps after the standard dependency installation.

2. **Database setup:**
   Add database migration commands:
   ```bash
   python manage.py migrate  # Django
   alembic upgrade head      # SQLAlchemy
   ```

3. **Environment variables:**
   Modify the `.env.local` template to include project-specific variables.

### Custom Port Ranges

If ports 8001+ are already in use, modify the `get_next_available_port` function in `create-worktree.sh` to start from a different base port.

### Frontend Projects

If you have a frontend that needs separate port configuration:

1. Update `.env.local` template in `create-worktree.sh`:
   ```bash
   VITE_PORT=$((FRONTEND_PORT + 100))
   ```

2. Update frontend start command to use the environment variable.

## Troubleshooting Integration

### Scripts not executable

```bash
chmod +x scripts/*.sh
```

### Submodule not updating

```bash
git submodule update --init --recursive
git submodule update --remote
```

### agents.yaml not found

The file is created automatically when you create your first agent worktree:
```bash
./scripts/create-worktree.sh my-first-agent
```

### Port conflicts

Check the registry and adjust if needed:
```bash
./scripts/list-worktrees.sh
cat ../[project]-worktrees/agents.yaml
```

## Using with Claude Code

Once integrated, create agent worktrees before starting Claude Code sessions.

### Recommended Setup

1. Create agent worktrees for each Claude instance:
   ```bash
   ./scripts/create-worktree.sh claude-1
   ./scripts/create-worktree.sh claude-2
   ```

2. Start Claude in each worktree:
   ```bash
   # Terminal 1
   cd ../project-worktrees/claude-1
   claude-code

   # Terminal 2
   cd ../project-worktrees/claude-2
   claude-code
   ```

3. Give each agent their task. They'll create branches and work independently.

### Agent Workflow

Each agent will:
1. Start in detached HEAD mode on main
2. Create a feature branch when given a task
3. Work on the task
4. Push and create a PR
5. Return to main for the next task

The worktree persists across tasks, so agents don't need to recreate their environment.

## Next Steps

1. Read [docs/WORKTREE_GUIDE.md](docs/WORKTREE_GUIDE.md) for usage instructions
2. Review [docs/PARALLEL_DEVELOPMENT_EXAMPLES.md](docs/PARALLEL_DEVELOPMENT_EXAMPLES.md) for workflow examples
3. Create your first agent worktree
4. Share the workflow with your team
