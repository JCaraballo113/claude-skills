# claude-skills

Personal collection of [Claude Code](https://docs.claude.com/en/docs/claude-code) skills, packaged as a Claude Code **plugin**. The repo doubles as its own single-plugin marketplace, so it installs directly from GitHub — portable across machines.

## Install

Inside Claude Code:

```
/plugin marketplace add JCaraballo113/claude-skills
/plugin install claude-skills@jcaraballo
```

### Local development install

On a machine where this repo is cloned and you want edits picked up without pushing to GitHub, add the marketplace from the local path instead:

```
/plugin marketplace add ~/Documents/repos/claude-skills
/plugin install claude-skills@jcaraballo
```

## Updating

After pulling (or pushing from another machine):

```
/plugin marketplace update jcaraballo
/reload-plugins
```

`/reload-plugins` applies changes in the active session; restarting Claude Code also works.

## Uninstall

```
/plugin uninstall claude-skills@jcaraballo
```

## Skills

Skills live under [`skills/`](./skills). Once the plugin is installed they're invoked as `/claude-skills:<name>`, and Claude also auto-invokes them from their descriptions.

| Skill | Description |
|---|---|
| [add-agent-skill](./skills/add-agent-skill/SKILL.md) | Scaffold a new agent skill in this repo. Interviews for name and triggers, writes the frontmatter + outline, and suggests a commit. Use when starting a new skill. Named `agent-skill` to avoid collision with a potential future Anthropic-shipped `add-skill`. |
| [html-artifact](./skills/html-artifact/SKILL.md) | Generate a single self-contained HTML artifact (inline CSS + inline SVG + optional inline JS) that visually explains a system, feature, or codebase area. Output is one file in `docs/` that opens offline. Use when the user wants to visualize a system, generate a flow diagram, build a one-pager explainer, or asks to "make an HTML artifact" / "visualize X" / "explain X visually". Good for state machines, planner/decision logic, data flows, and architectural overviews with optional interactive widgets. |
| [improve-user-experience](./skills/improve-user-experience/SKILL.md) | Find "bridging opportunities" — gulfs the user has to cross themselves — using Don Norman's gulf vocabulary (execution / evaluation, signifier, feedback). Walks the flows, presents candidates as a temp-dir HTML report, then grills the chosen one and designs the bridge in Pencil, held to `impeccable`'s bar. Anchored to `EXPERIENCE.md` (human-owned) + `CONTEXT.md`. Requires the Pencil MCP and the `impeccable` skill. Use when the user wants to improve UX, reduce friction, or fix where users get stuck. |
| [open-pr](./skills/open-pr/SKILL.md) | Open a reviewer-oriented pull request from the current branch. Reads diff and commits, interrogates the author one question at a time (intent, type, scope, risk, out-of-scope, ticket), builds a What / Why / Notes-for-reviewers body inline, then pushes and opens via `gh` as a draft by default. Honors any repo PR template. |
| [pr-review-status](./skills/pr-review-status/SKILL.md) | Read-only overview of the current branch's PR review comments — groups into addressed / pending / in-discussion / deferred. No edits, no posts. Pair with `triage-pr-comments` when you want to act on what you see. |
| [setup-js-tooling](./skills/setup-js-tooling/SKILL.md) | Bootstrap a JS/TS project with the preferred stack (TanStack Start/Vite/Hono, Query, Form, Drizzle + Docker/Supabase, Zod, Tailwind, shadcn, Vitest, guardrail ESLint, GitHub CI) on pnpm with the 1-day package-age guard. Interviews for project type first; the linting section works standalone on existing repos. |
| [teach-me](./skills/teach-me/SKILL.md) | A teaching session that makes sure you deeply understand a specific piece of work in this repo. Grounds itself in the code, git history, and ADRs, then walks you through the problem, the solution, and the broader context one item at a time — restating, drilling the whys, and quizzing — and won't finish until you've demonstrated mastery. Optionally saves durable study notes to Obsidian or Notion. |
| [triage-pr-comments](./skills/triage-pr-comments/SKILL.md) | Active triage workflow: classifies each comment into one of five states (valid-fix / partial / invalid / defer / needs-info), asks clarifying questions when ambiguous, implements approved fixes, and gates commit/push/reply on explicit user approval. |

## Editing workflow

The installed plugin is managed by Claude Code's plugin system — never edit installed copies directly. To change a skill:

1. Edit in the repo: `skills/<skill>/SKILL.md`
2. Commit + push (skip the push if the marketplace was added from the local path)
3. `/plugin marketplace update jcaraballo` then `/reload-plugins`

## Adding a new skill

Use the [`add-agent-skill`](./skills/add-agent-skill/SKILL.md) skill, or by hand:

1. Create `skills/<name>/SKILL.md` with frontmatter (`name`, `description`) — see existing skills for examples.
2. Validate: `claude plugin validate . --strict`
3. Commit + push, then `/plugin marketplace update jcaraballo` and `/reload-plugins`.

The `description` field is what Claude uses to decide when to invoke the skill, so make it specific about the triggers (e.g. "use when user says X" / "use when Y condition").
