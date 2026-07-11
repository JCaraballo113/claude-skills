---
name: implement-design
description: Implement a design ticket or spec in Pencil — the design-work mirror of /implement. Two passes per screen, every state and matrix variant, verified by screenshot against the design-system rule and impeccable, closed demoably.
disable-model-invocation: true
---

# Implement Design

Implement the design work described in the ticket or spec. The deliverable is `.pen` frames, not code.

Preflight: Pencil MCP connected and `impeccable` installed — prompt the user with the install commands in [skill.deps.json](./skill.deps.json) if not; never fall back to unpolished mockups.

- Design in Pencil (`get_editor_state({ include_schema: true })` first, then `batch_design`), following the project's design-system rule: two passes per screen, the extremes, every state, every matrix variant.
- Verify the way `/tdd` verifies: `get_screenshot` each variant as it lands and check it against the ticket's acceptance criteria, the design-system rule, and `impeccable`'s bar — iterate per screen, don't batch the checking to the end.
- Close demoably: post the screenshots of every variant to the ticket.
- Commit the `.pen` to the current branch, using the project's `(design):` commit prefix where that convention is established.
