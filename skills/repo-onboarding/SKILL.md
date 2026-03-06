---
name: repo-onboarding
description: Comprehensive repository onboarding workflow that creates documentation for new developers. Generates tools.md (commands and tooling), architecture.md (system design with code references), summary.md (repo purpose), and quickstart.md (setup guide with prerequisites). Invoked by requests like "onboard this repo" or "create onboarding documentation".
---

## Invocation examples
- "Onboard this repo"
- "Create onboarding documentation"
- "Generate repository onboarding guide"
- "Help me understand this repository from scratch"

## Workflow

Use the ask_questions tool to collect:
1. Where to create the onboarding folder (e.g. `docs/`, `onboarding/`, hidden folder)
2. User's OS and preferred shell

Then create the folder and generate the four files below.

---

### Step 1 — tools.md

Scan the repo and document all development tooling.

**Scan for:**
- Package manager(s) and lock files
- Test frameworks — identify ALL layers independently
- Type checkers
- Linters and formatters
- Build, run, and deploy scripts
- CI/CD configuration
- Database migration tooling

**Testing section rules (critical):**
- Treat each layer (e.g. frontend, backend) as independent
- For each layer document: framework, config file link, test file pattern
- For each layer provide all of: run all, run single file, run by pattern, watch mode, CI mode
- Derive every command from actual repo files; do not invent command syntax
- Use shell syntax matching the user's environment

**tools.md structure:**
```
# Development Tools & Commands

## Package Manager
## Testing
  ### [Layer A] — [Framework]
  ### [Layer B] — [Framework]
## Type Checking
## Code Quality
## Build & Run
## Database
## Useful Scripts
## CI/CD
```

---

### Step 2 — architecture.md

Map the system design concisely.

- Identify main directories and their responsibilities
- Document entry points, data models, services, and external integrations
- Note the architecture style and key design patterns
- Use markdown file links: [file.ts](path/to/file.ts#L10-L20)

**architecture.md structure:**
```
# Architecture Overview
## Project Structure
## Core Components
## Technology Stack
## Design Patterns
## Data Flow
```

---

### Step 3 — summary.md

Write a short plain-language overview.

- Read README, package manifests, and main source files
- Describe what the repo does, what problem it solves, and its main features
- Keep it under one page

**summary.md structure:**
```
# Repository Summary
## What is this?
## Purpose
## Key Features
## Technology Stack
## Repository Type
```

---

### Step 4 — quickstart.md

Write a practical setup guide.

- List prerequisites (tools, credentials, config files) as checkboxes
- Provide exact install commands
- Include verification steps (tests, type check, lint, build)
- Document "Common Commands" with one example per command type per layer:
  - Run all tests
  - Run tests for one layer
  - Run a single test file
  - Run tests matching a folder or pattern
  - Start the app locally

**quickstart.md structure:**
```
# Quick Start Guide
## Prerequisites
## Installation
## Verification
## Running Locally
## Common Commands
## Troubleshooting
```

---

## General rules

- Verify every command exists in the repo before documenting it
- Use the user's shell syntax throughout
- Link to files using markdown: [file.ts](path/file.ts)
- Keep all documents concise — no padding or redundancy
- Use ask_questions when uncertain about repo details

## Workflow Summary

1. ASK — folder location, OS, shell
2. CREATE — tools.md
3. CREATE — architecture.md
4. CREATE — summary.md
5. CREATE — quickstart.md
6. CONFIRM — "Onboarding complete! Files are in [folder]/"