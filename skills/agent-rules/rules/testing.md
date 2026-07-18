# testing.md

Applies: every project.

Features develop test-first (red → green → refactor) via the `tdd`
skill; the generated rule tells the agent that when the skill fails the
installed-check (wording in SKILL.md), it prompts the user to install it
(command in [../skill.deps.json](../skill.deps.json)) rather than
improvising the loop.

## Spec structure

Every test file (Vitest in JS; the stack's runner elsewhere) groups
specs under `describe("Happy path")` and `describe("Negative path")`;
when one file covers several surfaces, nest the pair inside each
surface's describe. Happy path = the documented, intended behavior.
Negative path = everything that must fail well (auth rejections,
validation errors, conflicts, malformed data, downstream failures),
asserting the observable refusal — status, unchanged state, audit
entry — not internals. A surface with no negative specs is a smell.

## File layout

Spec files mirror the domain seams of the source: group into
`tests/<domain>/` folders as domains accumulate — never one flat pile; a
lone spec may sit flat until its domain grows a second file. When
installing into a repo that already has flat spec files, grandfather
them by name in the rule: new specs go in domain folders; legacy files
move opportunistically when touched, never in bulk. Shared
infrastructure lives in `tests/helpers/`.

## Coverage

Non-trivial features land with tests covering their happy and negative
paths — not incidental line coverage. Measure with a `test:coverage`
script (in JS: `vitest run --coverage`); before calling feature work
done, check that the files added or changed show up covered — an
important module at ~0% is a gap to close, not a statistic to report.
Coverage is a discovery tool, not a gate: there is no numeric threshold
to game, and untestable-as-written code that blocks coverage gets
refactored, not excluded.
