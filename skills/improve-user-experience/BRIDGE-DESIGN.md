# Bridge Design

When the user wants to explore alternative bridges for a chosen gulf, use this parallel sub-agent pattern. Based on "Design It Twice" (Ousterhout) — your first idea is unlikely to be the best, and experience is cheap to vary in design and expensive to vary in code.

Uses the vocabulary in [LANGUAGE.md](LANGUAGE.md); closing tactics by gulf type are in [BRIDGING.md](BRIDGING.md).

**Requires Pencil + `impeccable`** (see the Required tooling section of [SKILL.md](SKILL.md)). The output of this pattern is real `.pen` design variants the user can see and compare — never written interface specs. If the tooling isn't available, stop and prompt the user to install it before running this; don't substitute prose mockups.

## Process

### 1. Frame the gulf

Before spawning sub-agents, write a user-facing framing of the chosen candidate:

- The **Job** the user is trying to do, and exactly where the gulf opens in the flow.
- Which gulf it is (execution / evaluation) and what's missing (signifier, feedback, model match).
- The constraints any bridge must respect — the states it must cover (empty, loading, error, success, the **precondition already satisfied**, and the **action in flight**), the surrounding flow it can't break, the **conceptual model** it must match.
- A reference frame: a `get_screenshot` of the current designed (or built) screen, so the user sees the "before" while the variants are designed.

Show this to the user, then proceed to Step 2. The user reads and thinks while the sub-agents work in parallel.

### 2. Spawn sub-agents

Spawn 3+ sub-agents in parallel using the Agent tool. Each produces a **radically different** bridge for the same gulf, **designed in Pencil** (`batch_design` against the schema from `get_editor_state`) and held to `impeccable`'s bar. Give each a different design constraint so they don't converge:

- Agent 1: **Remove the gulf entirely** — can a default, inference, or prior choice make the step vanish? Aim for the bridge the user never has to cross.
- Agent 2: **Signify in place** — keep the step, but make the affordance perceivable exactly where the Job brings the user's attention. Minimal new surface.
- Agent 3: **Richest legibility** — maximise feedback and visible state; optimise for the user always knowing what happened and what's next.
- Agent 4 (if applicable): **Re-model** — restructure so the action sits where the user's existing conceptual model already expects it, even if that means moving it across the flow.

Give each sub-agent a self-contained brief: the gulf framing, the file/frame paths in the `.pen`, the states to cover, and both the [LANGUAGE.md](LANGUAGE.md) vocabulary and the project's `CONTEXT.md` domain nouns, so every variant names things consistently.

To keep concurrent edits to the one `.pen` from colliding, **pre-create one empty artboard per agent at known, non-overlapping coordinates** and require each agent to build only inside its assigned frame — no `FindEmptySpace`, no inserts at the document root. When that isolation isn't practical, design the variants sequentially yourself rather than risk a spatial race.

Each sub-agent outputs:

1. A `.pen` design of the bridge, covering every required state, polished to `impeccable`'s bar.
2. A `get_screenshot` of each state.
3. One line on which gulf it closes and how (the tactic from [BRIDGING.md](BRIDGING.md)).
4. The friction delta — decisions / steps / round-trips before vs. after.
5. Trade-offs — what it costs the *other* Jobs sharing this surface.

### 3. Present and compare

Present the variants sequentially — show each one's screenshots so the user absorbs it — then compare them in prose. Contrast by:

- **Friction removed** — how much of the gulf each one actually deletes vs. signposts.
- **Cost to neighbours** — what each adds to the surface every other Job pays for.
- **Model fit** — which sits most naturally in the user's existing **conceptual model**.

After comparing, give your own recommendation: which bridge is strongest and why. If elements combine well — Agent 1's removal with Agent 3's feedback on the residual step — propose the hybrid and design it. Be opinionated; the user wants a strong read, not a gallery.

The chosen design is the deliverable, together with a **design decision record** ([DECISION-RECORD.md](DECISION-RECORD.md)): the comparison you just made — the chosen bridge, and the runners-up with the reason each lost — is exactly its _Considered options_. It becomes the spec whatever implements designs in the project builds from — implementation is out of this skill's scope.
