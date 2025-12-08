# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Claude Code plugin marketplace containing four plugins:

1. **conversation-logger**: Automatically logs conversations to local files with rotation (Windows-only, PowerShell 5.1+)
2. **useful-commands**: Slash commands for PR management (Azure DevOps & GitHub) and session documentation, with integrated MCP servers
3. **security-agent**: Custom agent for code vulnerability detection and security audits
4. **senior-reviewer**: Custom agent for senior-level code reviews focusing on quality, optimizations, and best practices

## Installation

```bash
# Register the marketplace (auto-installs plugins)
/plugin marketplace add practia-ia/claude_code_plugins

# Enable plugins
/plugin enable conversation-logger@practia-ia
/plugin enable useful-commands@practia-ia
/plugin enable security-agent@practia-ia
/plugin enable senior-reviewer@practia-ia
```

Requires Claude Code version 1.0.40+ (plugin support).

## Repository Structure

```
.claude-plugin/marketplace.json    # Marketplace definition (owner, plugins list)
conversation-logger/
├── .claude-plugin/plugin.json     # Plugin metadata
├── hooks/
│   ├── hooks.json                 # Hook event definitions
│   └── log-conversation.ps1       # PowerShell logging script
└── README.md
useful-commands/
├── .claude-plugin/plugin.json     # Plugin metadata
├── .mcp.json                       # MCP server configuration (Azure DevOps + GitHub)
├── commands/                      # Slash commands (auto-discovered by Claude Code)
│   ├── adr.md                     # /adr - Create Architecture Decision Records
│   ├── create-pr.md               # /create-pr - Azure DevOps PR creation
│   ├── create-pr-gh.md            # /create-pr-gh - GitHub PR creation
│   ├── document.md                # /document - Session documentation
│   ├── update-pr.md               # /update-pr - Update Azure DevOps PR
│   └── update-pr-gh.md            # /update-pr-gh - Update GitHub PR
└── README.md
security-agent/
├── .claude-plugin/plugin.json     # Plugin metadata
├── agents/
│   └── security-review.md         # security-review agent definition
└── README.md
senior-reviewer/
├── .claude-plugin/plugin.json     # Plugin metadata
├── agents/
│   └── senior-code-review.md      # senior-code-review agent definition
└── README.md
```

## Architecture

### Plugin System

Claude Code discovers plugins through `marketplace.json`, which references plugin directories containing `.claude-plugin/plugin.json` metadata files. Plugins can provide:

- **Hooks**: Event-driven command execution (conversation-logger)
- **Slash Commands**: User-invocable commands in `.md` files (useful-commands)
- **MCP Servers**: External tool integrations via Model Context Protocol (useful-commands)
- **Agents**: Specialized AI agents for delegated tasks (security-agent, senior-reviewer)

### conversation-logger Plugin

#### Hook Event System

Registers hooks for three Claude Code events (defined in `hooks/hooks.json`):

| Event              | Trigger                               | Timeout |
| ------------------ | ------------------------------------- | ------- |
| `UserPromptSubmit` | User sends a message                  | 10s     |
| `PostToolUse`      | Any tool completes (wildcard matcher) | 10s     |
| `Stop`             | Assistant response completes          | 15s     |

All hooks execute the same PowerShell script (`log-conversation.ps1`) with different JSON input via stdin.

#### Hook Input JSON Schema

Claude Code passes JSON with these fields:

- `session_id`: Unique session identifier
- `hook_event_name`: Event type (`UserPromptSubmit`, `PostToolUse`, `Stop`)
- `prompt`: User message (UserPromptSubmit only)
- `tool_name`, `tool_input`: Tool details (PostToolUse only)
- `transcript_path`: Path to NDJSON transcript file (Stop only)
- `cwd`: Current working directory

#### Logging Behavior

- **Location**: `.claude/logs/conversation-YYYYMMDD.log` (project-relative)
- **Rotation**: At 512 KB, renamed to `conversation-YYYYMMDD-HHmmss.log`
- **Tool Input Summarization** (prevents log bloat):
  - Read/Write/Edit: File path only
  - Bash: First 200 chars of command
  - Grep/Glob: Pattern only
  - Task: Description only
  - Other tools: JSON input (max 300 chars)
