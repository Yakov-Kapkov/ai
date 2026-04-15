# AGENTS.md — tools/sda/

Rules for AI agents working on the SDA (Software Development Assistant) tool suite.

---

## Overview

SDA is a coordinated suite of AI agents that implement a Specification-Driven Development workflow. Agents are **tightly coupled by design** — they share file formats, workflow contracts, and behavioral rules. Changes to one agent frequently require synchronized changes to connected agents and shared resources.

## Folder Structure

```
tools/sda/
├── README.md                          ← user-facing docs, pipeline diagram, setup guide
├── AGENTS.md                          ← this file
├── .dev-assistant/
│   └── resources/
│       ├── bootstrap.md               ← shared init steps read by sda-dev and sda-dev-orc
│       └── project-config.example.json
├── agents/
│   ├── sda-init.agent.md              ← project initialization (standalone)
│   ├── sda-system.agent.md            ← system architecture design
│   ├── sda-feature.agent.md           ← feature-level design
│   ├── sda-task.agent.md              ← task specification design
│   ├── sda-dev.agent.md               ← TDD implementation (monolithic)
│   ├── sda-dev-orc.agent.md           ← TDD implementation (orchestrator)
│   ├── sda-test-writer.agent.md       ← subagent: writes tests (RED phase)
│   └── sda-coder.agent.md           ← subagent: writes production code (GREEN phase)
└── prompts/
    └── sda-init.prompt.md             ← prompt shortcut for sda-init
```

## Agent Dependency Map

### Two implementation branches (must stay in sync)

The TDD implementation phase has **two parallel branches** that must implement the same workflow logic:

| Branch | Agent(s) | How it works |
|---|---|---|
| **Monolithic** | `sda-dev` | Single agent handles the entire TDD cycle (RED → GREEN → refactor → quality checks) in one context |
| **Orchestrated** | `sda-dev-orc` → `sda-test-writer` + `sda-coder` | Orchestrator delegates RED to `sda-test-writer` and GREEN to `sda-coder` to reduce context size |

**Sync rule:** Both branches must produce identical outcomes for the same input. When changing workflow logic (slice processing, approval gates, verification commands, quality checks, refactoring pass, state tracking), apply the same change to both branches.

### Agent relationships

```
sda-init ─────────────────────────────────────────── standalone
sda-system ──handoff──▸ sda-feature                  design pipeline
sda-feature ─handoff──▸ sda-task                     design pipeline
sda-task ────handoff──▸ sda-dev OR sda-dev-orc       design → implementation

sda-dev                                              monolithic branch (self-contained)

sda-dev-orc ─delegates─▸ sda-test-writer             orchestrated branch
sda-dev-orc ─delegates─▸ sda-coder             orchestrated branch
```

### Detailed dependency matrix

| When you change… | Also update… | Why |
|---|---|---|
| `sda-dev` workflow logic (Phase 0–6) | `sda-dev-orc` (and vice versa) | Both branches must implement the same TDD workflow |
| `sda-dev` RED/test-writing rules | `sda-test-writer` (and vice versa) | `sda-test-writer` is the extracted RED phase of `sda-dev` |
| `sda-dev` GREEN/implementation rules | `sda-coder` (and vice versa) | `sda-coder` is the extracted GREEN phase of `sda-dev` |
| `sda-dev-orc` delegation format | `sda-test-writer` and `sda-coder` input contracts | Subagents parse the exact format the orchestrator sends |
| Approval gate structure or output templates | All of: `sda-dev`, `sda-dev-orc`, `sda-test-writer`, `sda-coder` | Gate outputs must be consistent across branches |
| `bootstrap.md` | `sda-dev` and `sda-dev-orc` (Phase 0 bootstrap step) | Both read bootstrap at conversation start |
| `task.md` schema (in `sda-task`) | `sda-dev`, `sda-dev-orc`, `sda-test-writer`, `sda-coder` | All implementation agents consume `task.md` |
| `state.md` schema (in `sda-task`) | `sda-dev`, `sda-dev-orc` | Both track progress via `state.md` |
| `feature.md` schema (in `sda-feature`) | `sda-task` (reads feature context) | Task designer reads the feature spec |
| `design.md` schema (in `sda-system`) | `sda-feature` (references system design) | Feature designer references system architecture |
| Communication rules (silent-by-default, forbidden phrases) | `sda-dev`, `sda-dev-orc` | Both share identical communication constraints |
| Standards compliance rules | `sda-dev`, `sda-dev-orc`, `sda-test-writer`, `sda-coder` | All code-producing agents enforce standards |
| Development guidance / coding standards skill references | `sda-dev`, `sda-dev-orc` | Both reference `development-guidance` for process and coding standards for output |
| Quality check gates (Phase 5) | `sda-dev`, `sda-dev-orc` | Both run the same quality gates |
| `sda-init` output format (`project-tools.md`, `project-config.json`) | `bootstrap.md`, `sda-dev`, `sda-dev-orc` | Implementation agents depend on init outputs |
| `README.md` | Keep consistent with all agent descriptions and workflow phases | User-facing docs must match agent behavior |

## Rules

### 1. Cross-Branch Synchronization (highest priority)

When changing TDD workflow logic in **either** implementation branch, apply the equivalent change to the other branch:

- **Monolithic → Orchestrated:** A change in `sda-dev` may need to be split across `sda-dev-orc`, `sda-test-writer`, and `sda-coder`.
- **Orchestrated → Monolithic:** A change in a subagent or orchestrator must be consolidated back into `sda-dev`.

Before considering any workflow change complete, verify both branches handle the same scenarios identically.

### 2. Schema Changes Propagate Downstream

File schemas (`task.md`, `state.md`, `feature.md`, `design.md`, `bootstrap.md`, `project-tools.md`, `project-config.json`) are contracts between agents. When changing a schema:

1. Identify every agent that **reads** or **writes** that schema (use the dependency matrix above).
2. Update all affected agents to match the new schema.
3. Update `README.md` if the schema is documented there.

### 3. Subagent Contract Stability

`sda-test-writer` and `sda-coder` have explicit **input contracts** (the format `sda-dev-orc` sends them). When changing delegation format:

1. Update the orchestrator's delegation templates.
2. Update the subagent's input contract section.
3. Verify the subagent's workflow still produces the expected output format.

### 4. Communication Rules Are Shared

`sda-dev` and `sda-dev-orc` share identical communication constraints (silent-by-default, output templates, forbidden phrases). When editing communication rules in one, copy the change to the other.

### 5. Keep README.md in Sync

The `README.md` in this folder documents the agent pipeline, setup steps, workflow phases, and configuration paths. When any of these change in the agent files, update `README.md` to match.

### 6. Preserve Existing Patterns

- Follow the formatting conventions already in use (Markdown heading levels, table layout, section numbering, output template style).
- New sections should model their structure after existing peer sections in the same agent file.

## Boundaries

- ✅ **Always do**: Propagate changes across connected agents, keep schemas consistent, update README.md.
- ⚠️ **Ask first**: Changing a file schema, adding/removing an agent, restructuring the delegation model, changing the approval gate sequence.
- 🚫 **Never do**: Change one branch without checking the other, modify subagent input contracts without updating the orchestrator, break the `task.md`/`state.md` contract that `sda-task` and implementation agents share.
