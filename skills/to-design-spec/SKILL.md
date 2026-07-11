---
name: to-design-spec
description: Turn the current conversation into a design spec — surfaces, Jobs, design decisions, and a done bar — and publish it to the project issue tracker. The design-work mirror of /to-spec; no interview, just synthesis.
disable-model-invocation: true
---

# To Design Spec

Take the current conversation and produce a spec for **design work** — work whose deliverable is `.pen` frames, not code. Do NOT interview the user — synthesize what you already know.

The issue tracker and triage label vocabulary should have been provided to you — run `/setup-matt-pocock-skills` if not. The design conventions live in the project's design-system rule (`.claude/rules/design-system.md`); the spec builds on them, never restates them.

## Process

1. Read the project's design-system rule and the current `.pen` design (Pencil MCP — `get_editor_state({ include_schema: true })` first) so the spec starts from the designed state, not an imagined one. If `/john-superpowers:improve-user-experience` is installed, use its Job/gulf vocabulary throughout.

2. Sketch the **surfaces**: which screens and flows the work touches, and which template or component owns each change. This is the design analog of seams — the fewer surfaces, the better. Check with the user that they match expectations.

3. Write the spec with the template below and publish it to the tracker with the `ready-for-agent` label.

<design-spec-template>

## Problem statement

The experiential problem, from the user's perspective.

## Solution

The intended experience once the work is done.

## Jobs

A numbered list of the user Jobs the design serves — what the user is trying to accomplish, in their terms and their outcome.

## Design decisions

The decisions already made: templates vs pages touched, components reused vs introduced, variables/tokens involved, motion moments and their budgets, conceptual-model choices. No frame IDs or node paths — they go stale; name screens and components instead.

## Done bar

Generated from the project's design-system rule: the variant matrix (e.g. theme × breakpoint), the states, and the content extremes every touched screen must be exercised against.

## Out of scope

What this spec deliberately does not cover — always including code implementation, which gets its own /to-spec once designs are approved.

## Further notes

</design-spec-template>
