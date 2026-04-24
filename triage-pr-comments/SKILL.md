---
name: triage-pr-comments
description: Triage review comments (CodeRabbit, reviewers) on the current branch's open PR. Verifies each claim against the actual code, classifies into explicit states, reports validity + priority, asks for clarification when needed, and only commits/pushes/replies on explicit user approval. Use when user says "triage the PR comments", "check coderabbit comments", "address review feedback", "show PR review status", or wants a grounded assessment of review feedback before acting.
---

# Triage PR Comments

Go through review comments on the open PR for the current branch, verify each against the actual code (don't trust the reviewer blindly), classify them into explicit states, fix the valid ones, and post responses. Works for CodeRabbit, humans, or any reviewer.

## Prerequisites

- `gh` CLI authenticated (`gh auth status` — if token is expired, tell the user to run `gh auth login` and stop)
- Current branch has an open PR

## Comment states

Every comment gets classified into exactly one state. The state drives what happens next:

| State          | Meaning                                                                   | Next action                                                           |
| -------------- | ------------------------------------------------------------------------- | --------------------------------------------------------------------- |
| `valid-fix`    | Real issue, fix belongs in this PR                                        | Implement the fix (step 5), reply with SHA after push                 |
| `partial`      | Real concern but already mitigated elsewhere or lower-impact than claimed | No code change; reply explaining the existing mitigation              |
| `invalid`      | Based on misread of the code, stale info, or doesn't apply                | Draft a respectful rebuttal; user decides whether to post or dismiss  |
| `defer`        | Valid but out of scope for this PR                                        | Reply acknowledging + linking a follow-up issue; log in knowledge base |
| `needs-info`   | Ambiguous or overlapping with another comment — can't triage yet          | Ask the user a clarifying question before moving the comment forward  |

**One state per comment.** If you're torn, pick the more conservative (e.g. `needs-info` over guessing `invalid`).

## Main workflows

The skill has two entry points — pick based on the user's ask.

### Workflow A: Fresh triage (default)

Use when the user says "triage the PR comments", "address CodeRabbit", or otherwise starts from a cold PR.

Runs steps 1 → 9 below.

### Workflow B: Status overview

Use when the user says "show PR review status", "where are we on the review", or comes back to a long-running PR.

Query the PR comments and figure out what state each is already in, based on:
- Has the comment been addressed by a commit on this branch? (look for replies from you/the user referencing a SHA)
- Is there a reply thread indicating deferral, invalidation, or ongoing discussion?
- Is the comment untouched?

Present a grouped summary:

- **Addressed** (replied with a SHA) — N comments
- **Pending** (no reply) — N comments
- **In discussion** (reply exists but no resolution SHA) — N comments
- **Deferred / Dismissed** (logged in `.pr-review-decisions/`) — N comments

Then let the user pick one to dive into, or restart fresh triage on the pending ones.

## Workflow A steps

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
4. Assign one of the five states above (`valid-fix`, `partial`, `invalid`, `defer`, `needs-info`)

For `valid-fix` items, assess priority:
- **Runtime bug** (will cause user-visible failures) → high
- **Latent / future risk** (no active path uses it today but will break when enabled) → low
- **Defensive / hardening** (silent misconfiguration prevention) → medium

### 3a. Grill on `needs-info`

Before moving on, resolve any `needs-info` classifications by asking the user targeted questions. Good reasons to land in `needs-info`:

- The comment is vague ("this could be cleaner")
- Two comments contradict each other
- The comment references behavior you can't confirm without domain knowledge
- The claim depends on intent ("should this throw or return null?") that only the user knows

**Ask at most 2-3 questions per comment.** Don't over-interview. If a single clarifying answer resolves it, re-classify and move on.

If the user's answer reveals the comment is actually valid or invalid after all, re-triage it — `needs-info` should empty out by the end of step 3a.

### 4. Report to the user

Write a concise triage summary — one section per comment with:
- File:line reference
- **State** (valid-fix / partial / invalid / defer) and why
- For `valid-fix`: priority (high / medium / low)
- Suggested **Action**

End with a priority order for the `valid-fix` items. Wait for the user to confirm which to address — don't auto-fix everything. For `invalid` and `defer` items, confirm the user wants to proceed with a reply (not post silently).

### 5. Implement the fixes — do not commit yet

Work through the approved `valid-fix` items. **Do not commit or push automatically.** The user reviews the diff before anything lands in history.

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

Draft a reply for every triaged comment, shaped by its state:

- **`valid-fix`** → Reference the fix commit short SHA. Describe what was done, name specific state/variable/function names so a future reader can find the change. Don't re-argue the claim.
- **`partial`** → Acknowledge the concern, explain where/why it's already mitigated (file:line if possible), no SHA needed.
- **`invalid`** → Respectfully disagree. Point to the code that shows why the claim doesn't apply. Keep it neutral — reviewers (especially bots) can be wrong, and that's fine. Flag to the user as "draft rebuttal" before posting.
- **`defer`** → Acknowledge the issue is real but out of scope. Link to a follow-up issue if one exists; otherwise say one will be filed. Log the decision in `.pr-review-decisions/` (see step 10).
- **`needs-info`** should not reach this step — resolve it in 3a first.

Show all drafts to the user at once. Wait for approval or edits before posting. For `invalid` replies, explicitly confirm — they carry more weight than a "fixed" reply.

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

### 10. Log deferred / dismissed decisions

For any comment in state `defer` or `invalid`, append a short record to `.pr-review-decisions/<pr-number>.md` in the current repo. Create the directory if it doesn't exist.

Format:

```markdown
## PR #<num> — <comment path>:<line>

- **State:** defer | invalid
- **Reviewer:** <login>
- **Comment URL:** <html_url from the API>
- **Claim:** <one-line summary of what they said>
- **Decision:** <why we deferred or rejected, in plain language>
- **Follow-up issue:** <URL if defer + issue filed, else "none">
- **Date:** <YYYY-MM-DD>
```

The file is a flat log — keep the newest entry at the top. This gives a searchable record of "we keep seeing this class of nit and rejecting it" which is useful for pattern detection over time.

Stage and commit `.pr-review-decisions/` in the same commit as the fixes, or a follow-up commit if fixes already shipped.

## Notes

- Don't post `invalid` replies without discussing with the user first — disagreeing with a reviewer is a social move, not a code move.
- If the PR repo moved (GitHub redirects during push), the old `owner/repo` in git remote still works for `gh api`, but prefer the new location when constructing URLs.
- CodeRabbit comments include a lot of collapsed `<details>` blocks — the meaningful claim is usually in the first paragraph. Skim the rest only if you need the suggested diff.
- If a reviewer pushes back on a reply you posted, re-triage the comment from scratch. States aren't permanent — a `valid-fix` reply can still get disputed.
