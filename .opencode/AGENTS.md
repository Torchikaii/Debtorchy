# AI Agent Rules - Debtorchy

## Project Overview

- **Project name:** `Debtorchy`
- **Core purpose:** Personal utility toolkit consolidating scripts and configurations for daily development workflows. Enables quick environment reconstruction, workflow automation, and knowledge preservation across machines.
- **Target users:** Solo developer / power user working with Ubuntu, Windows, Altium Designer, and AI-assisted development tools.

---

## Core Principles

1. **Ask questions instead of assuming** — When unclear about requirements, ask before implementing
2. **Verify before acting** — Read existing code before making changes, understand the codebase first
3. **Keep it simple** — Prefer simple solutions; avoid over-engineering small tools
4. **Document decisions** — Explain why you made certain choices
5. **Test thoroughly** — Verify changes work and don't break existing functionality
6. **Maintain idempotency** — Scripts must be safe to re-run; no errors on repeated execution
7. **One thing well** — Each utility/script should do one thing; don't bundle unrelated functionality

---

## Coding Style

### Shell Scripts (Bash)
- Shebang: `#!/bin/env bash`
- Use `set -e` for error handling
- No comments unless explicitly requested
- Simple, direct approach — avoid unnecessary complexity
- Validate paths exist before operations
- Use `rm -f` for symlinks (safe to re-run)

### Python
- Docstring at top of file explaining purpose and features
- Standard library imports first, third-party imports second
- Clear variable naming
- Basic error handling with `exit(1)` on failure
- No type hints required (Python 3.x compatibility)

### General
- **Formatting:** No automated formatters for shell; Black for Python (if used)
- **Naming conventions:** lowercase with underscores for files/variables, descriptive names
- **Code organization:** Feature-based directories, single-responsibility scripts

### Key Patterns
- **Facade Pattern** — `main.sh` orchestrates all sub-scripts
- **Single Responsibility** — Each `.sh` file handles one app/service
- **Idempotent Scripts** — All scripts check state before modifying

---

## Testing Strategy

- **Test framework:** None (no formal testing infrastructure per PRD scope)
- **Validation approach:** Manual execution and verification
- **Acceptance criteria:**
  - Scripts execute without errors on target OS (Ubuntu 22.04+)
  - Scripts produce expected output
  - Scripts are re-run safe (idempotent)

---

## Questions Policy

**Always ask when:**
- Requirements are unclear or ambiguous
- Edge cases aren't specified
- About to make assumptions about business logic
- Security or performance implications are unclear
- Existing code contradicts requirements
- Path assumptions need confirmation (`~/repos/Debtorchy` convention)

**Don't assume when:**
- User intent is unclear
- Technology choices aren't documented
- Error handling isn't specified
- OS compatibility needs clarification

---

## Project Structure

```
Debtorchy/
├── .opencode/              # AI development workflow
│   ├── AGENTS.md           # This file
│   ├── PRD.md              # Product requirements
│   ├── commands/           # Slash commands for OpenCode
│   ├── progress/           # Human-tracked task completion
│   └── plans/              # Feature implementation plans
├── BOM-reconstructor/     # BOM processing (Python)
│   ├── consolidate_bom.py
│   └── consolidate_bom_excel.py
├── cd-NAS/                 # NAS quick-access (Windows)
│   ├── repos.bat
│   └── repos.ps1
├── context-engineering/    # OpenCode templates (copy-to-project)
├── docs/                   # Documentation
├── ubuntu-utility/         # Ubuntu setup scripts
│   ├── main.sh             # Master orchestrator
│   ├── apps/               # Individual app installers
│   ├── services/            # Service configurations
│   ├── commands/            # Utility commands
│   ├── keyboard.sh          # Keyboard configuration
│   ├── dotfiles.sh          # Dotfile symlinking
│   └── dotfiles/            # Config files (symlink targets)
│       ├── bash/
│       ├── vim/
│       └── alacritty/
└── README.md
```

---

## Important Files

- **PRD:** `.opencode/PRD.md` — Product requirements and scope
- **Main entry:** `README.md` — Repository overview
- **Ubuntu setup:** `ubuntu-utility/main.sh` — Master setup script
- **BOM tools:** `BOM-reconstructor/consolidate_bom.py` — Excel BOM processing

---

## Communication Guidelines

- Speak as little as possible; preserve token usage unless told otherwise
- Prefer saying too little then too much
- When executing a task, respond with "Done" or "Completed" — no summaries
- When asked a simple question, answer "yes" or "no" — one word

```
Example:
q: Can you clone a public git repository without github token?
a: yes
```

- When "yes" or "no" doesn't fit, give one (sometimes two) sentence(s)

```
Example:
q: How do you install numpy via apt?
a: Numpy is not a linux package, it's a python package and can be
installed via pip.
```

- When user asks for explanation, go on with normal explanation

---

## Common Pitfalls to Avoid

1. Don't skip reading existing code before making changes
2. Don't implement features without understanding the architecture
3. Don't assume "it should work" — verify explicitly
4. Don't leave broken code — either fix or document the issue
5. Don't rush — take time to understand the problem first
6. Don't hardcode paths — use `~/repos/Debtorchy` convention
7. Don't forget idempotency — scripts must be re-run safe

---

## Success Criteria

- Code follows existing patterns in the codebase
- Scripts execute without errors on target environment
- Idempotency maintained (safe to re-run)
- README/documentation updated if needed
- Changes validated before marking complete
