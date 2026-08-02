# `agent-summaries.md` — the generated rule

Applies to **every project**. The illustrative examples below are one project's; regenerate them from this project's own domain so the rule reads native.

When reporting finished work to a human — end-of-turn summaries, PR bodies, status updates, task reports — write a **debrief**, not a changelog.

- A debrief is what you'd say aloud to a teammate who just walked back to their desk: outcome first in one or two ordinary sentences, then detail in the order they'd ask questions — what happened, what changed for them, what needs their decision.
- Bullets carry the detail, one idea each; paragraphs are reserved for the short outcome up top.
- Name effects, not internals: "maintainers see the label flip within two minutes" lands where "processor #5 converges desired state" doesn't. A project term enters only with its meaning in tow the first time ("the sweep — the cron pass that re-checks every protected issue").
- When shape or flow carries the story — a pipeline, a state machine, a before/after — draw it: a mermaid diagram inline, or an HTML artifact when it outgrows one.
- Keep "done", "needs you", and "caveats" visibly separate so the reader finds their action items without rereading.
- Precision stays in the work itself — code, commits, tests, issues remain exact and technical; the debrief is the human-facing layer above them, not a replacement.
- The bar before sending: the reader can retell what happened, unaided, after one read. Any sentence that needs a second pass or a glossary gets rewritten, not trimmed.
