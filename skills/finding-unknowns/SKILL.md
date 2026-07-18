---
name: finding-unknowns
description: Classify the user's unknowns about a piece of work into four quadrants (known knowns, known unknowns, unknown knowns, unknown unknowns) and run the right technique for each. Use when the user says "find my unknowns", "blindspot pass", "unknown unknowns", "what am I missing", is starting work in an unfamiliar domain or codebase area, or when another skill needs the quadrant vocabulary.
---

# Finding Unknowns

The map (prompt, plan, context) is not the territory (the codebase, its real constraints). Every gap between them is an unknown Claude fills by best-guess — find them while they're cheap to fix.

## 1. Situate

Ask, in one short message: phase (before / during / after implementation)? Familiarity with the problem domain and this codebase area? Rough idea, half-formed plan, or full spec? This decides which quadrants dominate — don't run them all every time.

## 2. Scan the territory

Explore the relevant code, docs, and git history before asking anything, so discoverable facts never become questions.

## 3. Work the quadrants

Present a short four-quadrant map, then run the technique that fits each:

- **Known knowns** — what the request pins down. Verify each against the territory; if the code contradicts one, stop and re-scope rather than grinding through questions on a dead plan.
- **Known unknowns** — open questions the user flagged but hasn't answered. Interview them (`/grilling`), architecture-changing questions first.
- **Unknown knowns** — criteria the user would recognize but can't articulate (design, UX feel, naming). Offer reactions, not questions: several divergent options, a throwaway HTML mock with fake data (`/john-superpowers:html-artifact`), or a reference — the best reference is source code, which you read and extract semantics from, even across languages.
- **Unknown unknowns** — the blindspot pass: historical work, potholes, constraints, what "good" looks like in this domain. Teach each one until the user can ask their own next question; whether it becomes a requirement is their call.

## 4. Exit by phase

- **Before** — write an implementation plan leading with the decisions most likely to change (data models, type interfaces, anything user-facing); mechanical work at the bottom. Suggest a fresh session with plan + prototypes as inputs.
- **During** — keep `implementation-notes.md`: on a forced deviation, pick the conservative option, log it under "Deviations", keep going; review deviations with the user afterward — each is a discovered unknown.
- **After** — offer to package plan + notes into a pitch doc for reviewer buy-in.

If a skill in [skill.deps.json](./skill.deps.json) isn't installed, prompt the user to run its install command first.
