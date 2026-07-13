---
name: agent-rules
description: Encode working conventions as one rule file per concern in .claude/rules/ — testing (TDD, happy/negative path, coverage as discovery), migrations, design-system (atomic design vocabulary, content extremes, motion), code-review, sub-agents (model tiering), finding-unknowns — generalized to the project at hand, any ecosystem. Use when the user says "setup agent rules", "encode the agent rules", or via setup-tooling.
---

# Agent Rules

Encode the working conventions as one rule file per concern in
`.claude/rules/` — checked in, loaded as project instructions every
session. Write them generalized to the project at hand (its actual
domains, scripts, and stack), never with another app's specifics.

Three rules gate on a skill being installed. The **installed-check** —
inline this wording into each generated rule that uses it, so the rule
stands alone in the target repo: *the skill counts as installed when it
appears in the available-skills list in any scope — global, project, or
plugin — possibly namespaced (e.g. `john-superpowers:finding-unknowns`);
a name match under any namespace counts, and the list beats guessing
filesystem paths.*

The rules:

- **`testing.md`** (every project): features develop test-first (red → green → refactor)
  via the `tdd` skill; the generated rule tells the agent that when the
  skill fails the installed-check, it prompts the user to install it
  (`npx skills add https://github.com/mattpocock/skills --skill tdd`)
  rather than improvising the loop. Every test file (Vitest in JS; the
  stack's runner elsewhere) groups specs under
  `describe("Happy path")` and `describe("Negative path")`; when one file
  covers several surfaces, nest the pair inside each surface's describe.
  Happy path = the documented, intended behavior. Negative path =
  everything that must fail well (auth rejections, validation errors,
  conflicts, malformed data, downstream failures), asserting the
  observable refusal — status, unchanged state, audit entry — not
  internals. A surface with no negative specs is a smell. Spec files
  mirror the domain seams of the source: group into `tests/<domain>/`
  folders as domains accumulate — never one flat pile; a lone spec may
  sit flat until its domain grows a second file. When installing into a
  repo that already has flat spec files, grandfather them by name in the
  rule: new specs go in domain folders; legacy files move
  opportunistically when touched, never in bulk. Shared infrastructure
  lives in `tests/helpers/`. Coverage: non-trivial features land with
  tests covering their happy and negative paths — not incidental line
  coverage. Measure with a `test:coverage` script (in JS:
  `vitest run --coverage`); before calling feature work done, check that
  the files added or changed show up covered — an important module at
  ~0% is a gap to close, not a statistic to report. Coverage is a
  discovery tool, not a gate: there is no numeric threshold to game, and
  untestable-as-written code that blocks coverage gets refactored, not
  excluded.
- **`migrations.md`** (only when the project has a DB): local dev is
  push-based; deployed environments are migration-based (in JS:
  Drizzle's `db:push` / `db:generate` / `db:migrate`). Generate the
  migration once the shape is final, and it lands **in the same
  commit** as the schema change — a schema edit without its migration
  silently never reaches deployed environments. Never edit a committed
  migration; add a new one. The deploy pipeline runs the migrations
  against that environment's database before building.
- **`design-system.md`** (frontend projects only): atomic design's five
  levels — atoms, molecules, organisms, templates, pages — are the shared
  vocabulary for component **granularity**, used in design conversations,
  critiques, and PR discussion. Never as folder names: folders stay
  domain-based, and components are named for what they are (`SearchForm`,
  not `MoleculeSearch`). Atoms are mostly the vendored primitives (in JS
  projects, the shadcn components in `components/ui/`); everything above
  them earns extraction the usual way — the model is concurrent, not
  linear, so never pre-build a component library. The vocabulary answers
  "how big is this?", not "should this be shared?" — a header
  accumulating search, nav, and session state is an organism pretending
  to be a molecule: split it. Templates prove content *structure*; pages
  prove it against real content. Every designed screen and every
  implemented view gets exercised with the content and state extremes
  before it's called done:
  - longest realistic name/headline — does it wrap or truncate well?
  - unbroken strings (emails, URLs, IDs/tokens) — no spaces means normal
    wrapping never kicks in; they blow out flex/grid containers unless
    `overflow-wrap` or truncation is designed in;
  - empty vs one vs many, for every list;
  - numeric/date extremes — 0, negative, 1,000,000+, long currency and
    timezone-qualified dates; alignment, badges, and axes break at the
    ends of the range;
  - async and error states — loading skeleton, failed fetch, offline;
    every screen has more states than the happy mock, and a state that
    isn't designed gets improvised in code;
  - locale expansion and RTL — text ~30% longer than English, mirrored
    layout; labels designed at English length clip first;
  - sections suppressed by permissions or feature flags.

  Extremes that break move the fix down to the molecule that owns it,
  not a page-level patch.

  Mock repeated and data-driven content in the design file with Pencil
  code-on-canvas Script nodes
  (https://docs.pencil.dev/core-concepts/code-on-canvas) — generated
  from data, not hand-duplicated layers, converting to editable layers
  only when a mock needs hand-tuning. Motion: one animation library per project (GSAP in JS
  projects), added when the UI first animates; feedback animation
  budgets 100–200ms; every animated moment ships a
  `prefers-reduced-motion` variant (color or opacity change); and
  high-stakes moments — payments, destructive actions, errors involving
  loss — get calm, plain feedback, no playfulness.

  Theming: surfaces follow the active theme — light theme means light
  surfaces, dark theme dark ones, never an inverted, opposite-theme
  fill. Floating elements (tooltips, toasts, popovers, menus) are
  `$surface` with a `$border` stroke and an ink shadow. Every color on
  a themed element resolves through a theme-bound variable; a one-off
  token that flips against the theme axis is the tell that this rule is
  about to be broken.

  Responsive: every screen and view ships **both** desktop and mobile
  treatments — a desktop-only mock is unfinished, because mobile is where
  the layout actually breaks (a header row that fits at desktop width
  collides at phone width; a table must scroll or restack; actions move
  into a menu) and the missing treatment gets improvised in code. Where
  the layout diverges structurally — tables, toolbars, multi-column
  rows — the mobile
  treatment is its own component (a `<Screen> Mobile` companion), not a
  narrowed desktop frame; where a card only reflows, a phone-width
  instance suffices, but it is still built and exercised. Every content
  and state extreme above gets re-checked at phone width, where they
  break first. This axis composes with theming — viewport × theme is four
  real renders (desktop and mobile, each in light and dark), never
  assumed.
- **`code-review.md`**: after any code change, run `/code-review` and fix
  findings **before** committing — only when the code-review skill
  passes the installed-check; if it doesn't, commit without improvising
  an ad-hoc review. Docs-only changes
  are exempt; when in doubt, review anyway. The point: the working
  branch's history is what reviewers read, so findings get fixed
  pre-commit instead of surfacing in PR review.
- **`sub-agents.md`** (every project): match the sub-agent's model to the
  task; never default every spawn to the session model. Think in three
  cost tiers, cheapest to most expensive, named by **role** so the rule
  survives new model releases — a **cheap tier** (Sonnet today), a **mid
  tier** (Opus today), and a single **heavy-hitter tier**: the most
  expensive model the session offers (Fable at the time of writing, but
  read it as whatever the top tier is when you run). Reserve each tier for
  where its extra capability pays off. **Cheap tier for mechanical,
  well-specified work** with one right answer and a clear spec: lint
  remediation (`id-length`, `no-magic-numbers`, other cap fixes with an
  obvious extraction), mechanical renames, straightforward test
  scaffolding, doc/format passes, search-and-collate. **Mid tier for
  judgment-heavy work:** structural refactors of long or complex files
  (splitting modules along seams, decomposing high-complexity functions
  without changing behavior), architecture and interface design, ambiguous
  or underspecified tasks, security-sensitive or money-moving code, and
  cross-cutting changes whose blast radius needs weighing. **The
  heavy-hitter tier is opt-in, never a silent default:** before spawning
  any sub-agent on it, confirm the user wants sub-agents to potentially use
  it (and it is only a candidate when actually available in the session).
  Two modes the user picks: (a) case-by-case, where the spawner still
  applies the judgment call — the heavy hitter only for the hardest tasks
  that genuinely out-reach the mid tier, not the default; or (b) always
  route the heavy tier to it. Absent an explicit yes, the heavy tier stays
  the mid tier. The spawning agent is the reviewer: when a cheaper-model
  agent returns, review its diff before committing — use `/code-review` for
  non-trivial batches (see `.claude/rules/code-review.md`). Cheaper
  execution plus a review gate from the spawner beats running everything on
  the top tier. Set the model explicitly on each spawn (`model:` on the
  Agent tool, or `model`/`effort` per stage in a Workflow) rather than
  relying on inheritance.
- **`finding-unknowns.md`**: before implementing a non-trivial feature —
  new domain, schema change, unfamiliar area of the codebase — run
  `/john-superpowers:finding-unknowns` to map the unknowns (four-quadrant
  pass: verify assumptions against the code, interview open questions,
  prototype taste calls, teach blindspots) before writing code — only
  when the skill passes the installed-check; skip silently when it
  doesn't. Mechanical changes and bug fixes
  with an obvious cause are exempt. The point: unknowns get surfaced
  while they're cheap — during planning, not after implementation comes
  back wrong.

When installing these rules, if a skill in
[skill.deps.json](./skill.deps.json) isn't installed, prompt the user to
run its install command first.
