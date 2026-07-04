# Product Requirements Document: Debtorchy

**Version:** 1.0  
**Last Updated:** 2026-03-25

---

## 1. Executive Summary

This repository serves as a personal utility toolkit ("Debtorchy"), consolidating small but essential scripts and configurations that support daily development workflows. Rather than maintaining numerous separate repositories for small utilities, this monorepo approach keeps related tools organized, version-controlled, and easily deployable across systems.

The project addresses the practical reality that developers accumulate small scripts, configurations, and tools over time. By centralizing these utilities, the repository enables quick environment reconstruction, workflow automation, and knowledge preservation.

**Core Value Proposition:** One repository to rule all personal utilities — portable, maintainable, and ready to deploy anywhere.

**MVP Goal:** Provide a curated collection of utilities that reduce friction in daily development tasks, from workstation setup to BOM management to structured AI-assisted development.

---

## 2. Mission & Principles

### Mission Statement

Build and maintain a personal utility ecosystem that eliminates repetitive tasks, preserves institutional knowledge, and enables instant environment recreation across machines.

### Core Principles

1. **Simplicity First** — Each utility should do one thing well. Avoid over-engineering small tools.
2. **Portability** — Utilities must work across different environments (Linux, Windows via scripts, etc.)
3. **Idempotency** — Scripts must be safe to re-run. No duplicate entries, no errors on re-execution.
4. **Self-Contained** — Minimal external dependencies. Prefer standard library tools where possible.
5. **Documentation by Default** — Every utility includes README explaining purpose, usage, and dependencies.

---

## 3. Target Users

### Primary User

**The Solo Developer / Power User**
- Develops firmware/PCB using Altium Designer
- Uses Ubuntu as primary workstation
- Leverages AI tools (OpenCode) for development assistance
- Maintains Windows environment for specific tasks

### Technical Comfort Level

- Comfortable with command line
- Familiar with shell scripting (bash)
- Basic Python knowledge for BOM utilities
- Understands symlinks and dotfile management

### Problems Solved

| Problem | Utility |
|---------|---------|
| Time-consuming fresh Ubuntu setup | `ubuntu-utility/` |
| Repetitive BOM column modifications | `BOM-reconstructor/` |
| Slow NAS navigation | `cd-NAS/` |
| Inconsistent AI development workflows | `context-engineering/` |
| Scattered documentation | `docs/` |

---

## 4. Scope

### In Scope (MVP) ✅

- [ ] **ubuntu-utility** — Automated Ubuntu workstation setup
  - Shell scripts for app installation (docker, terraform, brave, vim, etc.)
  - Keyboard layout configuration
  - Dotfile symlinking (bash, vim, alacritty)
  - Network storage mounting (cifs, nfs)
  - Safe to re-run idempotent execution

- [ ] **BOM-reconstructor** — Altium BOM file processing
  - Python scripts for Excel manipulation
  - Column addition/removal
  - CSV consolidation from multiple files
  - Works with Altium default export format

- [ ] **cd-NAS** — Quick NAS access
  - Windows CMD script (`repos.bat`)
  - PowerShell script (`repos.ps1`)
  - Auto-login and directory change

- [ ] **context-engineering** — OpenCode workflow templates
  - PRD generation command
  - Agent rules templates
  - Progress tracking system
  - Feature planning templates

- [ ] **docs** — Reference documentation
  - Git credential management
  - How-to guides

### Out of Scope ❌

- [ ] GUI applications (CLI-first approach)
- [ ] Cross-platform abstraction layers

---

## 5. User Stories

### Ubuntu Setup

**US-001:** As a developer, I want to run one script to set up a fresh Ubuntu machine, so I can be productive within minutes instead of hours of manual configuration.

**US-002:** As a developer, I want my dotfiles symlinked from a repository, so changes to configuration are automatically shared across machines.

**US-003:** As a developer, I want keyboard shortcuts configured automatically, so I don't have to reconfigure after each Ubuntu reinstall.

**US-004:** As a developer, I want to mount NAS storage with a single command, so I can access my files without manual network configuration.

### BOM Processing

**US-005:** As an electronics engineer, I want to modify BOM columns from Altium exports, so I can prepare files for different manufacturing requirements.

**US-006:** As an electronics engineer, I want to consolidate multiple BOM files, so I can compare revisions or merge component lists.

### Development Workflow

**US-007:** As an AI-augmented developer, I want structured planning commands, so I can break complex features into manageable phases.

**US-008:** As an AI-augmented developer, I want progress tracking, so I can see what remains in each development phase.

### Cross-Platform

**US-009:** As a developer using both Windows and Linux, I want platform-specific utilities in one repo, so I don't forget where my tools are located.

---

## 6. Architecture & Design

### Directory Structure

```
Debtorchy/
├── .opencode/           # AI development workflow templates
│   ├── commands/        # Slash commands for OpenCode
│   ├── progress/        # Human-tracked task completion
│   └── plans/           # Feature implementation plans
├── BOM-reconstructor/   # BOM processing utilities
│   ├── consolidate_bom.py
│   └── consolidate_bom_excel.py
├── cd-NAS/             # NAS quick-access scripts
│   ├── repos.bat        # Windows CMD
│   └── repos.ps1        # Windows PowerShell
├── context-engineering/ # OpenCode templates
│   └── .opencode/       # Copy-to-project templates
├── docs/               # Documentation
├── ubuntu-utility/     # Ubuntu setup scripts
│   ├── main.sh          # Master orchestration script
│   ├── apps/            # Individual app installers
│   ├── services/        # Service configurations
│   ├── commands/        # Utility commands
│   └── dotfiles/        # Config files (symlink targets)
└── README.md           # Repository entry point
```

