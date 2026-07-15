---
name: autopilot
description: Orchestrate a batch of tickets or fixes to done — a fresh agent implements, commits, and notes each item in its own git worktree, while the main session validates, fast-forwards it into the branch, and reports.
argument-hint: "Which items (tickets/issues/fixes) and the branch to land them on"
disable-model-invocation: true
---

# Autopilot

Run a batch of work items to done without the user in the loop. The main session is the
**orchestrator**: it never writes the code — it hands each item to a **fresh agent in its own
git worktree**, and once that agent has implemented, committed, and noted its work, the
orchestrator **validates and fast-forwards** the commit into the target branch. The orchestrator
holds the through-line (order, shared pointers, the branch's story) and pulls each agent's
detail from git on demand — not from a prose report it has to carry.

One item at a time, each worktree cut from the tip the last item landed on.

## Invariants

Hold these every iteration — they are what keep an unattended run predictable:

- **The orchestrator orchestrates; agents implement.** You brief, validate, integrate, push,
  and report; the agents write the source.
- **A fresh agent per item, in its own worktree.** Each item runs in a throwaway git worktree on
  its own branch, cut from the target tip — fresh context, isolated tree, and the isolated copy
  runtime verification wants (its own app instance, DBs, or ports).
- **The agent commits and notes; the orchestrator integrates.** In its worktree the agent commits
  by **pathspec** (only the files it changed) and attaches a **git note** (`refs/notes/autopilot`)
  with its label and reviewer notes. Nothing reaches the target branch until the orchestrator has
  validated that commit and **fast-forwarded** it in — so unvalidated work never enters target
  history, and the note rides the commit unchanged.
- **Validate before you integrate.** The agent's commit is a proposal; confirm it (scope, a key
  test, lint, parity for front-end) before fast-forwarding. Patch as a **follow-up commit**, never
  an `--amend` — an amend rewrites the SHA and orphans the note.
- **Front-end items ship at design parity, not just working.** An agent told only to satisfy
  acceptance criteria drifts from the design — reusing a component's default layout, missing a
  state or color. The design file is the spec: parity is a completion gate, proven by screenshot
  against **every state and variant the design defines** (only the themes/viewports/states it
  actually specifies) before the item integrates.

## Workflow

### 1. Fix the work-list and its order

Read each item (e.g. `gh issue view <n>` for issues). Order them so every item's dependencies land
before it — the **frontier** is whatever has no unmet dependency. For a parity/cleanup batch with
no tickets, the work-list is the set of divergences grouped into **disjoint slices**.

Done when: an ordered list exists where each item's prerequisites precede it, and you know the
target branch.

### 2. Map the code once, up front

Spawn one read-only Explore agent to map the files, seams, and conventions every item will touch
(schemas, test seams, prior art, the components in play). Write the map to a file in the
scratchpad so each item's brief can reference it by path instead of restating it.

Done when: a shared map file exists with concrete `path:line` pointers for the items ahead.

### 3. Commit any pre-existing foundation first

If the target already holds uncommitted work the items build on (a design file, a migration),
commit that by pathspec before starting — so each item's worktree branches from a clean tip.

Done when: the only uncommitted changes left are ones the items will produce.

### 4. Run the item loop

For each item in order:

1. **Cut a worktree** off the current target tip (which already carries the previous item):
   `git worktree add <path> -b autopilot/<item> <target>`.
2. **Brief the agent with `/autopilot-handoff`**, pointed at that worktree. Its pickup doc
   references the issue and the step-2 map **by path**, names the branch to commit on, and its
   **suggested skills** section runs `/autopilot-implement` (implement → TDD at the seams →
   typecheck + tests → `/code-review`, then commit by pathspec and attach the git note) plus, for
   a user-visible change, a runtime check against the running app (however the project runs it). For a **front-end item**, name the design
   board(s) and states and make design parity a completion gate. The agent returns a **terse**
   result — branch, commit, files, test/verify status — its prose living in the note.
3. **Validate the item branch.** Confirm the commit touches only the item's files; re-run its key
   test; lint the changed files; pull the agent's note only if you need it
   (`git notes --ref=autopilot show <sha>`); spot-check parity for a front-end item. If it's off,
   fix it as a **follow-up commit** in the branch (never an amend).
4. **Fast-forward into target** (`git switch <target> && git merge --ff-only autopilot/<item>`),
   which brings the commit and its note unchanged; then remove the worktree. **Push** the target
   and the notes ref (`git push origin <target> refs/notes/autopilot`).

Done when: every item is a validated, fast-forwarded commit on the target — provenance-noted, and
front-end items at design parity — with its worktree removed.

### 5. Final sanity pass

Run the full test suite once and the full-repo lint. Confirm the tree is clean and the target is
level with its remote.

Done when: suite green, lint clean, `git status` clean, nothing ahead/behind.

### 6. Report the run as an HTML artifact

Summarize the run with `/html-artifact` — one self-contained page the user opens when they're
back: a card per item (what shipped, its commit, verification status), the branch / suite / lint
state from step 5, and any **flag** surfaced prominently — e.g. a pre-existing failure outside the
work-list you left untouched. Pull each item's detail from its git note rather than carrying it in
context. Hand the user the path once it's saved.

Done when: the artifact is saved, self-contained, and its path is in the user's hands.

## Notes

- **Scope creep mid-run.** When the user adds items while a run is going, append them to the
  work-list as new slices and keep the one-at-a-time cadence — don't widen an in-flight agent's
  brief.
- **Provenance via git notes.** Read the per-commit notes with `git log --notes=autopilot`; they
  reach the remote via the pushed notes ref. This is what keeps the agents' prose in git — pulled
  on demand — instead of in the orchestrator's context.
- **A trivial follow-up** the user explicitly asks for (a one-line rename) is fine to do inline as
  its own pathspec commit rather than spawning an agent.
- Pairs with `/autopilot-handoff` + `/autopilot-implement` (its model-invocable arms),
  `/html-artifact` (the run report), and the project's `/code-review` — autopilot is the loop
  around them, not a replacement.
