# Design: git-workflow agent

**Date:** 2026-04-10  
**Status:** Implemented  
**File:** `agents/git-workflow.md`

---

## Problem

Commit and PR workflows require loading project-specific conventions (branch naming, commit format, PR description template). These conventions live in existing skills (`mine-git-conventions`, `mine-project-workflow`). Running this workflow on the primary model is wasteful — the task is well-defined and deterministic.

## Goals

- Execute commit + PR workflow using the cheapest available model
- Dynamically load only the skills relevant to the current task
- Ask for confirmation before irreversible operations (push, PR creation)
- Reuse existing skill definitions without duplicating conventions

## Approach chosen: dynamic skill loading

The agent's system prompt defines rules for when to load each skill. The model calls the `skill` tool on demand, loading `mine-git-conventions` or `mine-project-workflow` (or both) depending on what the task requires.

**Rejected alternatives:**

- *Static skill list in frontmatter* — OpenCode does not support `skills:` in agent frontmatter; skills are always loaded dynamically via the `skill` tool.
- *Inline conventions* — Would duplicate content from SKILL.md files, creating a maintenance burden.

## Configuration

| Option | Value | Rationale |
|---|---|---|
| `model` | `claude-haiku-4-5` | Cheapest available model |
| `mode` | `subagent` | Invoked by primary agent or via `@git-workflow` |
| `temperature` | `0.1` | Deterministic output for commit messages |
| `bash.*` | `allow` | Needed for git/gh commands |
| `git push*` | `ask` | Irreversible — requires confirmation |
| `gh pr create*` | `ask` | Irreversible — requires confirmation |
| `edit`, `write` | `deny` | Agent should not modify source files |

## Skill loading rules

| Condition | Skill to load |
|---|---|
| Commit messages, branch naming, PR descriptions, CHANGELOG | `mine-git-conventions` |
| GitHub Issues, ROADMAP, pre-coding workflow | `mine-project-workflow` |
| Both apply | Load both |

## Workflow

1. `git diff --staged` / `git diff` — understand current state
2. Read changed files if context is needed
3. Stage files selectively (`git add` — never blindly `git add -A`)
4. Write commit message per `mine-git-conventions` conventions
5. `git commit` autonomously
6. Ask before `git push`
7. Prepare PR title + body, ask before `gh pr create`
8. Report: committed files, PR URL if opened

## Relation to existing agents

- `reviewer.md` — read-only code review, also on `claude-haiku-4-5`. Separate concern.
- `git-workflow.md` — write-capable (bash only), handles git/gh operations.
