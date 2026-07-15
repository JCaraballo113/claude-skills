---
name: autopilot-implement
description: The model-invocable form of /implement, for autopilot's per-item agents. Use when an autopilot brief's suggested-skills section says to run /autopilot-implement.
---

Implement the work described by the user in the spec or tickets.

Use /tdd where possible, at pre-agreed seams.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

Once done, use /code-review to review the work and fix its findings.

Commit your work by pathspec — only the files you changed — to the branch you were briefed on. Then attach a git note (`git notes --ref=autopilot add -m "…" HEAD`) recording your agent label and your notes for the reviewer: caveats, judgment calls, deviations from the design or spec, follow-ups.

Report a terse result — the branch and commit, the files you changed, and the typecheck / test / review status. Your prose lives in the note, not the report; the orchestrator validates the commit and fast-forwards it into the target branch.
