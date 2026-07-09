---
name: setup-js-tooling
description: Bootstrap a JS/TS project with my preferred stack — TanStack Start (or Vite for SPAs), TanStack Query/Form, Zustand for client state when needed, Hono for pure backends, Drizzle + Docker/Supabase Postgres, Zod, Tailwind, shadcn, Vitest, AI-guardrail ESLint, GitHub Actions CI, all on pnpm with the 1-day package-age guard. Interviews for project type first and installs only the matching subset. Use when the user says "setup js tooling", "bootstrap this project", "scaffold my stack", "setup linting", "set up the lint guardrails", or starts a fresh JS/TS repo.
---

# Setup JS Tooling

Sets up a new (or bare) JS/TS repo with the preferred stack. **Always
interview before installing anything** — the project type decides which
subset applies. Two things apply to every project regardless of type:
the pnpm baseline (step 3) and the lint guardrails + CI (step 5). The
linting section stands alone — for an existing repo that only needs lint,
run just step 5.

## Step 1 — Interview

Ask these up front (AskUserQuestion works well); don't guess:

1. **What kind of project?**
   - **Full-stack web app** → TanStack Start
   - **SPA** (client-only, no SSR) → Vite + React + TanStack Router
   - **Backend/API service** (pure JS backend) → Hono
   - **Full-stack with a separate API** → Start or Vite SPA + a Hono service
2. **Does it need a database?** → Drizzle + local Postgres via
   Docker/Supabase, plus the migrations workflow.
3. **Forms-heavy?** → TanStack Form wired to Zod.
4. Anything already scaffolded? Never re-scaffold over existing code —
   layer the missing pieces instead.

## Step 2 — The stack matrix

| Concern | Full-stack app | SPA | Backend/API |
| --- | --- | --- | --- |
| Framework | TanStack Start | Vite + React + TanStack Router | Hono |
| Data fetching | TanStack Query | TanStack Query | — |
| Client state | Zustand (only if needed) | Zustand (only if needed) | — |
| Forms | TanStack Form + Zod | TanStack Form + Zod | — |
| Validation | Zod (single source of truth, shared client/server) | Zod | Zod (`@hono/zod-validator`) |
| Styling | Tailwind + shadcn | Tailwind + shadcn | — |
| ORM/DB | Drizzle + Docker/Supabase Postgres | (via its API) | Drizzle + Docker/Supabase Postgres |
| Design | Pencil + impeccable | Pencil + impeccable | — |
| Tests | Vitest | Vitest | Vitest |
| Lint | guardrail ESLint | guardrail ESLint | guardrail ESLint |
| CI | GitHub Actions | GitHub Actions | GitHub Actions |

