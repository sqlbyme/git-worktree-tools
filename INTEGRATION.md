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

### Step 7: Update README.md

Add a section to your project's README.md:

```markdown
## Parallel Development with Git Worktrees

This project supports parallel development using git worktrees, allowing multiple developers and AI assistants to work simultaneously on different features.

### Quick Start

Create a new worktree for your feature:
```bash
./scripts/create-worktree.sh my-feature feature/my-feature-name
```

See [docs/WORKTREE_GUIDE.md](docs/WORKTREE_GUIDE.md) for complete documentation.

### Directory Structure
```
project/                  # Main development (main branch)
project-worktrees/       # Parallel worktrees
├── feature-auth/        # Authentication feature
├── feature-api/         # API improvements
└── bugfix-login/        # Login bug fix
```

Each worktree is a complete, isolated workspace with its own:
- Git branch
- Python virtual environment
- Development server (on unique port)
- Environment configuration
```

### Step 8: Commit the Integration

Commit all the changes:

```bash
git add .gitignore .env.example tox.ini README.md docs/ scripts/
git add .gitmodules tools/  # If using submodules
git commit -m "Add git-worktree-tools for parallel development

- Add git-worktree-tools as submodule
- Update .gitignore for worktree patterns
- Add .env.example template
- Update tox.ini for port configuration
- Add worktree documentation"
```

### Step 9: Test the Integration

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

When starting Claude Code in a worktree, provide this context:

```
Please read docs/CLAUDE_WORKTREE_PROMPT.md and follow those guidelines.

You are working in a git worktree for parallel development.

Worktree location: ../<project>-worktrees/<name>
Branch: <branch-name>
Backend Port: <port> (check .env.local)
Frontend Port: <port> (check .env.local)

Your scope: <describe the specific feature or task>

Before starting:
1. Run git status
2. Check for WORKING.lock files
3. Review recent commits: git log -5 --oneline

Focus on your assigned scope to avoid conflicts.
```

## Next Steps

1. Read [docs/WORKTREE_GUIDE.md](docs/WORKTREE_GUIDE.md) for usage instructions
2. Review [docs/PARALLEL_DEVELOPMENT_EXAMPLES.md](docs/PARALLEL_DEVELOPMENT_EXAMPLES.md) for workflow examples
3. Try creating a worktree and working on a small feature
4. Share the workflow with your team

## Support

For issues with git-worktree-tools, see the [main repository](https://github.com/yourusername/git-worktree-tools).

For project-specific integration issues, consult your team lead or open an issue in your project repository.
