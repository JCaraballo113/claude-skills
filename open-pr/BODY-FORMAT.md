# PR title and body format

## Title

Format: `<type>(<scope>): <subject>` — Conventional Commits.

- **Type**: `feat`, `fix`, `refactor`, `perf`, `docs`, `test`, `build`, `ci`, `chore`, `revert`.
- **Scope**: top-level package or module dominating the diff. Omit the parens entirely if no single scope dominates — `feat: …` is valid. Do not invent a scope.
- **Subject**: imperative, present tense, no trailing period, lowercase first word unless a proper noun.
- **Length**: total title ≤ 80 characters. If you can't fit, the subject is too vague — sharpen, don't truncate.
- **Tickets**: never in the title. They go in the body footer.

## Body

Three sections, in this order. No others by default.

### What

One paragraph, present tense, plain language. Describe the change a reviewer is about to read — not a list of commits, not a list of files. If the diff has two unrelated themes, name both; if one, name one.

### Why

One paragraph. Use the author's answer to the Intent question verbatim or lightly edited. Do not invent a Why.

### Notes for reviewers

Combine the author's Risk and Out-of-Scope answers with the heuristics in `SKILL.md` (Risk heuristics). The author's answers come first; heuristics fill in anything they didn't mention.

If nothing fires and the author flagged nothing, write a single line: `Straightforward change; nothing unusual.` Do not pad.

### Footer

If a ticket id was found and confirmed, append `Closes <ID>` on its own line at the end. Otherwise omit.

## Example

```
fix(session): expire sessions on password change

## What
Sessions are now invalidated when a user changes their password. Adds a `password_changed_at` column to `users`, and `session.IsValid()` rejects sessions issued before that timestamp.

## Why
Support reported users who changed passwords after a suspected compromise still had active sessions on other devices.

## Notes for reviewers
- Migration `20260430_add_password_changed_at.sql` is additive and backfills `NOW()` for existing rows — existing sessions stay valid; only future password changes invalidate.
- `session.IsValid()` is on the hot path; the new check is a single timestamp compare, no extra query.
- Did not add a "force logout all devices" admin endpoint — out of scope.

Closes SUP-482
```
