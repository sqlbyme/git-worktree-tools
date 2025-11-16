# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Mail-Agent is an LLM-powered email management system that interfaces with Gmail and Google Calendar APIs using a local Qwen2.5-3B-Instruct model for intelligent email classification and task extraction.

## Development Commands

### Environment Setup
```bash
python -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate
pip install -r requirements.txt
```

### Testing and Linting
**IMPORTANT:** Always use tox for running tests and linting to maintain consistency:

```bash
./.venv/bin/tox -e py312      # Run all tests
./.venv/bin/tox -e coverage   # Run tests with coverage
./.venv/bin/tox -e lint       # Run linting checks
./.venv/bin/tox -e format     # Auto-format code
./.venv/bin/pytest tests/test_classifier.py  # Run specific test file
```

### Working Guidelines
**IMPORTANT:** ALWAYS:
- Plan work first and record plan in the linear ticket, as a comment to the ticket
- You may use markdown text to format the comment you add to Linear
- Once the plan is added, STOP and ask me to review your plan and approve it or update it

**IMPORTANT:** NEVER:
- Create additional files beyond what was asked
- Add extra features or functionality
- Make suggestions and then implement them without approval
- Continue working on related tasks without being asked

### Development Workflow with Linear
**Linear Project Configuration:**
- Linear ticket prefix: `SQL-`
- All tickets for this project will have IDs like: `SQL-1`, `SQL-2`, etc.

When working on a Linear ticket:
1. Read the Linear ticket with the ID provided
2. Mark the ticket as "In Progress"
3. Checkout a new git branch following these rules:
   - Branch naming must follow: `type/ticket/quick-description`
   - Types are: `feature`, `fix`, `task`
   - Ticket refers to the Linear ticket ID (e.g., `SQL-1`)
4. Make the changes required to complete the work
5. Once all edits are complete, stage the files for commit
6. ALWAYS Follow this commit workflow:
   1. Commit staged files
   2. Run linting: `./.venv/bin/tox -e lint`
   3. Run tests: `./.venv/bin/tox -e py312`
   4. If any issues are found, fix those and amend the previous commit
   5. Run code review using the code-reviewer agent
   6. Fix any critical issues the agent suggests
   7. If non-critical issues remain, use the EPM agent to create new Linear tickets
   8. Open a pull request in GitHub

#### Reset Branch
If you're told to "reset branch":
1. Comment in the current Linear ticket with a link to the merge commit for the PR
2. Mark the current ticket as Done
3. Switch to the main branch
4. Fetch from origin and prune remote branches
5. Pull main from origin to get up to date
6. Delete the local working branch

**IMPORTANT:** When deleting local branches, always use `git branch -D` (capital D) because the upstream merge strategy is rebase and merge. Using lowercase `-d` will fail because the branch history has been rewritten.

### Git Worktrees for Parallel Development

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

**When Working in a Worktree:**
1. Each worktree has its own `.venv` - activate it with `source .venv/bin/activate`
2. Each worktree has its own `.env.local` - check and adjust ports to avoid conflicts
3. Stay focused on your worktree's scope to minimize merge conflicts
4. All worktrees share the same git repository - commits are immediately visible everywhere
5. Before starting work, check for `WORKING.lock` files that indicate others are working on shared code

**Important Notes:**
- Worktrees are created in `../mail-agent-worktrees/` directory (sibling to main project)
- Each worktree gets isolated Python environment and unique development ports
- Use `git worktree list` to see all active worktrees
- Clean up worktrees after merging to keep workspace tidy

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
- NEVER include test status in commit messages (e.g., "All tests passing", "157 tests pass")
- Keep commit messages concise and focused on what changed and why
- Keep Pull Request summaries concise and focused on what changed
- Never include code snippets or anything specific in commit or PR messages

### Commit and PR Size Limits
**IMPORTANT:** Keep commits and pull requests small and focused:
- When more than 350 lines of code have changed, it's time to:
  1. Commit the current changes
  2. Run linting and formatting (`./.venv/bin/tox -e lint`)
  3. Run tests (`./.venv/bin/tox -e py312`)
  4. Review the code
  5. Push up a PR to rebase and merge
- **Maximum PR size:** 400 lines of code
- **Target commit size:** Strive for less than 250 lines of code per commit
- Smaller commits are easier to review, test, and debug
- Break large features into multiple smaller PRs when possible

### Code Style and Verbosity
**IMPORTANT:** Keep code and comments minimal and focused:
- Write concise, clear code that accomplishes the required task with minimal additions
- Avoid verbose or overly detailed comments - code should be self-documenting when possible
- Strive for the minimum viable implementation that meets requirements

### Pull Requests
When creating pull requests:
- Do not include "Test plan" or "Testing" sections in PR descriptions
- Keep PR descriptions focused on what changed and why
- **ALWAYS run code-review before opening a PR** (unless the PR contains ONLY documentation changes)
  - Use the code-reviewer agent to review changes before creating the PR
  - Address any critical issues identified before opening the PR
  - For documentation-only PRs, code review is optional but recommended

### Addressing PR Comments
When addressing review comments left on a pull request, follow this workflow:

1. **Fetch the PR comments** to see what needs to be addressed:
```bash
gh api repos/sqlbyme/mail-agent/pulls/<pr number>/comments
```

2. **Review each comment** and understand what changes are requested

