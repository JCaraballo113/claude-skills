---
name: improve-user-experience
description: Find bridging opportunities in a product, informed by the intended experience in EXPERIENCE.md and the domain language in CONTEXT.md. Use when the user wants to improve UX, reduce friction in a flow, find where users get stuck or confused, or close the gap between what the product does and what it should feel like.
---

# Improve User Experience

Surface experiential friction and propose **bridging opportunities** — changes that close a **gulf** the user currently has to cross on their own. The aim is a product where a first-time user can form the right intention and confirm the result without help.

## Required tooling

Design is how this skill models experience, and it holds that design to a quality bar — so two dependencies are **required**, not optional:

- **Pencil MCP** — the `.pen` design editor. Every read of the designed experience and every bridge you produce goes through it. Install: <https://www.pencil.dev/>
- **`impeccable` skill** — the visual-craft bar every bridge design is held to. Layered on top of the design, never a substitute for closing the gulf. Install: `npx skills add https://github.com/pbakaus/impeccable --skill impeccable`

**Preflight before any design work.** If the Pencil MCP tools aren't connected or the `impeccable` skill isn't installed, **stop and ask the user to install/connect them** (install steps above) before continuing — do not fall back to hand-drawn mockups or unpolished designs. (A missing `.pen` *file* in the project is fine — that's a project state, not a missing dependency; you'll create one in phase 3.)

## Glossary

Use these terms exactly in every suggestion. Consistent language is the point — don't drift into "confusing," "clunky," "intuitive," or "clean." Full definitions in [LANGUAGE.md](LANGUAGE.md).

- **Job** — what the user is trying to accomplish, in their terms and outcome ("get a refund for a late order"), not the feature or screen.
- **Gulf of Execution** — the distance between the user's intention and the actions the interface offers. Felt as "how do I do this?"
- **Gulf of Evaluation** — the distance between the system's actual state and the user's ability to perceive and interpret it. Felt as "did that work? what now?"
- **Signifier** — a perceptible cue announcing that an action is possible, and where. Distinct from the affordance it advertises.
- **Affordance** — an action the interface actually permits.
- **Feedback** — the system's perceptible response confirming what an action did and what state resulted.
- **Conceptual model** — the model of how the system works that the design projects, and the one the user forms. Good UX makes them match.
- **Friction** — effort, decisions, waiting, or steps the user spends that don't advance the Job. The quantity being reduced.
- **Bridge** — a design change that closes a gulf so the user no longer crosses it themselves. The verb of this skill.

Key principles (see [LANGUAGE.md](LANGUAGE.md) for the full list):

- **Gulfs belong to the design, not the user.** When a user hesitates, the design left a gulf — name it, don't label the user confused.
- **The hesitation test**: walk the flow as a first-timer who can't ask anyone. Every pause is a gulf — "how?" = execution, "did it work?" = evaluation.
- **One confused user is a hypothesis; a pattern of hesitation is a gulf.** Validate the gulf is real before building the bridge.

This skill is _informed_ by the project's intended experience. `EXPERIENCE.md` says what the product should do and feel like; `CONTEXT.md` names the domain. The skill finds where the built experience falls short of the intended one — and never edits `EXPERIENCE.md` itself without explicit human approval: it is human-owned, the source of truth code conforms to, not the reverse.

## Process

### 1. Explore

Read `EXPERIENCE.md` in full and the relevant `CONTEXT.md` domain terms first. They are the intended experience and the names for it — the bar you're measuring against.

**The design is the second source of the bar.** `EXPERIENCE.md` states the intended experience; the `.pen` design *shows* it. Open it with Pencil — call `get_editor_state({ include_schema: true })` first (`.pen` files are encrypted: Pencil tools only, never Read or Grep), then read the designed flow with `batch_get` and capture frames with `get_screenshot` / `export_nodes` so the report can show the real designed experience, not a hand-drawn approximation. This unlocks a gulf source the prose misses: **drift between the designed experience and the built one** — where implementation quietly diverged from the design is often where the richest gulfs hide. If the project has no `.pen` design *yet*, there's nothing to compare against — work from `EXPERIENCE.md` plus the built app, and you'll create the design in phase 3.

Then walk the actual user flows in the area you're touching. Prefer **driving the running app** so you feel the friction yourself — start it however this project runs and move through the flow as a first-time user (browser automation, where available, lets a sub-agent walk it for you). When the app isn't runnable, trace the flow through the code with the Agent tool. Don't follow rigid heuristics — move through the product organically and note where you experience friction:

- Where does the user have to guess **how** to start a Job — no signifier for the affordance that does it? (execution gulf)
- Where does the user act and get no **feedback** — can't tell if it worked or what state they're now in? (evaluation gulf)
- Where does the product's **conceptual model** contradict what the user already believes, forcing them to relearn it?
- Where does a Job take more **friction** — steps, decisions, waiting — than the value it returns?
- Where does an error leave the user stranded with no next action?
- Where does the **built** screen diverge from the **designed** one in the `.pen` — a gulf introduced by drift, not by the design?

Apply the **hesitation test** at every step: would a first-time user pause to ask "how do I do this?" or "did that work?" Each pause is a candidate. Confirm the gulf is real (a pattern, not one imagined user) before proposing a bridge.

