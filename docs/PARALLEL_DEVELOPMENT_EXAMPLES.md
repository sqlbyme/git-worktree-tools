# Parallel Development Examples

## Scenario 1: Human + One Claude Instance

**Human (main worktree):**
```bash
cd ~/projects/myapp
source .venv/bin/activate
export DEV_PORT=8000
tox -e dev
# Working on frontend refinements
```

**Claude Code (worktree):**
```bash
./scripts/create-worktree.sh claude-tests feature/add-test-coverage
cd ../myapp-worktrees/claude-tests
source .venv/bin/activate
# Prompt: "Add comprehensive test coverage for the API endpoints"
```

## Scenario 2: Multiple Claude Instances

**Claude Instance 1 - Backend:**
```bash
./scripts/create-worktree.sh claude-backend feature/auth-api
# Scope: Implement OAuth authentication endpoints
# Port: 8001
```

**Claude Instance 2 - Frontend:**
```bash
./scripts/create-worktree.sh claude-frontend feature/login-ui
# Scope: Build login/signup UI components
# Port: 8002 (backend), 3001 (frontend)
```

**Claude Instance 3 - Documentation:**
```bash
./scripts/create-worktree.sh claude-docs feature/api-docs
# Scope: Add OpenAPI documentation and usage examples
# Port: 8003
```

## Scenario 3: Team Development

**Developer A (main):**
- Working on critical bug fixes
- Port 8000

**Developer B (worktree):**
- Refactoring database layer
- Port 8001

**Claude Code 1 (worktree):**
- Writing integration tests
- Port 8002

**Claude Code 2 (worktree):**
- Updating API documentation
- Port 8003

## Scenario 4: Feature Development Pipeline

**Phase 1 - Design (Claude in worktree-design):**
```bash
./scripts/create-worktree.sh design feature/payment-design
# Task: Create database models and API design for payment system
```

**Phase 2 - Implementation (Claude in worktree-impl):**
```bash
./scripts/create-worktree.sh impl feature/payment-impl
# Task: Implement payment endpoints and business logic
# Can reference design worktree for context
```

**Phase 3 - Testing (Claude in worktree-test):**
```bash
./scripts/create-worktree.sh test feature/payment-tests
# Task: Add comprehensive tests for payment system
# Can reference impl worktree for latest code
```

**Phase 4 - Documentation (Human in main):**
```bash
# Review all three worktrees and write final documentation
```

## Scenario 5: Experimentation and Comparison

**Approach A - ORM Implementation:**
```bash
./scripts/create-worktree.sh experiment-orm feature/payment-orm
# Implement payment system using SQLAlchemy ORM
```

**Approach B - Raw SQL Implementation:**
```bash
./scripts/create-worktree.sh experiment-sql feature/payment-sql
# Implement same feature using raw SQL queries
```

**Comparison:**
- Run benchmarks in both worktrees
- Compare code complexity
- Choose the best approach and merge
- Clean up the rejected worktree

## Scenario 6: Coordinating Work with Lock Files

Create a `WORKING.lock` file in areas where coordination is needed:

```bash
# In main project - Developer A starts work
cd backend/payment
echo "Developer A - Refactoring payment module - ETA 2 hours" > WORKING.lock
git add WORKING.lock
git commit -m "Lock payment module for refactoring"
git push
```

**Claude instances can check for these files:**
```bash
# In worktree
find . -name "WORKING.lock" -exec cat {} \;
```

**Output:**
```
Developer A - Refactoring payment module - ETA 2 hours
```

Claude then knows to avoid modifying payment module files.

## Scenario 7: Continuous Integration

**Main worktree:**
- Always kept in working state
- Only merged code that passes all tests
- CI/CD runs from main

**Feature worktrees:**
- Can be in broken state during development
- Run tests locally before merging
- Clean up after merge

```bash
# In feature worktree
tox -e test,lint,type
git push
gh pr create

# After PR is merged and CI passes
cd ../../myapp
./scripts/cleanup-worktree.sh feature-name
```

## Scenario 8: Hotfix While Feature Development Continues

**Issue:** Critical bug in production needs immediate fix

**Main worktree (Human):**
```bash
cd ~/projects/myapp
git checkout main
git pull
./scripts/create-worktree.sh hotfix-login bugfix/login-timeout
cd ../myapp-worktrees/hotfix-login

# Fix the bug
# Test thoroughly
# Commit and push
# Create PR with high priority
```

**Feature worktrees (Claude instances):**
- Continue working on features uninterrupted
- Merge main into feature branches after hotfix is deployed
```bash
# In feature worktree
git fetch origin
git merge origin/main
```

## Best Practices from Examples

1. **Naming Convention:**
   - Use descriptive prefixes: `feature-`, `bugfix-`, `experiment-`, `claude-`
   - Include feature name: `feature-auth`, `bugfix-login`

2. **Port Management:**
   - Document port assignments
   - Use sequential ports: 8000, 8001, 8002...
   - Check `.env.local` before starting servers

3. **Communication:**
   - Use WORKING.lock files for coordination
   - Commit frequently to share progress
   - Document scope clearly in worktree creation

4. **Cleanup:**
   - Remove worktrees after merging
   - Don't let abandoned worktrees accumulate
   - Use `git worktree prune` periodically

5. **Testing:**
   - Each worktree can run tests independently
   - Use unique database names to avoid conflicts
   - Run full test suite before merging
