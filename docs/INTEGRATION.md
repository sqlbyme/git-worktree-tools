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

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python

# Tox
.tox/
.pytest_cache/

# Environment files
.env
.env.local
.env.*.local

# Development databases
*.db
*.sqlite
*.sqlite3
dev_*.db

# IDE
.vscode/
.idea/
*.swp
*.swo

# Frontend (if applicable)
node_modules/
dist/
build/
.next/
.nuxt/
.cache/

# Logs
*.log
logs/

# OS
.DS_Store
Thumbs.db

# Worktree lock files
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

# Worktree Identification (automatically set by create-worktree.sh)
WORKTREE_NAME=main

# Add your project-specific variables below
# API_KEY=your-api-key-here
# SECRET_KEY=your-secret-key-here
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
    WORKTREE_NAME = {env:WORKTREE_NAME:main}
    PYTHONPATH = {toxinidir}

[testenv:dev]
description = Run development server with hot reload
deps =
    -r requirements.txt
commands =
    # Adjust this command based on your project
    # For FastAPI/uvicorn:
    uvicorn app.main:app --reload --host 0.0.0.0 --port {env:DEV_PORT:8000}
    # For Flask:
    # flask run --host 0.0.0.0 --port {env:DEV_PORT:8000}
    # For Django:
    # python manage.py runserver 0.0.0.0:{env:DEV_PORT:8000}

[testenv:test]
description = Run test suite
deps =
    -r requirements.txt
    pytest
    pytest-cov
    pytest-asyncio
commands =
    pytest {posargs:tests/} -v --cov=app --cov-report=term-missing

[testenv:lint]
description = Run linting checks
deps =
    ruff
commands =
    ruff check {posargs:.}

[testenv:format]
description = Format code
deps =
    ruff
commands =
    ruff format {posargs:.}

[testenv:format-check]
description = Check code formatting without making changes
deps =
    ruff
commands =
    ruff format --check {posargs:.}

[testenv:type]
description = Run type checking
deps =
    -r requirements.txt
    mypy
commands =
    mypy {posargs:app}
```

### Step 6: Copy Documentation to Your Project

Copy the documentation files to your project's docs directory:

```bash
mkdir -p docs
cp tools/worktree/docs/WORKTREE_GUIDE.md docs/
cp tools/worktree/docs/CLAUDE_WORKTREE_PROMPT.md docs/
cp tools/worktree/docs/PARALLEL_DEVELOPMENT_EXAMPLES.md docs/
```

### Step 7: Create .claude.md for Mandatory Worktree Usage

Create a `.claude.md` file in your project root to enforce autonomous worktree usage:

```markdown
# Claude Code Project Configuration

## MANDATORY: Autonomous Worktree-Based Development

This project requires ALL development work to be done in dedicated git worktrees. When given a task, you MUST automatically create and switch to a worktree before making any code changes.

### Workflow for Every Task

When a user gives you a development task (feature, bugfix, refactoring, etc.):

1. **Create a worktree for the task:**
   ```bash
   ./scripts/create-worktree.sh <descriptive-name> <branch-name>
   ```
   - Use descriptive names: `feature-auth`, `bugfix-login`, `refactor-db`, etc.
   - Branch name should follow project conventions (e.g., `feature/authentication`)

2. **Navigate to the worktree:**
   ```bash
   cd ../<project-name>-worktrees/<descriptive-name>
   ```

3. **Verify the environment:**
   ```bash
   pwd
   git status
   git branch
   cat .env.local  # Check your assigned ports
   ```

4. **Check for coordination:**
   ```bash
   # Check what other Claude sessions are working on
   cat WORKING.lock 2>/dev/null || echo "No other active work"
   ```

5. **Do your work** in this worktree following the guidelines in `docs/CLAUDE_WORKTREE_PROMPT.md`

### Mandatory Rules

- ✅ **DO**: Create a new worktree at the start of every task
- ✅ **DO**: Navigate to the worktree before making code changes
- ✅ **DO**: Make all commits from within the worktree
- ✅ **DO**: Use the ports specified in your worktree's `.env.local`
- ✅ **DO**: Stay focused on your assigned task to minimize conflicts
- ❌ **NEVER**: Make code changes in the main project directory
- ❌ **NEVER**: Start coding without creating/switching to a worktree
- ❌ **NEVER**: Share ports with other worktrees