### Design Patterns

| Pattern | Application |
|---------|-------------|
| **Facade** | `main.sh` orchestrates all sub-scripts |
| **Single Responsibility** | Each `.sh` file handles one app/service |
| **Template Method** | Context engineering commands follow consistent structure |
| **Idempotent Scripts** | All scripts check state before modifying |

---

## 7. Technology Stack

### Shell Scripts
- **Bash** — Primary scripting language for Ubuntu
- **DASH** — POSIX-compliant shell compatibility
- **Dconf/GSettings** — GNOME configuration management

### Python
- **Python 3.x** — BOM processing
- **openpyxl** — Excel file manipulation
- **pandas** — Data processing (optional enhancement)

### Platform-Specific
- **CMD/PowerShell** — Windows NAS scripts
- **GitHub Actions** — CI/CD workflows

### Development Tools
- **OpenCode** — AI development assistant
- **Zod** — Schema validation for context engineering

---

## 8. Security & Configuration

### Authentication

| Utility | Method |
|---------|--------|
| NAS Mounting | Stored credentials (cifs-utils) |
| Git | SSH keys / credential helpers |
| General | No sensitive data in repo |

### Configuration Management

- **Dotfiles** stored in `ubuntu-utility/dotfiles/`
- **Symlinks** created to `~/.config`
- **No hardcoded paths** — uses `~/repos/Debtorchy` convention

### Security Scope

- No production secrets stored
- No API keys or tokens in repository
- `.gitignore` excludes sensitive files
- Credentials handled by system keyring (future enhancement)

---

## 9. API Specification

Not applicable — this is a collection of standalone utilities, not an API-driven service.

---

## 10. Success Criteria

### Functional Acceptance Criteria ✅

- [ ] `ubuntu-utility/main.sh` executes without errors on fresh Ubuntu 22.04+
- [ ] All app installers create working installations
- [ ] Dotfile symlinks resolve correctly
- [ ] BOM Python scripts produce valid Excel output
- [ ] NAS scripts connect to configured server
- [ ] OpenCode commands load correct templates

### Quality Indicators

| Metric | Target |
|--------|--------|
| Scripts re-run safely | 100% idempotent |
| README coverage | All utilities documented |
| Cross-session context | OpenCode templates functional |
| Setup time (Ubuntu) | < 30 minutes automated |

---

## 11. Implementation Phases

### Phase 1: Foundation ✅
**Goal:** Establish core infrastructure

- [x] Repository structure created
- [x] Basic ubuntu-utility scripts implemented
- [x] README documentation written
- [x] Git ignore configured

**Validation:** Can clone repo and run `main.sh` on fresh Ubuntu  
**Timeline:** Completed

### Phase 2: Utility Expansion ✅
**Goal:** Add missing utilities

- [x] BOM-reconstructor Python scripts added
- [x] cd-NAS Windows scripts added
- [x] context-engineering templates created
- [x] docs folder populated

**Validation:** Each utility works independently  
**Timeline:** Completed

### Phase 3: Workflow Integration (Current)
**Goal:** Enhance AI-assisted development

- [x] OpenCode command templates implemented
- [x] PRD generation workflow created
- [ ] Agent rules template refined
- [ ] Progress tracking system operational

**Validation:** Can run full `/create-prd` → `/execute` workflow  
**Timeline:** In progress

### Phase 4: Polish & Portability
**Goal:** Improve maintainability

- [ ] Add input validation to all scripts
- [ ] Create Windows WSL compatibility layer
- [ ] Add installation script for cd-NAS
- [ ] Document all command-line arguments

**Validation:** All scripts have `--help` or usage info  
**Timeline:** Future

---

## 12. Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| **Path dependencies** — Scripts assume `~/repos/Debtorchy` | Medium | High | Document path requirement; add path detection |
| **Ubuntu version drift** — APIs change between releases | Medium | Medium | Test on LTS releases; use version checks |
| **BOM format changes** — Altium export format varies | Low | Medium | Add format detection; version comments |
| **Context engineering template bloat** — Over-engineering | Low | Medium | Keep templates minimal; iterate based on need |
| **Windows script neglect** — Scripts not tested regularly | Low | High | Add periodic testing; document requirements |

---

## 13. Future Considerations

### Post-MVP Enhancements

- **Windows Subsystem for Linux (WSL) support** — Unified scripts across Windows/Linux
- **Homebrew/Linuxbrew compatibility** — Package management abstraction
- **Docker containerization** — Portable development environments
- **Ansible/Terraform integration** — Infrastructure-as-code for workstation
- **Dotfiles manager integration** — Consider chezmoi or GNU Stow

### Integration Opportunities

- **GitHub Codespaces** — Cloud development environment
- **VS Code Remote** — Remote development support
- **Tailscale/Headscale** — Secure remote access to NAS

### Long-Term Vision

When any single utility outgrows the monorepo, it can be extracted into its own repository while maintaining the development workflow established here. The context-engineering system is designed to be portable — copy `.opencode/` to any project for consistent AI-assisted development.
