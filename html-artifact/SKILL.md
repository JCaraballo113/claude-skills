---
name: html-artifact
description: Generate a single self-contained HTML artifact (inline CSS + inline SVG + optional inline JS) that helps engineers visually reason about a system, feature, or codebase area. Output is one file in docs/ that opens in any browser offline — no external scripts, no CDN fonts, no external images. Use when the user wants to visualize a system, generate a flow diagram, build a reference page or one-pager explainer, document how a state machine / decision tree / data flow works, sanity-check a new feature implementation visually, or asks to "make an HTML artifact" / "visualize X" / "explain X visually". Particularly good for state machines, planner/decision logic, data flows, and architectural overviews, with optional interactive widgets that re-implement live logic in the browser.
---

# html-artifact

Produces a polished, single-file HTML explainer of any system in the user's codebase. The point is to help an engineer (or a stakeholder) **see and reason about** a feature — its model, its flow, its decision logic, its failure modes — without leaving the browser.

Self-contained — opens offline, no CDNs, no fetches.

## Quick start

1. Identify what to visualize.
2. Read the source-of-truth: relevant code files + ADRs + design docs.
3. Pick whichever sections actually help reason about *this* feature (see "Section vocabulary" below — it's a menu, not a checklist).
4. Save the artifact to `docs/<feature>-flow.html` (or wherever fits the repo's convention).
5. Confirm it renders standalone by opening with `file://`.

## Workflow

1. **Decide what the engineer needs to see.** A state-machine-heavy feature wants a flowchart. A planner-heavy feature wants step cards + worked scenarios + maybe an interactive widget. A data-flow feature wants entity boxes + arrows. Don't impose sections the feature doesn't earn.

2. **Section vocabulary** — common reusable shapes. Use what fits; combine or skip freely:
   - **Overview / lede** — one paragraph: what is this, who reads it, where the truth lives.
   - **Model** — domain entities (states, assets, actors) as colored cards.
   - **Flow / state machine** — inline SVG flowchart with labeled edges; back-edges and failure edges visually distinct.
   - **Decision logic** — numbered step cards or branching rules. Show the conditions and outcomes.
   - **Worked scenarios** — table of inputs → outcomes → why. Anchors abstract logic in concrete cases.
   - **Interactive visualizer** — for systems with pure decision logic, re-implement it in inline JS so the engineer can tinker.
   - **Integration / external systems** — cards for each external dependency.
   - **Failure handling** — one card per failure mode: symptom, alert, recovery.
   - **Glossary / domain language** — when the feature has non-obvious terms.

3. **Color palette** — opinionated, tied to *concepts* not aesthetics. See [TEMPLATE.html](TEMPLATE.html) for the full default:
   - `--idle` (green) — resting / yield-bearing / default state
   - `--accept` (blue) — active / accepted / normal operation
   - `--external` (purple) — external system / async work
   - `--warn` (warm red) — alerts, failures, halts
   Rename or add palette roles when the domain demands it.

4. **Diagrams** — inline SVG for state machines, flow charts, decision trees. CSS Grid / flexbox for layout. No external diagramming libraries.

5. **Interactive widgets** — when the system has a pure decision function (a planner, router, fee calculator, state-transition function), re-implement it in vanilla JS inline and let engineers tinker with inputs. Show: the inputs, per-entity derived state, the verdict (color-coded), and which branch fired. Use `BigInt` where the real system does. The widget is often the single most useful section.

6. **Self-contained check** — no `<script src>`, no `<link href>` to external assets, no `fetch()`. Target file size under ~70 KB. Open the saved file with `file://` to verify it renders standalone.

## Layout conventions

- Light theme; system font stack.
- `<main>` with max-width ~1040 px, generous padding.
- Each section is `<h2>` + `.panel` wrapper.
- Pills for status / tags: `.pill.idle`, `.pill.accept`, `.pill.external`, `.pill.warn`.
- Footer references the source-of-truth files (paths, ADR numbers).
- No emojis unless they materially add clarity.

## When to delegate to a sub-agent

A substantial artifact is 30–70 KB of inline code — easier dispatched to a general-purpose sub-agent with:

- The section menu + palette conventions (copy from this SKILL.md).
- Paths to the source-of-truth files the agent must read first.
- The target output path.
- Constraints: single file, no external assets, no emojis, under ~70 KB.
- Verification: confirm sections render + report file size.

Small diffs (renaming a phase, updating an entity, fixing a scenario row) can be done directly with `Edit`.

## Iteration

Common follow-ups, in rough order of frequency:

- **"Update for phase N"** — usually a small diff (alphabet change, scenario rows, status pills).
- **"Add an interactive widget for X"** — re-implement X's pure decision logic inline in JS, render results with the same palette and step-card pattern.
- **"Add a new section"** — drop into the same `<h2>` + `.panel` shape.
- **"Make scenarios interactive"** — convert a static table into clickable presets that load into a visualizer widget.

## Template

A minimal starter is in [TEMPLATE.html](TEMPLATE.html). It includes the default palette, layout primitives, and a few example section shapes you can pick from. **Treat it as a buffet, not a checklist.**