### Exception: Read-Only Operations

You may perform these operations from the project root:
- Reading documentation files
- Listing existing worktrees: `git worktree list`
- Running `./scripts/list-worktrees.sh`
- Answering questions about project structure
- Reading `.claude.md`, `README.md`, etc.

But for ANY code modifications, tests, or running dev servers: **Use a worktree**.

### Worktree Naming Convention

Use clear, descriptive names:
- Features: `feature-<name>` (e.g., `feature-oauth`, `feature-dashboard`)
- Bugfixes: `bugfix-<name>` (e.g., `bugfix-login-error`)
- Refactoring: `refactor-<name>` (e.g., `refactor-database`)
- Testing: `test-<name>` (e.g., `test-payment-flow`)

### After Completing Work

1. Ensure all tests pass
2. Commit your changes
3. Push your branch: `git push -u origin <branch-name>`
4. Navigate back to project root: `cd ../../<project-name>`
5. Let the user know the branch is ready for review
6. The user will handle cleanup with `./scripts/cleanup-worktree.sh`

### Required Reading

Before starting any task, familiarize yourself with:
- `docs/WORKTREE_GUIDE.md` - Complete worktree documentation
- `docs/CLAUDE_WORKTREE_PROMPT.md` - Working guidelines and best practices
- `docs/PARALLEL_DEVELOPMENT_EXAMPLES.md` - Example workflows

### Available Commands

```bash
# Create and setup a new worktree (run from project root)
./scripts/create-worktree.sh <name> <branch>

# List all active worktrees
git worktree list
./scripts/list-worktrees.sh

# Clean up when done (user typically runs this)
./scripts/cleanup-worktree.sh <name>
```

### Multi-Claude Coordination

When multiple Claude Code sessions are running:
- Each creates its own worktree with a unique name
- Each worktree gets unique ports (auto-assigned)
- Check `WORKING.lock` files to see what others are doing
- Coordinate through the user if you need to modify overlapping code

---

**CRITICAL**: You are starting from the project root. Your first action for any coding task must be to create a worktree. Do not make any code changes until you are in a dedicated worktree directory.
```

### Step 8: Update README.md

Add a section to your project's README.md:

```markdown
## Parallel Development with Git Worktrees

This project **requires** git worktrees for all development work. Multiple Claude Code sessions can run in parallel, each automatically creating and managing its own isolated workspace.

### For Claude Code Users

Start Claude Code from the project root and give it tasks as normal:

```bash
cd /path/to/your-project
claude-code
```

Claude will automatically:
1. Create a dedicated worktree for each task
2. Set up isolated Python environments
3. Assign unique development ports
4. Navigate to the worktree and complete the work
5. Return to project root when done

The `.claude.md` file enforces this workflow - Claude cannot make code changes in the main directory.

### For Manual Development

Create a new worktree for your feature:
```bash
./scripts/create-worktree.sh my-feature feature/my-feature-name
cd ../your-project-worktrees/my-feature
```

See [docs/WORKTREE_GUIDE.md](docs/WORKTREE_GUIDE.md) for complete documentation.

### Directory Structure
```
project/                  # Main development (main branch)
project-worktrees/       # Parallel worktrees (auto-created by Claude or manually)
├── feature-auth/        # Authentication feature
├── feature-api/         # API improvements
└── bugfix-login/        # Login bug fix
```

Each worktree is a complete, isolated workspace with its own:
- Git branch
- Python virtual environment
- Development server (on unique port)
- Environment configuration

### Running Multiple Claude Sessions

You can run multiple Claude Code sessions simultaneously from the same project root:

```bash
# Terminal 1
cd /path/to/project
claude-code  # "Please implement OAuth authentication"

# Terminal 2
cd /path/to/project
claude-code  # "Please add tests for the payment module"

# Terminal 3
cd /path/to/project
claude-code  # "Please refactor the database layer"
```

Each Claude session will create its own worktree and work independently without conflicts.
```

### Step 9: Commit the Integration

Commit all the changes:

```bash
git add .gitignore .env.example .claude.md tox.ini README.md docs/ scripts/
git add .gitmodules tools/  # If using submodules
git commit -m "Add git-worktree-tools for parallel development

- Add git-worktree-tools as submodule
- Update .gitignore for worktree patterns
- Add .env.example template
- Create .claude.md to enforce autonomous worktree usage
- Update tox.ini for port configuration
- Add worktree documentation

