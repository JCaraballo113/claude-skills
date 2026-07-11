---
name: to-design-tickets
description: Break a design spec or conversation into per-screen design tickets — each one screen all the way through the variant matrix, with artifact-dependency blocking edges — published to the configured tracker. The design-work mirror of /to-tickets.
disable-model-invocation: true
---

# To Design Tickets

Break design work into tickets sliced by the rules below. Publish them exactly as `/to-tickets` publishes (local files or real tracker, blockers first, `ready-for-agent`), and work the frontier with `/john-superpowers:implement-design`, clearing context between tickets.

## Process

### 1. Gather context

Work from the conversation; if the user passes a reference (a design spec path, an issue number or URL), fetch it and read its full body and comments.

### 2. Read the designed state

The project's design-system rule (`.claude/rules/design-system.md`) and the `.pen` file (Pencil MCP). Ticket titles and descriptions use the project's domain vocabulary.

### 3. Draft slices

<design-slice-rules>

- The atom is **one screen, all the way through**: template pass → page pass with the extremes → states → every variant in the project's matrix. Never a pass, a theme, or a breakpoint as its own ticket.
- The **matrix is a hard gate**: acceptance criteria are generated from the design-system rule, and a ticket cannot close until every variant, state, and extreme exists. A too-big ticket splits by screen region — never by variant.
- A ticket closes **demoably**: screenshots of every variant posted for review.
- A multi-screen Job becomes one ticket per screen, grouped under the Job — the Job itself creates no edges.

</design-slice-rules>

### 4. Blocking edges — artifact dependencies only

- **Containment**: the shell/template a screen sits inside gates it.
- **Component introduction**: the ticket that births a shared component gates the tickets that reuse it. Components are born inside screen tickets — never a pre-built-library ticket.
- **Flow adjacency is never an edge**: a flow's screens design in parallel under their shared template.

### 5. Wide refactors go expand–contract

Trigger: blast radius beyond the screens in flight — a new matrix axis, a shared-component reshape, a token retrofit. Sequence: **expand** (introduce the axis/component/tokens beside the existing frames, nothing breaks) → **migrate** (one ticket per screen, blocked by the expand) → **contract** (delete legacy frames/components/tokens, blocked by every migrate ticket).

**Exempt**: theme-bound variable edits — Pencil propagates them atomically; not even a ticket.

### 6. Quiz the user

Present the breakdown as `/to-tickets` does — title, blocked-by, what it delivers — and iterate on granularity and edges until approved, then publish.
