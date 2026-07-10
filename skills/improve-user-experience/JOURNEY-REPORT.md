# Journey Report Format

The UX review is rendered as a single self-contained HTML file in the OS temp directory. Tailwind and Mermaid both come from CDNs. Mermaid handles graph-shaped journeys reliably; hand-built divs and inline SVG handle the more editorial visuals (a gulf drawn as an actual gap, a friction tally, a before/after step count). Mix the two — don't lean on Mermaid for everything, it'll start to look generic.

This is the **phase-2** artifact: it surfaces many candidates lightly. Full Pencil design work waits until phase 3, on the chosen bridge only. So the "before" here can embed a real frame exported from the `.pen` (`export_nodes` / `get_screenshot`) or a screenshot of the built screen; the "after" stays a lightweight sketch of the bridge, not a finished design.

## Scaffold

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <title>UX review — {{product name}}</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script type="module">
      import mermaid from "https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs";
      mermaid.initialize({ startOnLoad: true, theme: "neutral", securityLevel: "loose" });
    </script>
    <style>
      /* small custom layer for things Tailwind doesn't cover cleanly:
         the gulf gap, hand-drawn-feeling arrows, hesitation markers. */
      .gulf { background: repeating-linear-gradient(45deg, #fee2e2, #fee2e2 6px, #fff 6px, #fff 12px); }
      .pause { stroke: #dc2626; }
      .bridged { background: linear-gradient(135deg, #064e3b, #065f46); }
    </style>
  </head>
  <body class="bg-stone-50 text-slate-900 font-sans">
    <main class="max-w-5xl mx-auto px-6 py-12 space-y-12">
      <header>...</header>
      <section id="candidates" class="space-y-10">...</section>
      <section id="top-recommendation">...</section>
    </main>
  </body>
</html>
```

## Header

Product name, date, and a compact legend: solid box = step, hatched gap = gulf, red marker = a hesitation point ("how?" or "did it work?"), dark box = bridged step. No introduction paragraph — straight into the candidates.

## Candidate card

The diagrams carry the weight. Prose is sparse, plain, and uses the glossary terms ([LANGUAGE.md](LANGUAGE.md)) without ceremony.

Each candidate is one `<article>`:

- **Title** — short, names the bridge (e.g. "Default the refund reason — delete the step").
- **Badge row** — recommendation strength (`Strong` = emerald, `Worth exploring` = amber, `Speculative` = slate), plus a tag for the gulf type (`execution` / `evaluation`).
- **Flow** — the screens/steps/states involved, `font-mono text-sm`.
- **Before / After diagram** — the centrepiece. Two columns, side by side. "Before" embeds the real `.pen` frame or screenshot with the gulf and hesitation point marked; "after" sketches the bridge. See patterns below.
- **Gulf** — one sentence: which **Job**, execution or evaluation, what's missing.
- **Bridge** — one sentence: what changes so the user stops crossing it.
- **Wins** — bullets, ≤6 words each, in glossary terms. e.g. "friction: 3 decisions → 0", "signifier where the Job looks", "feedback closes the loop".
- **EXPERIENCE.md callout** (if applicable) — one line in an amber-tinted box.

No paragraphs of explanation. If the diagram needs a paragraph to be understood, redraw the diagram.

## Diagram patterns

Pick the pattern that fits the candidate. Mix them. Don't make every diagram look the same — variety is part of the point.

### Mermaid journey / flow (the workhorse)

Use a Mermaid `flowchart` when the point is "the user moves step → step → and stalls here." Wrap it in a Tailwind-styled card. Style with classDef to mark the hesitation point red and the bridged step dark.

```html
<div class="rounded-lg border border-slate-200 bg-white p-4">
  <pre class="mermaid">
    flowchart LR
      A[Find order] --> B[Open returns]
      B --> C{Pick reason?}
      C -.how?.-> D[Submit]
      classDef pause stroke:#dc2626,stroke-width:2px;
      class C pause
  </pre>
</div>
```

Sequence diagrams work well for evaluation gulfs: "before: action → silence; after: action → state change."

### The gulf as a literal gap (hand-built)

Two step-boxes with a hatched `.gulf` band between them that the user has to leap. Label the band with the question the user is stuck on ("how do I do this?" / "did that work?"). The "after" closes the gap into one continuous bar. Mermaid won't render this with the right weight — use divs + an SVG arrow.

### Friction tally (good for "too many steps")

A row of small boxes, one per decision/step/round-trip the **Job** currently costs. Before: a long row, some greyed as "system cares, user doesn't." After: the row collapses to the one or two the user actually cares about. Put the count in a big numeral.

### Before/after screen pair (good for missing signifier / feedback)

The exported `.pen` frame or built screenshot on the left with the absent **signifier** or missing **feedback** circled; a sketch on the right showing it present. Best when the gulf is "the affordance is there but nothing advertises it."

## Style guidance

- Lean editorial, not corporate-dashboard. Generous whitespace. Serif optional for headings (`font-serif` works well with stone/slate).
- Colour sparingly: one accent (emerald or indigo) plus red for hesitation points and amber for warnings.
- Keep diagrams ~320px tall so before/after sits comfortably side by side without scrolling.
- Use `text-xs uppercase tracking-wider` for step labels inside diagrams — they should read as schematic, not as UI.
- The only scripts are the Tailwind CDN and the Mermaid ESM import. The report is otherwise static — no app code, no interactivity beyond Mermaid's own rendering.

## Top recommendation section

One larger card. Bridge name, one sentence on why, anchor link to its card. That's it.

## Tone

Plain English, concise — but the experience nouns and verbs come straight from [LANGUAGE.md](LANGUAGE.md). Concision is not an excuse to drift.

**Use exactly:** Job, gulf of execution, gulf of evaluation, signifier, affordance, feedback, conceptual model, friction, bridge.

**Never substitute:** confusing, clunky, intuitive, smooth (mood words) · "the button" (for signifier) · "more features" (for a bridge).

**Phrasings that fit the style:**

- "Execution gulf at the reason step — no default, the user has to decide."
- "Action submits, but no feedback — evaluation gulf."
- "Bridge: infer the reason; delete the decision."
- "Friction: 3 decisions → 0."

**Wins bullets** name the gain in glossary terms: *"signifier placed where the Job looks"*, *"feedback closes the evaluation gulf"*, *"friction: 3 decisions → 0"*. Don't write *"cleaner"* or *"more intuitive"* — those aren't in the glossary and don't earn their place.

No hedging, no throat-clearing, no "it's worth noting that…". If a sentence could be a bullet, make it a bullet. If a bullet could be cut, cut it. If a term isn't in [LANGUAGE.md](LANGUAGE.md), reach for one that is before inventing a new one.
