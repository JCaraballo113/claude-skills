---
name: triage-pr-comments
description: Triage review comments (CodeRabbit, reviewers) on the current branch's open PR. Verifies each claim against the actual code, reports validity + priority, offers to implement fixes, then posts reply comments crediting the fix commit. Use when user says "triage the PR comments", "check coderabbit comments", "address review feedback", or wants a grounded assessment of review feedback before acting.
---

# Triage PR Comments

Go through review comments on the open PR for the current branch, verify each against the actual code (don't trust the reviewer blindly), report findings with priority, fix the valid ones, and post responses. Works for CodeRabbit, humans, or any reviewer.

## Prerequisites

- `gh` CLI authenticated (`gh auth status` — if token is expired, tell the user to run `gh auth login` and stop)
- Current branch has an open PR

## Workflow

### 1. Find the PR

```bash
gh pr list --head "$(git branch --show-current)" --json number,title,url,state
```

If nothing returned, tell the user and stop — don't guess at other branches.

### 2. Pull the comments

There are two comment surfaces on a PR. Pull both:

- **Inline review comments** (attached to specific lines):
  ```bash
  gh api repos/<owner>/<repo>/pulls/<num>/comments --paginate
  ```
- **Issue-level comments** (PR body / summary / general discussion):
  ```bash
  gh api repos/<owner>/<repo>/issues/<num>/comments --paginate
  ```

For CodeRabbit triage, inline comments are where the actionable findings live. Filter with jq:

```bash
gh api repos/<owner>/<repo>/pulls/<num>/comments --paginate \
  | jq 'map(select(.user.login | test("coderabbit"; "i"))) | .[] | {path, line, id, body}'
```

Save the output — you'll need the comment IDs later to reply.

### 3. Triage each comment

**Critical:** Do not just summarize the reviewer's claim. Verify it against the current code. Reviewers (especially automated ones) can be wrong, make claims based on stale code, or miss mitigations that already exist elsewhere.

For each comment:

1. Read the claim
2. Open the referenced file/line and check whether the claim is actually true right now
3. If the claim depends on other code paths (e.g. "the resolver only handles format X"), verify those paths too
4. Classify as:
   - **Valid** — real issue that should be fixed
   - **Partial** — real concern but mitigated elsewhere, or lower-impact than claimed
   - **Invalid** — based on wrong reading of the code, stale info, or doesn't apply

For valid items, assess priority:
- **Runtime bug** (will cause user-visible failures) → high
- **Latent / future risk** (no active path uses it today but will break when enabled) → low
- **Defensive / hardening** (silent misconfiguration prevention) → medium

### 4. Report to the user

Write a concise triage summary — one section per comment with:
- File:line reference
- **Verdict** (Valid / Partial / Invalid) and why
- Suggested **Action** (fix now / defer / dismiss)

End with a priority order for fixing. Wait for the user to confirm which to address — don't auto-fix everything.

### 5. Implement the fixes — do not commit yet

Work through the approved items. **Do not commit or push automatically.** The user reviews the diff before anything lands in history.

After the edits are in place:
1. Run `git diff --stat` and `git diff` (or show the relevant hunks) so the user can see exactly what changed
2. Summarize each fix briefly, one line per comment addressed
3. Wait for the user to confirm the changes look right

If the user wants edits, make them and re-show the diff. Don't move to step 6 until they explicitly approve.

### 6. Commit — only after user approval

Once approved, stage only the relevant files (don't `git add -A`) and commit with a message that lists each fix. Keep commits focused — don't bundle in unrelated cleanup.

Commit message template:

```
fix: address <reviewer> review on <branch> PR

- <one line per fix, explaining what and why>
- <...>
```

After committing, show `git status` and the short SHA. Do not push yet.

### 7. Push — only after the commit is approved

Ask before pushing ("want me to push?"). Only push when the user confirms. Use `git push origin <current-branch>` — do not force-push.

If `git push` is blocked by a hook, surface the block and ask the user whether to adjust the hook or push manually. Do not try to work around the block.

### 8. Draft reply comments — show drafts first

Now that the fix is pushed and referenceable by SHA, draft replies to each addressed comment. Each reply should:
- Reference the fix commit short SHA (from step 6)
- Briefly describe what was done, not just "fixed"
- Name specific state/variable/function names where relevant so a future reader can find the change
- Not re-argue the original claim — the fix speaks for itself

Show all drafts to the user at once. Wait for approval or edits before posting.

### 9. Post replies via the replies endpoint

**Gotcha:** `POST /pulls/<num>/comments` with `in_reply_to` in the body **does not work** via `gh api -f` because `-f` stringifies and the API rejects the string. Use the dedicated replies endpoint instead:

```bash
gh api --method POST \
  repos/<owner>/<repo>/pulls/<num>/comments/<comment_id>/replies \
  -f body="$(cat <<'EOF'
<reply body here>
EOF
)" --jq '.id'
```

Post all replies in parallel (multiple Bash calls in one message). Report the reply IDs back to the user.

## Notes

- Don't post replies that amount to "I disagree" without discussing with the user first. If triage found a comment to be invalid, surface that and let the user decide whether to reply, dismiss, or close as not-planned.
- If the PR repo moved (GitHub redirects during push), the old `owner/repo` in git remote still works for `gh api`, but prefer the new location when constructing URLs.
- CodeRabbit comments include a lot of collapsed `<details>` blocks — the meaningful claim is usually in the first paragraph. Skim the rest only if you need the suggested diff.