3. **Make the code changes** to address each comment:
   - Use Edit tool to modify the relevant files
   - Address each comment one at a time
   - Keep changes focused and minimal

4. **Run linting** to ensure code style is correct:
```bash
./.venv/bin/tox -e lint
```

5. **Run tests** to ensure nothing broke:
```bash
./.venv/bin/tox -e py312
```

6. **Commit the changes** with a descriptive message:
```bash
git add -A
git commit -m "Address PR review feedback

- Fix issue 1 description
- Fix issue 2 description
- Fix issue 3 description"
```

7. **Push the changes**:
```bash
git push
```

8. **Resolve the review threads**:

   First, get the review thread IDs:
   ```bash
   gh api graphql -f query='
   {
     repository(owner: "sqlbyme", name: "mail-agent") {
       pullRequest(number: PR_NUMBER) {
         reviewThreads(first: 10) {
           nodes {
             id
             isResolved
             comments(first: 1) {
               nodes {
                 databaseId
                 body
               }
             }
           }
         }
       }
     }
   }
   '
   ```

   Then resolve each thread using its thread ID:
   ```bash
   gh api graphql -f query='
   mutation {
     resolveReviewThread(input: {threadId: "THREAD_ID"}) {
       thread {
         isResolved
       }
     }
   }
   '
   ```

   Replace `PR_NUMBER` with the actual PR number and `THREAD_ID` with each thread ID from the first command.

### Temporary Files
Always prefix temporary files with `tmp_` to clearly identify them as safe to remove later. This includes:
- Temporary scripts for analysis or testing
- Temporary data files
- Any files created for debugging or exploration purposes

Example: `tmp_examine_email.py`, `tmp_test_data.json`

## Architecture Overview

### Core Processing Flow
1. **Gmail Client** (`src/gmail/client.py`) fetches emails via Gmail API
2. **Rule Engine** (`src/rules/rule_engine.py`) applies user-defined rules from `src/rules/rules.json`
3. **Classifier** (`src/agent/classifier.py`) uses LLM to categorize emails into 4 buckets:
   - Action Required (urgent, needs response)
   - Read Now (relevant, not urgent)
   - Read Later (low priority, batchable)
   - Archive/Delete (non-essential)
4. **Summarizer** (`src/agent/summarizer.py`) generates concise email summaries
5. **Calendar Client** (`src/calendar/client.py`) creates TODO entries for action items
6. **Email Agent** (`src/agent/email_agent.py`) orchestrates the entire workflow

## Important Implementation Notes

### Logging
Always implement logging consistently across all Python modules:
- Use the centralized logger module from `src/utils/logger.py`
- Import logger using: `from src.utils.logger import get_logger` and `logger = get_logger(__name__)`
- Use appropriate log levels:
  - `logger.debug()` for detailed debugging information
  - `logger.info()` for general informational messages
  - `logger.warning()` for warning messages
  - `logger.error()` for error messages
- Never use `print()` for application logging - only use `print()` for user-facing output
- Never log sensitive email content or credentials
- Logging can be configured via environment variables:
  - `LOG_LEVEL`: Set logging level (DEBUG, INFO, WARNING, ERROR, CRITICAL)
  - `LOG_FILE`: Set log file path for file-based logging

### Google API Integration
- OAuth 2.0 tokens stored in `config/` (gitignored)
- Credentials file: `config/credentials.json` (must be downloaded from Google Cloud Console)
- Gmail API quota: 1 billion units/day - implement exponential backoff for rate limits
- Use batch requests where possible for efficiency

### LLM Integration
- Uses locally hosted Qwen2.5-3B-Instruct model via OpenAI-compatible API
- Production and Development deployments should set custom endpoint (e.g., `http://k3s.rwc.feco.net:8090/v1/chat/completions`) (configure via `LLM_ENDPOINT` env var)
- Prompt templates stored in `src/utils/prompts.py`
- Only send email content to API when classification requires semantic analysis
- Email content is never logged or persisted beyond necessary caching

### Rule System
- Rules defined in `src/rules/rules.json` (gitignored, user-specific)
- Rule structure: conditions (from, subject_contains, from_domain, has_label) + action + priority
- Rules evaluated in priority order before LLM classification

### Environment Variables
- `LLM_ENDPOINT`: LLM API endpoint URL (default: http://localhost:8090/v1/chat/completions)
- `LLM_MODEL`: LLM model identifier (default: Qwen2.5-3B-Instruct)
- `LLM_TIMEOUT`: LLM request timeout in seconds (default: 10)
- `LLM_MAX_RETRIES`: Maximum retry attempts for LLM requests (default: 1)
- `GMAIL_BATCH_SIZE`: Emails per batch (default: 50)
- `LOG_LEVEL`: Logging verbosity (default: INFO)
- `LOG_FILE`: Path to log file (optional)
- `DRY_RUN`: Run without making actual changes (default: false)
- `APPLY_LABELS`: Apply labels to emails after classification (default: true)

## Project Status

This is a new project. The README describes the planned architecture. Current implementation status:
- Phase 1: Basic Gmail integration, rule-based classification, LLM integration in progress
- Phase 2: Calendar integration, task extraction (planned)
- Phase 3: Advanced features like multi-account support (future)

When implementing new modules, follow the structure outlined in README.md and maintain separation of concerns between Gmail/Calendar clients, rule processing, and LLM-based classification.
