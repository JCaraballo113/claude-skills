---
name: agent-rules
description: Encode working conventions as one rule file per concern in .claude/rules/ — testing (TDD, happy/negative path, coverage as discovery), migrations, design-system (atomic design vocabulary, content extremes, motion), code-review, subagent-model-tiering (advisory escalation, parallel safety), improve-the-territory (leave touched code better than found), finding-unknowns — generalized to the project at hand, any ecosystem. Use when the user says "setup agent rules", "encode the agent rules", or via setup-tooling.
---

# Agent Rules

Encode the working conventions as one rule file per concern in
`.claude/rules/` — checked in, loaded as project instructions every
session. Write them generalized to the project at hand (its actual
domains, scripts, and stack), never with another app's specifics.

Each rule's full spec lives in [`rules/`](rules/); the index below only
routes. For every rule whose "applies" condition the project meets, read
its spec file, then write the generalized rule from it.

Some rules gate on a skill being installed. The **installed-check** —
inline this wording into each generated rule that uses it, so the rule
stands alone in the target repo: *the skill counts as installed when it
appears in the available-skills list in any scope — global, project, or
plugin — possibly namespaced (e.g. `john-superpowers:finding-unknowns`);
a name match under any namespace counts, and the list beats guessing
filesystem paths.*

The rules:

- [`testing.md`](rules/testing.md) (every project) — features develop
  test-first via the `tdd` skill; happy/negative-path spec structure;
  coverage as discovery, not a gate.
- [`migrations.md`](rules/migrations.md) (only when the project has a
  DB) — local dev pushes, deployed environments migrate; the migration
  lands in the same commit as the schema change.
- [`design-system.md`](rules/design-system.md) (frontend projects only)
  — `/impeccable` owns the quality bar; atomic-design granularity
  vocabulary; content/state extremes; theming; responsive; motion.
- [`code-review.md`](rules/code-review.md) (every project) — run
  `/code-review` and fix findings before every commit.
- [`subagent-model-tiering.md`](rules/subagent-model-tiering.md) (every
  project) — match each spawn's model to the task across three cost
  tiers; advisory escalation; parallel execution safety.
- [`improve-the-territory.md`](rules/improve-the-territory.md) (every
  project) — existing code is precedent, not gospel; leave touched
  patterns better than found.
- [`finding-unknowns.md`](rules/finding-unknowns.md) (every project) —
  map the unknowns before non-trivial features.

When installing these rules, if a skill in
[skill.deps.json](./skill.deps.json) isn't installed, prompt the user to
run its install command first.

Done when every applicable rule exists in `.claude/rules/`, written from
its spec and generalized to this project, and every skill-gated rule
carries the installed-check wording inline.
