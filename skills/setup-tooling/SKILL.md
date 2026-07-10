---
name: setup-tooling
description: Bootstrap a project with my preferred tooling. Drives an intent interview first (ecosystem, project type, frontend, database, existing code), then composes the matching modules — a per-ecosystem stack (JS/TS today via setup-js-stack), lint-guardrails, design-tooling, and agent-rules. Use when the user says "setup tooling", "bootstrap this project", "scaffold my stack", or starts a fresh repo.
---

# Setup Tooling

Orchestrator: encodes my tastes into a project. **Drive intent first** —
the interview decides which modules apply; never install anything
before it.

## 1. Drive intent

Ask up front (AskUserQuestion works well); don't guess:

1. **Ecosystem** — JS/TS is the only stack module today. For anything
   else, say so, apply only the ecosystem-agnostic modules below, and
   offer to draft a `setup-<lang>-stack` module as a follow-up.
2. **Project type** — full-stack web app, SPA, backend/API, library,
   CLI. The stack module maps type → scaffold.
3. **Frontend?** — decides design tooling.
4. **Database?** — decides the DB portion of the stack module.
5. **Existing code?** — never re-scaffold over existing work; layer the
   missing pieces instead.

## 2. Compose modules

In order, skipping what intent ruled out:

1. `/john-superpowers:setup-js-stack` — the ecosystem stack (framework,
   package-manager baseline, database, CI). JS/TS projects only.
2. `/john-superpowers:lint-guardrails` — every project, any ecosystem.
3. `/john-superpowers:design-tooling` — frontend projects only.
4. `/john-superpowers:agent-rules` — every project.
5. If `setup-matt-pocock-skills` appears in the available-skills list
   (any scope, possibly namespaced), invoke it to layer the
   agent-workflow conventions (issue tracker, triage labels, domain
   docs) on top of the fresh tooling. If not, skip silently — don't
   hunt for it.

## 3. Report

Summarize what landed — scaffold, scripts, rule files, hooks, CI,
design files — and what was skipped and why.
