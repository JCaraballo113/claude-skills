---
name: open-pr
description: Use when the user asks to open, create, draft, raise, or "send" a pull request, or says "PR this" / "let's PR" / "ship a PR" on a branch with commits ahead of its base. Interrogates the author one question at a time, builds a reviewer-oriented PR body inline, then pushes and opens the PR via gh as a draft by default. Do NOT use for committing, merging, or reviewing existing PRs.
---

<what-to-do>

A pull request exists to make a diff legible to a stranger in a hurry. The reviewer is the customer. The author already has the context; the reviewer doesn't. Your job is to extract that context.

Read the diff, commits, and any linked ticket first. Then walk the author through the question tree one question at a time, proposing a recommended answer drawn from what you read. Skip a question only when the diff or commits answer it unambiguously — never skip out of guesswork.

After each answer, write the resolved fragment into a running PR body so the author sees it crystallize. When the tree is fully resolved, show the final title and body, confirm with the author, push the branch, and open the PR as a draft.

Ask one question at a time. Wait for the answer. Cross-reference each answer against the diff and surface contradictions.

</what-to-do>

<supporting-info>

## Preconditions

Stop at the first failure and tell the user.

1. `gh auth status` — must be authenticated.
2. Current branch is not the default branch. Get default via `gh repo view --json defaultBranchRef -q .defaultBranchRef.name`.
3. `git rev-list --count <base>..HEAD` returns > 0.
4. Working tree clean — if dirty, ask whether to commit first or proceed (intentional WIP is allowed).
5. No open PR for this branch: `gh pr list --head "$(git branch --show-current)" --state open --json number,url`. If one exists, surface its URL and stop.

## Read first

```bash
BASE=$(gh repo view --json defaultBranchRef -q .defaultBranchRef.name)
git log "$BASE"..HEAD --format='%H%n%s%n%n%b%n---'
git diff "$BASE"...HEAD --stat
git diff "$BASE"...HEAD
```

If the branch name or any commit body contains `[A-Z]+-\d+` or `#\d+`, fetch the ticket via `gh issue view <id>` (or note the id and skip if it 404s).

Read the full diff. Do not skim. The diff is the source of truth; commits are the author's framing.

## Question tree

Ask in this order. One at a time. For each, state the question, your recommended answer drawn from the diff, and the reason for the recommendation. Wait for the user's answer before moving on.

1. **Intent** — "What's the one-sentence reason this change exists? My read: <one sentence inferred from commits + diff>." Skip only if a commit body already states the intent in a complete sentence.
2. **Type** — "Conventional Commits type? My read: `<type>` because <reason>." Skip only if the diff has a single unambiguous shape (pure rename → `refactor`; new endpoint with tests → `feat`).
3. **Scope** — "Scope label, or omit? My read: `<scope>` (or 'omit')." Skip only if one top-level package contains > 80% of the changed lines and the name is obvious.
4. **Risk** — "What should a reviewer look at carefully that isn't obvious from the diff? My read: <heuristics that fired — see Risk heuristics>." Always ask. Even if heuristics produce a strong list, the author knows things the diff doesn't.
5. **Out of scope** — "Anything you deliberately did NOT do that a reviewer might ask about? My read: <none, or specific guess>." Always ask.
6. **Ticket** — "Link a ticket? My read: `Closes <id>` (or 'none')." Skip only if a ticket id is unambiguously present in branch name or commit trailer and the issue exists.

If the diff and commits genuinely contradict, surface that as an extra question before #1: "Commit X says <Y> but the diff <does Z> — which is right?"

## Sharpen fuzzy answers

When the user gives a vague or overloaded answer, push back with a precise alternative before recording it.

- "You said 'cleanup' — refactor (behavior-preserving) or dead-code removal?"
- "You said 'fix the auth thing' — name the bug in one sentence so the reviewer knows what to verify."
- "You said 'minor' — minor as in patch-level, or as in 'I think it's small but it touches the session middleware'?"

## Cross-reference each answer

After each answer, check it against the diff. Surface contradictions immediately.

- User says `fix`, diff adds a new public function with no prior reference → "That looks like `feat`, not `fix` — the function is new. Confirm?"
- User says "no breaking changes," diff renames an exported symbol → "The diff renames `Foo` (exported). That's breaking for downstream callers. Confirm?"
- User says "no migration," diff includes a `migrations/` file → contradict.

## Risk heuristics

Use these to seed your recommendation for question 4. Any that fire belong in Notes for reviewers, even if the user adds nothing.

- Public API: exported signature added, removed, or renamed.
- Schema: migration added; note additive vs destructive and backfill behavior.
- Auth, crypto, or security paths touched.
- Tests deleted or skipped.
- Config or env additions: new env vars, config keys, feature flags.
- Dependency changes: additions, major bumps, removals.
- Hot-path or performance-sensitive code.

## Inline body building

Maintain a running PR body as answers come in. After question 1, the body has *Why*. After question 4, *Notes for reviewers* takes shape. Show the running body to the user only at the end (do not interrupt the question flow), but build it incrementally so the final preview is just "here's what we wrote together."

Format: see [BODY-FORMAT.md](./BODY-FORMAT.md).

## Template handling

If `.github/pull_request_template.md` or `.github/PULL_REQUEST_TEMPLATE/*.md` exists, map *What* / *Why* / *Notes for reviewers* into the closest-matching template fields. Leave un-inferable fields as `<!-- TODO: <field> -->`. Do not fabricate.

If no template exists, use the three-section body in [BODY-FORMAT.md](./BODY-FORMAT.md) as-is.

## Anti-patterns

- Do not draft on guesses. If something is ambiguous, ask.
- Do not summarize commit-by-commit. Reviewers read diffs.
- Do not generate a "Test Plan" checklist by default. Fake checkboxes are worse than no checklist.
- Do not write "Breaking changes: None" without proof.
- Do not add emojis or "Generated by" footers.
- Do not push without explicit confirmation.

## Execute

1. Print the running title and body.
2. Ask: **"Push and open as a draft? (y / edit / ready / no)"**
   - `y` → push, create as draft
   - `edit` → user revises, then ask again
   - `ready` → push, create as ready-for-review
   - `no` → stop
3. `git push -u origin "$(git branch --show-current)"`
4. Create the PR:

   ```bash
   gh pr create \
     --base "$BASE" \
     --title "<title>" \
     --body "$(cat <<'EOF'
   <body>
   EOF
   )" \
     --draft   # omit only when user chose "ready"
   ```

5. Print the URL.

## Reusability and overrides

This skill assumes git, `gh`, and a GitHub remote. If a CLI is missing, prompt the user with its install command from [skill.deps.json](./skill.deps.json). Beyond that, it adapts via what it reads — default branch, diff, commits, tickets, PR template.

If a repo needs different behavior — strict ticket-in-title, mandatory checklist, non-GitHub forge — drop a `.claude/skills/open-pr/SKILL.md` in the repo. Repo-local replaces global. Do not add a config file.

</supporting-info>
