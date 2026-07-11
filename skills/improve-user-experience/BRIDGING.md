# Bridging

How to close a gulf safely, given its type. Assumes the vocabulary in [LANGUAGE.md](LANGUAGE.md).

A bridge **removes** the gulf. It does not document it. Help text, tooltips, and onboarding tours are labels stuck over a gulf the user still has to cross — they are not bridges. Reach for them only when the gulf genuinely cannot be removed, and say so out loud.

## Classify the gulf first

Every candidate is one of two gulfs (occasionally both). The type determines the tactic.

### Gulf of Execution — "how do I do this?"

The user has the **Job** but can't find or form the action. The bridge brings the action to the intention. In order of preference:

1. **Remove the step.** The cheapest bridge is the one the user never has to cross. Can a smart default, an inferred value, or a prior choice make the step disappear? Deleting a decision beats explaining it.
2. **Add the missing signifier.** The **affordance** exists but nothing advertises it. Make it perceivable, and place it where the **Job** brings the user's attention — not in a menu they have no reason to open.
3. **Match the conceptual model.** The action exists and is signified, but it's filed under a model the user doesn't share. Relabel, regroup, or reorder so it sits where the user already expects it.
4. **Collapse a sequence.** Several steps that only the system cares about become one step the user cares about. Friction: N decisions → 1.

### Gulf of Evaluation — "did that work? what now?"

The user acted but can't perceive or interpret the result. The bridge makes the system's state legible. In order of preference:

1. **Give immediate feedback.** The action changed state but said nothing. Make the result perceptible at the moment and place of the action — optimistic UI, a state change, motion, a disabled control flipping. **Feedback** is any perceptible result, not only a toast.
2. **Show the state, don't announce it.** Persistent status the user can read at any time beats a transient message they may miss. Where is this in the flow, what's left, what happened — visible, not recalled.
3. **Make the next action obvious.** Evaluation isn't done until the user knows what to do next. Every terminal state (success, error, empty) names its next step; an error with no recovery action is an evaluation gulf, not a bug report.

When a feedback moment can carry personality — an acknowledgment, a celebration, a wait, an error — [DELIGHT.md](DELIGHT.md) has the timing budgets and restraint rules.

## Validate the gulf is real

- **One confused user is a hypothesis; a pattern of hesitation is a gulf.** The flow must force the gulf on essentially everyone doing the **Job**, not one imagined user with one unusual mental model. If only a minority hit it, the bridge may add **friction** for the majority — weigh that.
- **Don't bridge a gulf no one crosses.** A signifier for an affordance no one wants is noise. Confirm the **Job** is real before building the bridge to it.

## Bridging strategy: remove, don't paper over

- A bridge **changes the design** so the gulf is gone. If after your change the user still has to read an explanation to cross it, you papered over it — the gulf is still there.
- **Cover every state the bridge touches.** A bridge that only works in the happy path opens a new evaluation gulf in the error, empty, and loading states. Design all of them (this is where layering `impeccable` over the Pencil design earns its keep).
- **Don't widen one gulf to close another.** Adding an **affordance** to close an execution gulf can clutter the surface and raise the cost of *every* Job. Prefer bridges that subtract.
- **The test survives the redesign.** The win is measured against the **hesitation test**: walk the bridged flow as a first-timer who can't ask anyone, and confirm the pause is gone — not merely explained.
