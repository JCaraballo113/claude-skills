---
name: lint-guardrails
description: AI-guardrail linting — size/complexity caps that force extraction over sprawl, no comments, named constants, everything an error, and the config protected from agent edits by a deny hook. Ecosystem-agnostic philosophy with per-ecosystem implementations (ESLint for JS/TS today). Standalone-safe on existing repos. Use when the user says "setup linting", "set up the lint guardrails", "add lint guardrails", or via setup-tooling.
---

# Lint Guardrails

Guardrails make agent-written code readable by construction (based on
["ESLint as AI Guardrails"](https://medium.com/@albro/eslint-as-ai-guardrails-the-rules-that-make-ai-code-readable-8899c71d3446)):
size/complexity caps that force extraction over sprawl, no comments
(explanations go to docs), named constants. The philosophy is
ecosystem-agnostic; implementations live in per-ecosystem support files.

## The philosophy

- Everything is an **error**, never a warning.
- **Never raise a cap or add a suppression to make code fit** — hitting
  a limit means extract, split, or rename.
- Comments are banned; knowledge lives in docs, names, and test titles.
- The config is **protected**: a PreToolUse deny hook blocks agent edits
  to the lint config. Timing and caveats live with the implementation.
- Vendored/generated code, tests, scripts, and root config files get
  scoped exemptions — correctness rules stay on everywhere.

## Implementations

- **JS/TS (ESLint)** — [ESLINT.md](./ESLINT.md): the rules, deviations
  learned in practice, scoped exemptions, the protect hook, and
  remediation specifics.
- **Other ecosystems** — apply the philosophy with the native tools
  (e.g. clippy caps for Rust); add a support file here once an
  implementation stabilizes in real use.

## Remediating an existing codebase

On a fresh scaffold there is nothing to fix. On an existing repo:

1. Fix pre-existing lint errors before adding rules — never mix the two.
2. Measure, group by rule and by file, and report the blast radius to
   the user before starting — it can be hours.
3. Comments: first handle functional ones manually (suppressions,
   license headers). Harvest every comment with file:line to a scratch
   file before stripping the rest. Relocate load-bearing knowledge from
   the harvest: domain vocabulary → glossary; decisions/invariants →
   ADRs; subsystem warnings → a README next to the code; env-var
   semantics → `.env.example`; test intent → describe/it names.
   Everything else: better names.
4. Fix cheapest-first — the per-ecosystem file has the exact order and
   patterns.
5. Run the test suite after each batch; runtime-verify UI at the end if
   components were restructured.
6. Write `docs/agents/linting.md` (rules table, deviations, exemptions,
   where explanations go, the protect hook) and point AGENTS.md /
   CLAUDE.md at it with the one-liner: "When a cap fires, extract —
   never raise the cap." Then install the protect hook as the final
   lint action.

Don't remediate on a dirty tree; the diff must stay reviewable.

If `jq` (needed by the protect hook) is missing, prompt the user with
its install command from [skill.deps.json](./skill.deps.json).
