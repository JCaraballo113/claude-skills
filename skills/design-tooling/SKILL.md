---
name: design-tooling
description: Design-first frontend tooling — every UI is designed in Pencil (.pen files via the Pencil MCP) with the impeccable skill governing design quality; design precedes implementation. Creates the project's designs/ file, runs impeccable init, and encodes the convention in the agent docs. Use when the user says "setup design tooling", or via setup-tooling on frontend projects. Skip for backend/API projects.
---

# Design Tooling

UI is **always designed in Pencil** (a `.pen` design file driven through
the Pencil MCP — never Read/Grep on `.pen` files) with the **`impeccable`**
skill governing design quality. Design first, implement second.

Check availability first — `impeccable` in the available-skills list
(any scope, possibly namespaced), Pencil MCP tools connected. Prompt the
user to install anything missing with its command from
[skill.deps.json](./skill.deps.json); don't install these silently.

Once both are present:

- Create the project's `.pen` file under `designs/` and reference it from
  the agent instructions.
- Run `impeccable init` (or note it as the next step) so PRODUCT.md /
  DESIGN.md capture the product context the design work anchors to.
- Encode the convention in AGENTS.md / CLAUDE.md: designs live in
  `designs/<app>.pen` via the Pencil MCP; `/impeccable` governs design
  quality; design precedes implementation.
- Design each screen in two passes, template then page: first the
  structure (layout, dynamic-content bounds), then real representative
  content including the extremes named in the design-system agent rule
  (`/john-superpowers:agent-rules`). A screen isn't designed until its
  extremes are mocked.
- Mock repeated and data-driven content with code-on-canvas Script
  nodes, per the same design-system agent rule.
