# Design Decision Record

When a bridge (or any experience decision) is chosen with a real trade-off,
record it — so a future reader knows *what* was decided and *why*, and a
future UX review doesn't re-suggest what was already set aside. It follows
the ADR shape, but it is a **design** decision and lives with the design,
not in `docs/adr/` — so it isn't called an ADR.

## Where

`designs/decisions/NNNN-slug.md`, co-located with the `.pen`. Sequential
numbering — scan the folder for the highest number and increment. Create the
folder lazily, on the first record.

## When to write one

Only when all three hold (skip it otherwise):

1. **Hard to reverse** — re-deciding later costs real design and
   implementation work.
2. **Surprising without context** — a future reader will wonder "why this
   shape and not the obvious one?"
3. **A real trade-off** — there were genuine alternatives and one was picked
   for specific reasons.

A bridge chosen over designed-twice variants almost always qualifies: the
rejected variants *are* the trade-off.

## Format

```md
---
status: accepted
---

# {short title of the decision}

{1–3 sentences: the gulf/context, what was chosen, and why. Link the .pen artboard.}

## Considered options
{Optional — include when the rejected alternatives are worth remembering.}
- **{Variant / option}:** what it was, and why it lost.

## Consequences
{Optional — include when the decision commits the product to non-obvious behaviour.}
- {behaviour the bridge now requires — a state derived from X, feedback that must persist, a downstream constraint}.
```

Keep it short — a record can be a single paragraph. The value is recording
*that* a decision was made and *why*, not filling out sections.

## What goes here vs `EXPERIENCE.md`

- **Here:** the decision, the alternatives set aside and why, and the
  behaviour committed to.
- **`EXPERIENCE.md`:** only the reusable *vocabulary* the decision introduces
  (a named Job, flow, state, or feel), as a glossary entry — never the
  decision itself.
