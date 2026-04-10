---
name: commit
description: "Analyze working directory changes, compose a conventional commit message, and execute VCS operations after user approval. Use when: the user says 'commit', 'push', 'check in', 'submit changes', or after implementation is complete and changes need to be committed. Supports git, hg, and svn."
---

# Commit Workflow

Analyze working-directory changes and compose a commit message for user
approval. Execute VCS write operations only after explicit approval.

## Communication style

- Telegraph style. No preambles, no filler.
- Show the proposed commit message and the files to be committed.
- End every proposal with a hard stop — do not commit without approval.

## Constraints

- DO NOT edit, create, or delete source code, tests, or config files.
- DO NOT run destructive VCS operations: force-push, rebase, reset,
  branch deletion, history rewriting, or discarding uncommitted work.
- DO NOT commit without user approval of the message.
- DO NOT push without explicit user request or confirmation.

## §1. Detect VCS Commands

Detect VCS: check for `.git/`, `.hg/`, `.svn/` at the repo root
(first match wins). If none found, tell the user and stop.

### Shell detection

Detect the user's shell to produce correct command syntax.

| Shell | Command separator | Quote style |
|---|---|---|
| bash / zsh | `&&` | double quotes, escape inner `"` with `\"` |
| cmd.exe | `&&` | double quotes |
| PowerShell 7+ | `&&` | double quotes |
| PowerShell 5.1 | `; ` (semicolon) | double quotes |

**Detection:** Check `$PSVersionTable.PSVersion.Major` if in
PowerShell. Major < 7 → use `;`. Otherwise use `&&`.
On non-Windows (Linux/macOS), default to `&&`.

### Default command map (fallback)

| Action | git | hg | svn |
|---|---|---|---|
| Branch | `git branch --show-current` | `hg branch` | — |
| Status | `git status --short` | `hg status` | `svn status` |
| Diff summary | `git diff HEAD --stat` | `hg diff --stat` | `svn diff --summarize` |
| Diff full | `git diff HEAD` | `hg diff` | `svn diff` |
| Stage all | `git add -A` | *(auto)* | *(auto)* |
| Stage files | `git add <files>` | `hg add <new>` | `svn add <new>` |
| Commit | `git commit -m "<msg>"` | `hg commit -m "<msg>"` | `svn commit -m "<msg>"` |
| Push | `git push` | `hg push` | *(commit pushes)* |
| Log (last) | `git log -1` | `hg log -l 1` | `svn log -l 1` |

## §2. Propose

### Step 1 — Status & branch context

1. Run branch command → note the current branch name.
2. Run status command. No changes → report "Nothing to commit" and stop.
3. Report branch name alongside the file list.

### Step 2 — Diff analysis

Run diff summary, then full diff (`HEAD` base captures both staged
and unstaged changes). Determine:
- Which modules/areas are affected
- Logical change type (feature, fix, refactor, etc.)
- Whether changes span unrelated concerns

### Step 3 — Multi-concern check

Changes span **unrelated concerns** → suggest splitting into separate
commits. List files per concern and stop for user decision.

### Step 4 — Compose commit message

Format:
```
<type>(<scope>)[!]: <summary, imperative mood, ≤72 chars>

<why — max 3 lines>

[BREAKING CHANGE: <description>]
[Refs: <SHA>]
```

Parts in `[]` are optional.

#### Types

| Type | When |
|---|---|
| `feat` | New feature or capability |
| `fix` | Bug fix |
| `refactor` | Code restructuring, no behavior change |
| `test` | Adding or updating tests only |
| `docs` | Documentation only |
| `chore` | Maintenance (deps, config, tooling) |
| `ci` | CI/CD pipeline changes |
| `style` | Formatting, whitespace, no logic change |
| `perf` | Performance improvement |
| `revert` | Reverting a previous commit |

#### Rules

- **scope**: module/area in parentheses — derived from primary
  directory or component changed. Optional but recommended.
- **`!`**: append before `:` for breaking changes.
- **summary**: imperative mood, ≤72 chars, lowercase.
- **body**: max 3 lines. Explain _why_, not _what_. Omit if summary is
  self-explanatory. Must not repeat summary.
- **forbidden**: "This commit…", "Updated…", "Changed…" openers; test
  coverage percentages; quality gate mentions.
- **no special characters in message text**: do not use quotes
  (`"`, `'`, backticks), apostrophes, or other shell-sensitive
  characters. Rephrase or use hyphens instead
  (e.g. "add document-the-symbol-itself rule").
- **footers**: only `BREAKING CHANGE: <description>` and
  `Refs: <SHA>` (for `revert` type only).

#### Examples

```
feat(discovery): add VCS detection to project initialization

Projects may use git, hg, or svn — detection at init time avoids
repeated probing by downstream agents.
```

```
fix(worker_pool): prevent duplicate task dispatch on timeout
```

```
refactor(skills): extract shared validation into base class

Reduces duplication across apc, dac, and pantheon skill modules.
Three validators collapsed into one with subclass hooks.
```

```
feat(api)!: replace authentication with OAuth2 flow

Basic auth no longer accepted. All clients must migrate to OAuth2
before next release.

BREAKING CHANGE: /auth/login endpoint removed, use /oauth/token instead
```

```
revert(parser): undo greedy matching change

Caused false positives on multi-line inputs.

Refs: a3b8f2c
```

### 🛑 Approval gate

Present:
1. Files to be committed (from status output)
2. Proposed commit message (fenced code block)

Then use the ask-questions tool with these options:
- **Commit** — stage and commit only
- **Commit & Push** — stage, commit, and push
- **Edit** — let the user revise the message before proceeding

**Do not execute VCS write commands until the user picks an option.**

## §3. Execute

Only after user selects an option from the approval gate.

- **Edit** → ask for the revised message, then re-present the approval
  gate with the updated message.
- **Commit** or **Commit & Push** → proceed:

1. Run stage + commit (e.g. `git add -A && git commit -m "<summary>" -m "<body>"`).
   For multi-line messages use the multi-arg `-m` form.
   Use the detected shell's separator from §1.
   If it fails, diagnose and retry once.
2. If user chose **Commit & Push** — run push command after commit succeeds.
3. Show the VCS log entry for the new commit.
