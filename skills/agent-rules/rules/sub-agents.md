# `sub-agents.md` — the generated rule

Applies to **every project**.

Match the sub-agent's model to the task; never default every spawn to the session model. Think in three cost tiers, cheapest to most expensive, named by **role** so the rule survives new model releases:

- a **cheap tier** (Sonnet today),
- a **mid tier** (Opus today),
- a single **heavy-hitter tier**: the most expensive model the session offers (Fable at the time of writing, but read it as whatever the top tier is when you run).

Reserve each tier for where its extra capability pays off.

## Cheap tier — mechanical, well-specified work

One right answer and a clear spec: lint remediation (`id-length`, `no-magic-numbers`, other cap fixes with an obvious extraction), mechanical renames, straightforward test scaffolding, doc/format passes, search-and-collate.

## Mid tier — judgment-heavy work

Structural refactors of long or complex files (splitting modules along seams, decomposing high-complexity functions without changing behavior), architecture and interface design, ambiguous or underspecified tasks, security-sensitive or money-moving code, and cross-cutting changes whose blast radius needs weighing.

## Heavy-hitter tier — opt-in, never a silent default

Before spawning any sub-agent on it, confirm the user wants sub-agents to potentially use it (and it is only a candidate when actually available in the session). Two modes the user picks:

- **(a) case-by-case** — the spawner still applies the judgment call: the heavy hitter only for the hardest tasks that genuinely out-reach the mid tier, not the default; or
- **(b) always** — route the heavy tier to it.

Absent an explicit yes, the heavy tier stays the mid tier.

## The spawner is the reviewer

When a cheaper-model agent returns, review its diff before committing — use `/code-review` for non-trivial batches (see `.claude/rules/code-review.md`). Cheaper execution plus a review gate from the spawner beats running everything on the top tier.

Set the model explicitly on each spawn (`model:` on the Agent tool, or `model`/`effort` per stage in a Workflow) rather than relying on inheritance.
