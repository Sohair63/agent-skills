# agent-skills

Global rules and skills I want in every project, for Claude Code and any agent that reads `AGENTS.md`.

## Install

```bash
./install.sh
```

The script symlinks `CLAUDE.md` to `~/.claude/CLAUDE.md` and each folder in `skills/` into `~/.claude/skills/`. If `~/.codex` exists, it links `AGENTS.md` and the skills there too. Edits made here take effect everywhere straight away, so commit and push them like code.

## Layout

- `CLAUDE.md`: global rules loaded in every session. `AGENTS.md` is a symlink to the same file, so there is one source.
- `skills/<name>/SKILL.md`: one skill per folder.

## Skills

| Skill | When it runs |
| --- | --- |
| `task-preflight` | Start of every task: end-to-end audit, product decisions settled up front, code and PR shape pre-designed |
| `change-impact-check` | Changing shared code, and as the gate before a commit or PR |
| `done-verification` | Before reporting work as done: existing data, lifecycle, rollout, roles, data shapes, presentation |
| `branch-self-review` | On request or before pushing: independent reviewers, verify findings, fix P1 and P2 |
| `lean-code` | Writing or reviewing code: same behaviour in fewer lines |
| `system-design` | Choosing between materially different designs |
| `code-clarity` | Writing or reviewing code: naming, consistency, no over-engineering |
| `rails-model-naming` | Creating Rails models, tables and migrations |

## Project-specific skills

Skills that depend on one codebase (for example Journey Tracker's `feature-architecture-audit` or `scenario-verification`) stay in that repo's `.claude/skills/`. Global skills use different names from project ones because personal skills take precedence over project skills with the same name; each global skill tells the agent to run the project's version as well when there is one.

## Adding a skill

1. Create `skills/<name>/SKILL.md` with `name` and `description` frontmatter. The description decides when the skill triggers, so say what it does and when to use it.
2. Run `./install.sh`.
3. If it should run on every task, reference it in `CLAUDE.md`.