- **Response Logging**: Parses NDJSON transcript from end, collects assistant text blocks, truncates at 2000 chars

### useful-commands Plugin

#### Slash Commands Architecture

Commands are markdown files in `commands/` with YAML frontmatter:

```markdown
---
description: Brief description shown in /help
---

# Command Title

Detailed instructions for Claude Code to execute when command is invoked...
```

Claude Code auto-discovers these files and makes them available as `/command-name`.

#### MCP Server Integration

`.mcp.json` configures two MCP servers:

1. **azure-devops**: Node.js-based (`npx @azure-devops/mcp`)
   - Requires: `AZURE_DEVOPS_ORG` environment variable
   - Provides tools for repos, PRs, work items, pipelines, wikis, test plans, search, advanced security
   - Optional: Use `-d` flag to limit domains (see useful-commands/README.md)

2. **github**: Docker-based (`ghcr.io/github/github-mcp-server`)
   - Requires: `GITHUB_PERSONAL_ACCESS_TOKEN` environment variable
   - Provides tools for repos, PRs, issues, branches, commits, GitHub Actions
   - Requires Docker daemon running

#### Slash Command Workflows

**PR Creation Commands** (`/create-pr`, `/create-pr-gh`):
1. Verify git status (check for uncommitted changes)
2. Analyze commits: `git log origin/main..HEAD --oneline`
3. Analyze changes: `git diff --stat origin/main...HEAD`
4. Extract work item/issue references from commits
5. Generate detailed PR description with summary, changes by category, file stats, test plan
6. Create PR using MCP tools with auto-generated title/description
7. Link work items (Azure DevOps) or issues (GitHub)

**PR Update Commands** (`/update-pr`, `/update-pr-gh`):
- Similar workflow to creation, but updates existing PR
- Preserves existing images in description

**ADR Command** (`/adr`):
1. Ensure `/docs/adrs` directory exists
2. List existing ADRs, calculate next number (0001, 0002, etc.)
3. Prompt user for title, context, decision, consequences
4. Create `NNNN-title-in-kebab-case.md` with standard ADR template

**Document Command** (`/document`):
1. Analyze conversation history
2. Generate session summary: tasks completed, problems solved, files modified, commands executed
3. Save to `/docs/logs/session_YYYY-MM-DD_HH-MM-SS.md`

## Environment Variables

Configure in `.claude/settings.json` or system environment:

### Azure DevOps Commands
```bash
AZURE_DEVOPS_ORG=your-org           # Organization name (required)
AZURE_DEVOPS_PROJECT=your-project   # Project name (required)
AZURE_DEVOPS_REPO=your-repo         # Repository name (optional, auto-detected from git remote)
```

### GitHub Commands
```bash
GITHUB_PERSONAL_ACCESS_TOKEN=ghp_xxx  # PAT with 'repo' scope (required)
```

## Key Implementation Details

### Hook Variable Expansion

`${CLAUDE_PLUGIN_ROOT}` in `hooks.json` is expanded by Claude Code to the plugin's absolute path. This allows portable hook command definitions:

```json
"command": "powershell -ExecutionPolicy Bypass -File \"${CLAUDE_PLUGIN_ROOT}/hooks/log-conversation.ps1\""
```

### NDJSON Transcript Parsing

The `Stop` hook parses `.claude/transcripts/*.ndjson` files (newline-delimited JSON). Each line is a JSON object with `type` field (`user` or `assistant`). Assistant messages contain `message.content[]` arrays with `{type: "text", text: "..."}` objects.

### Tool Input Summarization Strategy

The logging script uses a switch statement to handle different tool types, extracting only relevant fields to prevent massive logs from tools with large inputs (e.g., Write tool with entire file contents).

### Slash Command Prompt Expansion

