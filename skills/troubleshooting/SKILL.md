---
name: troubleshooting
description: "Troubleshooting dictionary for unexpected command results. Use when: a command (test run, build, lint, type check) fails unexpectedly, produces errors you did not anticipate, or behaves differently than expected. Look up the symptom before reasoning from scratch."
---

# Troubleshooting

**Purpose:** Eliminate reasoning loops. One lookup → one fix. Stop.

## Mandatory Workflow

1. Read `references/troubleshooting.md` **lines 1–15 only** (the Index table).
2. Match a keyword in the Index to the observed symptom. Note the line range.
3. Read **only that line range** from `references/troubleshooting.md`.
4. **Match found → apply the prescribed fix immediately. Do not consider
   alternatives. Do not enumerate workarounds. Stop.**
5. After applying the fix, re-run the command once.
   - Fixed → done.
   - Still failing → return to step 1 with the *new* symptom.
6. **No match found, or two consecutive fix attempts have failed →**
   diagnose normally. Do not loop back through the dictionary a third time.

## Anti-Loop Rules

- **One match = one fix.** Never apply more than one fix at a time.
- **Never brainstorm alternatives** when a dictionary match exists.
- **Never explore workarounds.** The dictionary entry is authoritative.
- **Cap at two attempts.** If the same symptom persists after two fixes,
  stop and escalate / diagnose outside the dictionary.