Claude Code sessions will now automatically create and use
worktrees for all development work."
```

### Step 10: Test the Integration

Test creating a worktree:

```bash
./scripts/create-worktree.sh test-worktree test-branch
```

Verify it was created:

```bash
git worktree list
```

Navigate to it and test:

```bash
cd ../[project-name]-worktrees/test-worktree
source .venv/bin/activate
python --version
```

Clean up the test worktree:

```bash
cd ../../[project-name]
./scripts/cleanup-worktree.sh test-worktree
```

## Project-Specific Customizations

### Adjusting create-worktree.sh

If your project has specific setup requirements, you may need to customize the create-worktree script:

1. **Custom dependency installation:**
   Edit `tools/worktree/scripts/create-worktree.sh` (or your copied version) to add project-specific installation steps.

2. **Database setup:**
   Add database migration commands:
   ```bash
   # After dependency installation, add:
   python manage.py migrate  # Django
   alembic upgrade head      # SQLAlchemy
   ```

3. **Environment variables:**
   Modify the `.env.local` template in the script to include project-specific variables.

4. **Git hooks path:**
   Update the git hooks path if you use shared hooks:
   ```bash
   git config core.hooksPath /path/to/your/hooks
   ```

### Custom Port Ranges

If ports 8000-8003 are already in use, update the default ports in:
- `.env.example` (template defaults)
- `create-worktree.sh` (generated .env.local)
- Your project documentation

### Frontend Projects

If you have a frontend that needs separate port configuration:

1. Update `.env.local` template in `create-worktree.sh`:
   ```bash
   FRONTEND_PORT=3001
   VITE_PORT=5174  # Or whatever your frontend uses
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

### Python virtual environment issues

Make sure your project has one of:
- requirements.txt
- pyproject.toml with [project] section
- setup.py

### Worktree creation fails

Check that:
1. You're in a git repository: `git status`
2. You have a main/master branch
3. The branch name doesn't already exist: `git branch -a`

## Using with Claude Code

Once integrated, Claude Code will **automatically** use worktrees for all development work.

### Starting a Session

Simply start Claude Code from your project root:

```bash
cd /path/to/your-project
claude-code
```

Then give Claude a task as you normally would:

```
"Please implement OAuth authentication for the API"
"Add comprehensive tests for the payment module"
"Refactor the database connection pooling"
```

### What Happens Automatically

Claude will:
1. Read the `.claude.md` configuration file
2. Create a new worktree with a descriptive name
3. Navigate to the worktree directory
4. Set up the isolated environment
5. Check for coordination with other Claude sessions (via WORKING.lock)
6. Complete the development work
7. Run tests and ensure quality
8. Commit changes to the branch
9. Return to the project root

### Running Multiple Sessions in Parallel

You can start multiple Claude Code sessions from the same project root:

```bash
# Terminal 1 - OAuth feature
cd /path/to/project
claude-code  # "Implement OAuth authentication"

# Terminal 2 - Testing
cd /path/to/project
claude-code  # "Add tests for payment module"

# Terminal 3 - Refactoring
cd /path/to/project
claude-code  # "Refactor database layer"
```

Each session will:
- Create its own uniquely-named worktree
- Get assigned unique development ports
- Work independently without conflicts
- Coordinate through WORKING.lock files if needed

### Manual Workflow (Optional)

If you prefer to create worktrees manually before starting Claude:

```bash
./scripts/create-worktree.sh my-feature feature/my-feature
cd ../your-project-worktrees/my-feature
claude-code
```

Then provide context:
```
You are in a git worktree for parallel development.
Please read docs/CLAUDE_WORKTREE_PROMPT.md and work on: <task description>
```

## Next Steps

1. Read [docs/WORKTREE_GUIDE.md](docs/WORKTREE_GUIDE.md) for usage instructions
2. Review [docs/PARALLEL_DEVELOPMENT_EXAMPLES.md](docs/PARALLEL_DEVELOPMENT_EXAMPLES.md) for workflow examples
3. Try creating a worktree and working on a small feature
4. Share the workflow with your team

## Support

For issues with git-worktree-tools, see the [main repository](https://github.com/yourusername/git-worktree-tools).

For project-specific integration issues, consult your team lead or open an issue in your project repository.
