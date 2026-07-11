# Language

Shared vocabulary for every suggestion this skill makes. Use these terms exactly — don't substitute "confusing," "clunky," "intuitive," "clean," or "smooth." Consistent language is the whole point. The terms come from Don Norman's gulf model (*The Design of Everyday Things*); the skill is to UX what the gulf model is to interaction design.

## Terms

**Job**
What the user is trying to accomplish, stated in their terms and their outcome — "get a refund for an order that arrived late," not "open the returns drawer." Deliberately system-agnostic: a Job exists before the user knows which screen serves it.
_Avoid_: task, use case, feature (all framed from the system's side, not the user's intention).

**Gulf of Execution**
The distance between the user's intention (their Job) and the actions the interface makes available. Felt as "how do I do this?" Closed by **signifiers** that advertise the right **affordance**, by smart defaults, and by removing steps.
_Avoid_: "the user is confused" — name *which* gulf and *which* missing element.

**Gulf of Evaluation**
The distance between the system's actual state and the user's ability to perceive and interpret it. Felt as "did that work? what state am I in now?" Closed by **feedback**.
_Avoid_: "unclear," "no indication" — say "evaluation gulf: no feedback after X."

**Signifier** _(from Norman)_
A perceptible cue that announces an action is possible and where. The cue, not the control: a button's affordance is "click me"; its signifier is whatever makes the user perceive that. An affordance with no signifier does not exist to the user.
_Avoid_: using "affordance" when you mean the cue.

**Affordance**
An action the interface actually permits. The possibility; the **signifier** advertises it. A hidden affordance is unreachable regardless of how powerful it is.

**Feedback**
The system's perceptible response confirming what an action did and what state resulted. Spans the **Gulf of Evaluation**. An action with no feedback is an evaluation gulf by construction.
_Avoid_: "confirmation message" (too narrow — feedback is any perceptible result, including state change, motion, sound, or disabled controls).

**Conceptual model**
The model of how the system works. The design *projects* a model; the user *forms* one (their mental model). Good UX makes the projected model match what the user already believes, so they don't have to relearn it.
_Avoid_: using "mental model" for the system's side — reserve it for the user's.

**Friction**
Effort, decisions, waiting, or steps the user spends that don't advance the **Job**. The quantity this skill reduces. Measurable: count the decisions, the taps, the seconds.
_Avoid_: "clunky," "heavy," "painful" — name the friction (3 decisions, 2 round-trips, 1 dead end).

**Bridge**
A design change that closes a gulf so the user no longer crosses it themselves. The verb of this skill (the analog to "deepen").
_Avoid_: calling a tooltip or a tour a bridge — those document a gulf, they don't close it.

## Principles

- **Gulfs belong to the design, not the user.** When a user hesitates, the design left a gulf. Name the gulf (execution or evaluation) and the missing element (signifier, feedback, model match) — never label the user confused.
- **The hesitation test.** Walk the flow as a first-time user who can't ask anyone. Every pause is a gulf: "how do I do this?" = execution, "did that work?" = evaluation. Where they pause, there's a bridge to build.
- **Signifiers, not affordances, are the surface.** A user acts only on what they can perceive. An affordance no signifier advertises does not exist to them — however capable it is.
- **Feedback closes the loop.** Every action needs a perceptible result. An action with no feedback is an evaluation gulf, no matter how well it worked internally.
- **Match the user's conceptual model.** Don't make the user learn the system's model; project a model that matches what they already believe. The mismatch *is* the gulf.
- **One confused user is a hypothesis; a pattern of hesitation is a gulf.** Don't bridge a gulf no real user crosses. Validate it's a pattern (the flow forces it on everyone) before building.

## Relationships

- A **Job** is what the user intends; the **Gulf of Execution** sits between the Job and the available **Affordances**.
- **Signifiers** advertise **Affordances**. A user reaches an affordance only through its signifier.
- **Feedback** spans the **Gulf of Evaluation** between the system's state and the user's perception of it.
- The **Conceptual model** mismatch is what widens both gulfs; aligning it narrows them.
- A **Bridge** closes a gulf and reduces **Friction**.

## Rejected framings

- **Aesthetics _instead of_ gulf-closing**: visual polish alone doesn't close a gulf — this skill's lens is execution and evaluation gulfs, not styling. But polish isn't optional either: every bridge is designed in Pencil and held to `impeccable`'s bar (both required). Close the gulf *and* ship it polished — don't mistake a pretty screen for a bridged one.
- **"More features"**: each new **affordance** widens the **Gulf of Execution** unless it's signified and fits the **conceptual model**. Adding capability is not the same as improving experience.
