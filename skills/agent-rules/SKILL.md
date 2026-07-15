---
name: agent-rules
description: Encode working conventions as one rule file per concern in .claude/rules/ — testing (TDD, happy/negative path, coverage as discovery), migrations, design-system (atomic design vocabulary, content extremes, motion), code-review, sub-agents (model tiering), finding-unknowns — generalized to the project at hand, any ecosystem. Use when the user says "setup agent rules", "encode the agent rules", or invokes setup-tooling.
---

# Agent Rules

Encode the working conventions as one rule file per concern in
`.claude/rules/` — checked in, loaded as project instructions every
session. Write them generalized to the project at hand (its actual
domains, scripts, and stack), never with another app's specifics.

Four rules gate on a skill being installed. The **installed-check** —
inline this wording into each generated rule that uses it, so the rule
stands alone in the target repo: *the skill counts as installed when it
appears in the available-skills list in any scope — global, project, or
plugin — possibly namespaced (e.g. `john-superpowers:finding-unknowns`);
a name match under any namespace counts, and the list beats guessing
filesystem paths.*

The rules. The three large ones live in their own reference files — read
the file when you generate that rule; the short ones are inline here:

- **`testing.md`** (every project) — test-first via `tdd`, happy/negative
  grouping, domain-folder layout, coverage as a discovery tool. Full
  template in [rules/testing.md](./rules/testing.md).
- **`design-system.md`** (frontend projects only) — `/impeccable` as the
  quality bar, atomic-design granularity vocabulary, content/state
  extremes, motion, theming, responsive matrix. Full template in
  [rules/design-system.md](./rules/design-system.md).
- **`sub-agents.md`** (every project) — model tiering (cheap / mid /
  heavy-hitter) by role, heavy tier opt-in, spawner-as-reviewer. Full
  template in [rules/sub-agents.md](./rules/sub-agents.md).
- **`migrations.md`** (only when the project has a DB): local dev is
  push-based; deployed environments are migration-based (in JS:
  Drizzle's `db:push` / `db:generate` / `db:migrate`). Generate the
  migration once the shape is final, and it lands **in the same
  commit** as the schema change — a schema edit without its migration
  silently never reaches deployed environments. Never edit a committed
  migration; add a new one. The deploy pipeline runs the migrations
  against that environment's database before building.
- **`code-review.md`**: after any code change, run `/code-review` and fix
  findings **before** committing — only when the code-review skill
  passes the installed-check; if it doesn't, commit without improvising
  an ad-hoc review. Docs-only changes
  are exempt; when in doubt, review anyway. The point: the working
  branch's history is what reviewers read, so findings get fixed
  pre-commit instead of surfacing in PR review.
- **`finding-unknowns.md`**: before implementing a non-trivial feature —
  new domain, schema change, unfamiliar area of the codebase — run
  `/john-superpowers:finding-unknowns` to map the unknowns (four-quadrant
  pass: verify assumptions against the code, interview open questions,
  prototype taste calls, teach blindspots) before writing code — only
  when the skill passes the installed-check; skip silently when it
  doesn't. Mechanical changes and bug fixes
  with an obvious cause are exempt. The point: unknowns get surfaced
  while they're cheap — during planning, not after implementation comes
  back wrong.

When installing these rules, if a skill in
[skill.deps.json](./skill.deps.json) isn't installed, prompt the user to
run its install command first.
