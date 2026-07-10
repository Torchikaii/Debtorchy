# Debtorchy .opencode/README.md

### Workflow

Each `SESSION` in diagram below means opening new opencode
session. This yields better LLM context utilisation.   

`/<command name>` (e.g. `/create-prd` ) below tells which command
you should run in which session. Commands are stored inside 
`/commands` folder (see [project structure](#Structure) and
[command](#Commands) section below).

```
SESSION 1: Initial Planning
├── 1. Briefly describe project idea to AI agent (or tell it to 
│   │  analyze brownfield)
│   └── Tell AI agent to ask clarifying questions
├── 2. /create-prd → creates .opencode/PRD.md
└── 3. /create-rules → creates .opencode/AGENTS.md

SESSION 2: Feature Planning
├── 1. /prime → loads PRD + AGENTS.md + PROGRESS.md context
├── 2. /plan-feature phase-1-plan.md → creates phase-1-plan.md
└── (optional: iterate within session)

SESSION 3: Execution
├── 1. /prime → loads context + current state
├── 2. /execute phase-1-plan.md (phase-1-pland.md is $ARGUMENT)
│   └── AI validates as it goes (tests, checks)

REPEAT SESSION 2 for each phase planning (create phase-n-plan.md)
REPEAT SESSION 3 for each phase execution (execute
phase-1-plan.md).

```

---

### Commands

| Command | Description |
|---------|-------------|
| `/create-prd` | Generate PRD.md from conversation |
| `/create-rules` | Generate AGENTS.md from template + PRD |
| `/prime` | Load project context in new session |
| `/plan-feature` | Create phase-X-plan.md in plans/ |
| `/execute <plan>` | Execute plan with validation |

---

### Structure

```
.opencode/
├── AGENTS-template.md      # Template for AI agent rules
├── PRD.md                  # Product Requirements Document (ideal state)
├── PROGRESS.md             # Implementation status against PRD
├── AGENTS.md               # Generated agent rules
├── commands/
│   ├── create-prd.md
│   ├── create-rules.md
│   ├── execute.md
│   ├── plan-feature.md
│   └── prime.md
└── plans/
    └── phase-X-plan.md      # Implementation plans
```

---

### Key Concepts

- **PRD.md** - Brief product overview, containing final (ideal) state
of the project.
- **PROGRESS.md** - Tracks what's implemented vs not implemented against PRD
- **AGENTS.md** - Coding rules for AI agents, generated from template
- **phase-X-plan.md** - Detailed implementation plans
