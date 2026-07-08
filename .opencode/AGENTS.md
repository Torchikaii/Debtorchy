# AI Agent Rules - Debtorchy

## Project Overview

- **Project name:** `Debtorchy`
- **Core purpose:** Monorepo containing a complete Debian operating system (extracted ISO, versioned via git-lfs), post-install provisioning scripts, and documentation. Enables fully autonomous, reproducible OS installation with zero human intervention.
- **Target users:** Solo developer / power user who wants instant, hands-free recreation of a production-ready Debian workstation.

---

## Core Principles

1. **Ask questions instead of assuming** — When unclear about requirements, ask the user before implementing
2. **Verify before acting** — Read existing code before making changes, understand the codebase first
3. **Keep it simple** — Prefer simple solutions over complex ones unless complexity is justified
4. **Document decisions** — Explain why you made certain choices
5. **Test thoroughly** — Verify your changes work and don't break existing functionality
6. **Maintain idempotency** — Scripts must be safe to re-run; no errors on repeated execution
7. **One thing well** — Each utility/script should do one thing; don't bundle unrelated functionality

---

## Coding Style

### Shell Scripts (Bash)
- Shebang: `#!/bin/bash` or `#!/usr/bin/env bash`
- Use `set -e` for error handling
- No comments unless explicitly requested
- Simple, direct approach — avoid unnecessary complexity
- Validate paths exist before operations
- Use `rm -f` for symlinks (safe to re-run)

### General
- **Naming conventions:** lowercase with underscores for files/variables, descriptive names
- **Code organization:** Feature-based directories, single-responsibility scripts

### Key Patterns
- **Facade Pattern** — `main.sh` orchestrates all sub-scripts
- **Single Responsibility** — Each `.sh` file handles one app/service
- **Idempotent Scripts** — All scripts check state before modifying

---

## Testing Strategy

- **Test framework:** None (manual execution and verification)
- **Validation approach:** Manual execution on target OS (Debian)
- **Acceptance criteria:**
  - Scripts execute without errors
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

**Don't assume when:**
- User intent is unclear
- Technology choices aren't documented
- Error handling isn't specified

---

## Project Structure

```
Debtorchy/
├── .opencode/         # AI development workflow
│   ├── AGENTS.md      # This file
│   ├── AGENTS-template.md
│   ├── PRD.md         # Product requirements
│   ├── commands/      # Slash commands for OpenCode
│   ├── progress/      # Human-tracked task completion
│   └── plans/         # Feature implementation plans
├── iso/               # Extracted Debian netinst ISO (git-lfs)
│   ├── boot/
│   ├── debian -> .    # ISO circular symlink (preserved)
│   ├── dists/
│   ├── install.amd/
│   ├── isolinux/
│   ├── pool/
│   └── firmware/
├── os-provision/      # Post-install scripts
│   ├── main.sh        # Master orchestrator
│   ├── apps/          # Individual app installers
│   ├── commands/      # Utility commands
│   ├── dotfiles/      # Config files (symlink targets)
│   ├── dotfiles.sh    # Dotfile symlinking
│   ├── fonts.sh       # Font installation
│   └── python/        # Python package installation
├── docs/              # Documentation
│   └── build-iso.md   # ISO build instructions
└── README.md          # Repository overview
```

---

## Important Files

- **PRD:** `.opencode/PRD.md` — Product requirements and scope
- **Main entry:** `README.md` — Repository overview
- **ISO build:** `docs/build-iso.md` — How to rebuild the ISO
- **Provisioning:** `os-provision/main.sh` — Post-install orchestrator

---

## Communication Guidelines

- Speak as little as you can, preserve token usage, unless told otherwise or you want to ask a question.
- Prefer saying too little then too much.
- When AI agent is asked to execute a task it should never print summary or something but "Done" or "Completed". 1 Word, no speeches, no poems.
- When asked a simple question AI agent has to always say "yes" or "no". 1 word answer.

```
Example:
q: Can you clone a public git repository without github token ?
a: yes
```

- When it's hard to answer "yes" or "no" to the question (or the question is incorrect). You can give one (in some cases two) sentence answer.

```
Example:
q: How do you install numpy via apt ?
a: Numpy is not a linux package, it's a python package and can be installed via pip.
```

- If a user doesn't understand what are you saying and asking you why certain things work in certain ways or ask you to explain then you can go on with normal explanation, instead of one or two sentences.

```
Example
q1: Is sky on earth green ?
a1: no
q2: why not ?
a2: Because <go on with explanation, about dispersion and other optics related stuff, light travelling, bending, absorbtion, etc>
```

---

## Common Pitfalls to Avoid

1. Don't skip reading existing code before making changes
2. Don't implement features without understanding the architecture
3. Don't assume "it should work" — verify explicitly
4. Don't leave broken code — either fix it or document the issue
5. Don't rush — take time to understand the problem first
6. Don't hardcode paths — use `~/repos/Debtorchy` convention
7. Don't forget idempotency — scripts must be re-run safe
8. **Never run dangerous git commands** — Do not `git commit`, `git push`, `git rebase`, `git merge`, `git reset`, or any other destructive or mutating git operations. Ask the human to do those manually.

---

## Success Criteria

- Code follows existing patterns in the codebase
- Scripts execute without errors on target environment
- Idempotency maintained (safe to re-run)
- Documentation updated if needed
- Changes validated before marking complete