When a user types `/create-pr`, Claude Code:
1. Reads `commands/create-pr.md`
2. Expands the markdown content as a prompt to Claude
3. Claude executes the instructions in the expanded prompt
4. User sees results of Claude following those instructions

This allows plugin authors to write instructions for Claude rather than implementing command logic directly.

### security-agent Plugin

#### Agent Architecture

Agents are markdown files in `agents/` with YAML frontmatter defining their capabilities:

```markdown
---
name: agent-name
description: When and why to use this agent (include "Use proactively" for auto-invocation)
tools: Read, Grep, Glob, Bash
model: sonnet
---

# Agent system prompt and instructions...
```

Claude Code auto-discovers agent files and makes them available via the `/agents` interface.

#### security-review Agent

Specialized agent for code security audits with expertise in:

**Vulnerability Detection:**
- OWASP Top 10 vulnerabilities (SQL injection, XSS, authentication issues, etc.)
- Hardcoded secrets and credentials
- Insecure cryptography
- Input validation gaps
- Authorization bypass vectors

**Analysis Process:**
1. Scope identification (prioritize auth, data handling, user input)
2. Automated pattern searching (grep for common vulnerabilities)
3. Code review following security checklist
4. Compliance verification (error handling, logging, dependencies)

**Reporting:**
- Severity classification (Critical/High/Medium/Low)
- Structured reports with location, vulnerable code, impact, remediation
- CWE references when applicable
- Best practice explanations

**Invocation:**
- Manual: `/agents` → select `security-review`
- Direct mention: `@security-review audit authentication files`
- Auto-invocation: When working with authentication, user input, or sensitive data

**Tools Available:**
- Read: Examine source files
- Grep: Search for vulnerability patterns
- Glob: Find sensitive files
- Bash: Execute security analysis tools

The agent balances security with usability, providing actionable remediation steps and explaining the rationale behind each recommendation.

### senior-reviewer Plugin

#### Agent Architecture

Uses the same agent structure as security-agent: markdown files in `agents/` with YAML frontmatter.

#### senior-code-review Agent

Senior software engineer (15+ years experience) specialized in comprehensive code reviews:

**Review Dimensions:**
- **Architecture & Design**: Component boundaries, coupling/cohesion, design patterns, SOLID principles
- **Code Quality**: Readability, naming, function size, DRY/KISS/YAGNI, code smells
- **Performance**: Algorithm complexity, optimization opportunities, resource management, caching
- **Best Practices**: Error handling, testing, documentation, technical debt
- **Maintainability**: Organization, structure, future-proofing

**Multi-Language Expertise:**
- JavaScript/TypeScript (React hooks, async/await, bundle size)
- Python (PEP 8, comprehensions, generators, type hints)
- Java (Stream API, Optional, concurrency)
- C# (LINQ, async patterns, nullable types)
- Go (goroutines, channels, error handling)
- Rust (ownership, lifetimes, zero-cost abstractions)

**Review Process:**
1. Understand context and purpose
2. Multi-layer analysis (architecture, quality, performance, patterns)
3. Detect code smells and anti-patterns
4. Prioritized feedback (Critical/High/Medium/Low)
5. Provide before/after code examples
6. Educational insights and learning opportunities

**Feedback Structure:**
- Summary of changes
- Strengths (positive reinforcement)
- Issues by priority with location, impact, recommendation
- Architecture observations
- Performance considerations
- Learning opportunities with resources

**Common Detections:**
- Long functions (>50 lines), God objects, long parameter lists
- Code duplication, primitive obsession, feature envy
- N+1 queries, missing indexes, memory leaks
- Synchronous operations that should be async
- Missing caching, inefficient algorithms

**Invocation:**
- Manual: `/agents` → select `senior-code-review`
- Direct: `@senior-code-review review my changes before PR`
- Auto: When reviewing code, implementing features, or before PRs

**Communication Principles:**
- Constructive (focus on code, not person)
- Explains "why" behind suggestions
- Provides concrete examples
- Prioritizes high-impact improvements
- Encourages discussion (suggestions, not mandates)

The agent mentors developers while improving code quality, balancing pragmatism with best practices.
