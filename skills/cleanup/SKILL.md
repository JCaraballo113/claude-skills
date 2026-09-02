---
name: cleanup
description: Design-level cleanup of the current change, or the whole codebase when nothing is in flight — recomputation, compat shims, dead guards, point-of-use dedup, each redundant against something upstream — iterated to a fixed point. Use when the user says "cleanup" or "clean up the design".
---

# Cleanup

Scope is what the user names; else the branch's diff against its base plus uncommitted work; else, on a clean default branch, the whole codebase. Seek findings inside the scope; land each fix wherever the redundancy is rooted, upstream included.

Inspect for:

- **Recomputation** — a transformation or index that re-derives what an upstream producer already holds: a lookup already keyed, a relationship already materialized.
- **Compat shims** — a path kept alive for callers of the old shape. Migrate the callers, then delete the path.
- **Defensive guards** against states an upstream invariant already rules out.
- **Deduplication at the point of use** — a consumer stripping duplicates a producer emits. Fix at the producer: emit inherently deduplicated (a keyed collection, a set).

Each finding names what is redundant and the upstream fact that makes it so. Print the findings, fix them all, then confirm the project's checks (tests, types, lint) still pass. Iterate to a **fixed point** — each fix exposes the next; done when a full pass reports no findings.