### 2. Present candidates as an HTML report

Write a self-contained HTML file to the OS temp directory so nothing lands in the repo. Resolve the temp dir from `$TMPDIR`, falling back to `/tmp` (or `%TEMP%` on Windows), and write to `<tmpdir>/ux-review-<timestamp>.html` so each run gets a fresh file. Open it for the user — `xdg-open <path>` on Linux, `open <path>` on macOS, `start <path>` on Windows — and tell them the absolute path.

The report uses **Tailwind via CDN** for layout and **Mermaid via CDN** for diagrams where a journey/flow/sequence reliably communicates the structure. Mix Mermaid with hand-crafted CSS/SVG visuals — use Mermaid when the flow is graph-shaped (user journeys, state transitions, step sequences), and hand-built divs/SVG for something more editorial (a gulf rendered as an actual gap the user leaps, a friction tally, a before/after step count). Each candidate gets a **before/after visualisation**. Be visual.

For each candidate, render a card with:

- **Flow** — which screens/steps/states are involved
- **Gulf** — which Job, and whether it's a Gulf of Execution or Evaluation; what's missing (signifier, feedback, model match)
- **Bridge** — plain English description of what would change so the user stops crossing the gulf
- **Wins** — explained in glossary terms, and how the hesitation test improves
- **Before / After diagram** — side-by-side, showing the gulf and the bridge. The "before" can embed a real frame exported from the `.pen` design (or a screenshot of the built screen); the "after" stays a lightweight sketch — full Pencil design work waits until phase 3, on the chosen bridge only
- **Recommendation strength** — one of `Strong`, `Worth exploring`, `Speculative`, rendered as a badge

End the report with a **Top recommendation** section: which bridge you'd build first and why.

**Use CONTEXT.md vocabulary for the domain, and [LANGUAGE.md](LANGUAGE.md) vocabulary for the experience.** Talk about "the Job: return an item" and "the execution gulf at the payment step" — not "the confusing button" or "the bad onboarding."

**EXPERIENCE.md conflicts**: if a candidate contradicts the documented intended experience, only surface it when the friction is real enough to warrant revisiting that intent. Mark it clearly in the card (e.g. a warning callout: _"contradicts EXPERIENCE.md §Onboarding — but worth reopening because…"_). Don't list every theoretical change the doc rules out.

See [JOURNEY-REPORT.md](JOURNEY-REPORT.md) for the full HTML scaffold, diagram patterns, and styling guidance.

Do NOT design the bridge in detail yet. After the file is written, ask the user: "Which of these would you like to explore?"

### 3. Grilling loop

Once the user picks a candidate, drop into a grilling conversation. Walk the design tree with them — the user's Job, exactly where the gulf opens, the shape of the bridge, which signifier or feedback or model change closes it, and which states (empty, error, loading, success) the bridge must cover.

**Model the bridge in Pencil, held to `impeccable`'s bar — don't describe it in prose.** Experience is designed, not specified — once the bridge's shape is settled, build it as an actual `.pen` design (`batch_design` against the schema from `get_editor_state`), covering every state the grilling surfaced. Layer `impeccable` over the design for visual hierarchy, motion, accessibility, and edge states, so the bridge ships polished, not merely functional. Then show the user a `get_screenshot`. The design _is_ this skill's deliverable: it ends at an approved `.pen` design, which becomes the spec whatever implements designs in the project builds from. Implementation is out of scope. When several bridge shapes are in play, design them as separate variants — see [BRIDGE-DESIGN.md](BRIDGE-DESIGN.md) for the design-the-bridge-twice pattern (parallel sub-agents, real `.pen` frames, not written specs).

Side effects happen inline as decisions crystallize:

- **Surfaced a genuinely new _domain noun_ (a thing the business has — an Order, a Cart, a Subscription)?** Add it to `CONTEXT.md` — the shared domain glossary — as a one-line entry: the term, then a sentence defining it in the domain's own words. Create the file lazily if it doesn't exist. This is the _only_ reason a UX session touches `CONTEXT.md`.
- **Named a Job or experience concept (a user intention, a flow, a feel)?** Record it in `EXPERIENCE.md`, never `CONTEXT.md` — that doc is the UX context. Keeping Jobs out of the shared glossary is what stops the experience and architecture lenses polluting each other. Human-approved, like any `EXPERIENCE.md` edit.
- **The bridge implies new intended behaviour not yet in `EXPERIENCE.md`?** Propose the addition and show the exact wording — but **only apply it with explicit human approval** (`EXPERIENCE.md` is human-owned — no agent edits it without sign-off). It is the source of truth; code conforms to it, not the reverse.
- **User rejects the candidate with a load-bearing reason?** Offer to record it, framed as: _"Want me to note this in EXPERIENCE.md so future UX reviews don't re-suggest it?"_ — again, human-approved. Only offer when the reason would actually be needed by a future explorer; skip ephemeral or self-evident ones.
- **Want to explore alternative bridges for the same gulf?** See [BRIDGE-DESIGN.md](BRIDGE-DESIGN.md).

See [BRIDGING.md](BRIDGING.md) for how to close a gulf safely given its type — execution vs evaluation tactics, and why a bridge removes the gulf rather than papering over it with help text.