Scaffolders (verify current flags against the tool's docs before running):

```bash
pnpm create @tanstack/start@latest    # full-stack app
pnpm create vite@latest . --template react-ts   # SPA (add @tanstack/react-router)
pnpm create hono@latest               # backend
pnpm dlx shadcn@latest init           # after Tailwind is in
```

## Step 3 — pnpm baseline (every project, no exceptions)

pnpm is the package manager — not npm, not yarn, in the repo and in CI.

- `packageManager` field pinned to the latest pnpm (check
  `npm view pnpm version`), run via corepack.
- `pnpm-workspace.yaml` with the supply-chain guard — **always**, plus any
  native-build approvals the install flags:

```yaml
minimumReleaseAge: 1440   # a version must be ≥1 day old to install
```

- Scripts: `dev`, `build`, `test` (`vitest run`), `test:watch`, `lint`
  (`eslint --max-warnings 0`).

## Step 4 — Database (when the interview says yes)

- `docker-compose.dev.yml` running `supabase/postgres` (same engine as
  hosted Supabase) on a **non-default host port** (e.g. 54322) to avoid
  colliding with other local Postgres instances; healthcheck via
  `pg_isready`. Scripts: `db:up` / `db:down`.
- Drizzle: `drizzle-orm` + `drizzle-kit` + `pg`; `db:push` (local dev),
  `db:generate` (committed migrations), `db:migrate` (deploy). Rule:
  a schema change and its generated migration go **in the same commit**.
- Vitest `globalSetup` that creates throwaway databases in the dev
  container and pushes the schema — tests never touch a real DB.
- Secrets never in the repo: `.env.example` documents variables only.

## Step 5 — Lint guardrails (every project; standalone-safe)

AI-guardrail ESLint (based on
["ESLint as AI Guardrails"](https://medium.com/@albro/eslint-as-ai-guardrails-the-rules-that-make-ai-code-readable-8899c71d3446)):
size/complexity caps that force extraction over sprawl, no comments
(explanations go to docs), named constants. Everything is an **error**,
never a warning. **Never raise a cap or add an eslint-disable to make code
fit** — hitting a limit means extract, split, or rename.

### The rules

Flat config only. Install `eslint-plugin-no-comments` (dev dep) and layer
this on the repo's framework base config:

```js
import noComments from "eslint-plugin-no-comments";

const guardrails = {
  "max-lines": ["error", { max: 250, skipBlankLines: true }],
  "max-lines-per-function": ["error", { max: 50, skipBlankLines: true }],
  "max-statements": ["error", 20],
  complexity: ["error", 10],
  "max-depth": ["error", 4],
  "max-params": ["error", 3],
  "max-classes-per-file": ["error", 1],
  "no-magic-numbers": [
    "error",
    {
      detectObjects: false,
      enforceConst: true,
      ignore: [0, 1, -1, 2, "0n"],
      ignoreArrayIndexes: true,
    },
  ],
  "id-length": ["error", { min: 2, exceptions: ["z", "_"] }],
  eqeqeq: ["error", "always", { null: "ignore" }],
  "no-console": ["error", { allow: ["error", "warn"] }],
};

// { name: "ai-guardrails", plugins: { "no-comments": noComments },
//   rules: { ...guardrails, "no-comments/disallowComments": "error" } }
```

Deliberate deviations from the article, learned in practice:

- **`max-params: 3`, not 2** — TanStack Query / react-hook-form / Hono
  middleware callback signatures are 3-ary and not ours to redesign. Our
  own functions still prefer a single object param.
- **`max-lines-per-function: 120` for `.tsx`** (50 elsewhere) — JSX inflates
  line counts without adding logic; `complexity` and `max-statements` still
  apply at full strength there.
- **No plugin presets** — skip the article's `sonarjs`/`unicorn`/`security`
  recommended configs. This rule set is the whole system.

Scoped exemptions (separate flat-config blocks):

- **Vendored/generated code** (e.g. shadcn `components/ui/**`): size,
  complexity, magic-number, and comment rules off. Correctness rules stay.
- **`tests/**`, `scripts/**`**: size/params/complexity/magic-number/console
  off — specs assert literals, describe blocks are one long function.
  Comments stay banned; test names carry intent.
- **Root `*.config.*` files**: comments allowed, everything else applies.

### Remediating an existing codebase

On a fresh scaffold there is nothing to fix. On an existing repo:

1. Fix pre-existing lint errors before adding rules — never mix the two.
2. Measure with `npx eslint --format json`, group by rule and by file, and
   report the blast radius to the user before starting — it can be hours.
3. Comments: first check for functional ones (`eslint-disable`,
   `@ts-expect-error`, license headers) and handle those manually. Harvest
   every comment with file:line to a scratch file, then `eslint --fix`
   strips the rest (no-comments is auto-fixable). Collapse leftover
   blank-line runs. Relocate load-bearing knowledge from the harvest:
   domain vocabulary → glossary; decisions/invariants → ADRs; subsystem
   warnings → a README next to the code; env-var semantics →
   `.env.example`; test intent → describe/it names. Everything else:
   better names.
4. Fix cheapest-first: `id-length` renames (`i` → `index`, comparators
   `(a, b)` → `(left, right)`) and magic numbers → named constants
   (constants duplicated across client/server Zod schemas get one shared
   module) → decompose oversized functions into named step helpers (guard
   helpers returning `{ value } | { response }` unions work well for route
   handlers) → split oversized files along domain seams → extract
   subcomponents (grouped state like a dialog-state union often collapses
   lines and complexity at once).
5. Run the test suite after each batch; runtime-verify UI at the end if
   components were restructured.
6. Write `docs/agents/linting.md` (rules table, deviations, exemptions,
   where explanations go) and point AGENTS.md / CLAUDE.md at it with the
   one-liner: "When a cap fires, extract — never raise the cap."

Gotchas: `detectObjects: false` already spares `{ status: 409 }`-style
object literals — only bare arguments/operands need constants (HTTP
statuses as bare args deserve a tiny `http-status.ts`). ESLint's
`complexity` counts `??` and repeated `x?.kind === "a" ? … : null`
patterns — extract tiny accessor functions. Don't remediate on a dirty
tree; the diff must stay reviewable.

## Step 6 — CI via GitHub Actions (every project)

`.github/workflows/ci.yml`: `lint` and `test` jobs on push to the working
branches and PRs to main — `pnpm/action-setup` + `setup-node` with
`cache: pnpm`, `pnpm install --frozen-lockfile`, then `pnpm lint` /
`pnpm test`. If the project has a DB, give the test job a
`supabase/postgres` service on the same port the compose file uses, with a
`pg_isready` healthcheck.

## Step 7 — Design tooling (frontend projects)

UI is **always designed in Pencil** (a `.pen` design file driven through
the Pencil MCP — never Read/Grep on `.pen` files) with the **`impeccable`**
skill governing design quality. Design first, implement second. Setup:

- Create the project's `.pen` file under `designs/` and reference it from
  the agent instructions.
- Run `impeccable init` (or note it as the next step) so PRODUCT.md /
  DESIGN.md capture the product context the design work anchors to.
- Encode the convention in AGENTS.md / CLAUDE.md: designs live in
  `designs/<app>.pen` via the Pencil MCP; `/impeccable` governs design
  quality; design precedes implementation.

Skip this step entirely for backend/API projects.

## Step 8 — Agent workflow conventions (if available)

If the `setup-matt-pocock-skills` skill is installed, invoke it now to
layer the agent-workflow conventions (issue tracker, triage labels, domain
docs) on top of the fresh tooling. Check **global first, then project** —
it's usually installed globally (`~/.claude/skills/`), with
`.claude/skills/` in the repo as the fallback; the available-skills list
covers both, so trust it over guessing paths. If it isn't installed in
either scope, skip silently — don't hunt for it.

## Step 9 — Report

Summarize what was installed and why (tied back to the interview answers),
list the scripts, and call out anything deferred (auth, deployment target,
component library beyond shadcn defaults).

## Notes

- Organize code into **domain folders** from day one (`lib/<domain>/`,
  `components/<domain>/`) — no flat dumping grounds.
- Prefer the interview over inference even when the repo hints at a type —
  a `package.json` with react in it doesn't say SPA vs Start.
- Scaffolder CLIs drift; if a create-command errors, check the tool's
  current docs rather than forcing flags.
- Client state: server state belongs in TanStack Query and form state in
  TanStack Form — reach for **Zustand** only when genuine client-global
  state remains (multi-view UI state, cross-component sessions). Don't
  install it preemptively on a fresh scaffold, and never Redux/MobX/Jotai.
- Don't add tooling off-list (CSS-in-JS, axios, etc.) unless the user
  asks — TanStack Query + fetch, Tailwind, and Zod cover the defaults.
