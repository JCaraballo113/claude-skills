---
name: pr-review-status
description: Read-only overview of review comment status on the current branch's open PR. Groups comments into addressed / pending / in-discussion / deferred-or-dismissed so you can see where things stand before acting. Use when the user says "show PR review status", "where are we on the review", "what's left to address", "summarize review progress", or comes back to a long-running PR and needs context. For active triage, fixes, and posting replies, use `triage-pr-comments` instead.
---

# PR Review Status

Query the open PR for the current branch and show where each review comment stands — no edits, no posts, no commits. This is the read-before-write companion to `triage-pr-comments`.

## Prerequisites

- `gh` CLI authenticated (`gh auth status` — if token is expired, tell the user to run `gh auth login` and stop)
- Current branch has an open PR

## Workflow

### 1. Find the PR

```bash
gh pr list --head "$(git branch --show-current)" --json number,title,url,state
```

If nothing is returned, tell the user and stop — don't guess at other branches.

### 2. Pull the comments

Both surfaces matter:

```bash
gh api repos/<owner>/<repo>/pulls/<num>/comments --paginate     # inline (line-level)
gh api repos/<owner>/<repo>/issues/<num>/comments --paginate    # issue-level (PR body / general)
```

Inline comments are threaded. Each comment has an `id` and `in_reply_to_id` — the root comment of a thread has no `in_reply_to_id`, and replies chain off it. To reason about thread state, group by thread root.

### 3. Classify each thread

Assign one status per **root comment** (a thread), not per reply. Four buckets:

| Status           | Detection                                                                                              |
| ---------------- | ------------------------------------------------------------------------------------------------------ |
| `addressed`      | A reply in the thread references a commit SHA (match `\b[0-9a-f]{7,40}\b`) — implies a fix was made    |
| `in-discussion`  | A reply exists from the PR author or a maintainer but no SHA reference — ongoing back-and-forth        |
| `pending`        | No replies at all — untouched                                                                          |
| `deferred`       | Thread is logged in `.pr-review-decisions/<pr>.md` (either `defer` or `invalid` state)                 |

Order of precedence: `deferred` > `addressed` > `in-discussion` > `pending`. If the decisions log says something was dismissed, trust that even if there's no GitHub reply.

**Reading the decisions log:**

```bash
# file lives at $(git rev-parse --show-toplevel)/.pr-review-decisions/<pr-number>.md
```

Each entry in that log has a comment URL — use it to map entries back to thread IDs.

### 4. Present the summary

Lead with totals, then break down by group. Within each group, show oldest-first (longest-waiting surfaces first):

```
PR #195 — Rhea deployment — 6 comments

Addressed (3)
- coderabbit · addressBook.ts:212 · replied in 5df52c37
- coderabbit · sst.config.ts:203 · replied in 5df52c37
- coderabbit · sst.config.ts:2817 · replied in 5df52c37

Pending (2)
- alice · src/utils/withdrawQueue.ts:274 · "this math assumes USDC decimals, what about USDG?"
- bob · sst.config.ts:148 · "worth extracting this into a helper?"

In-discussion (1)
- coderabbit · src/lambdas/reahUsdgtLiquidityManagement.ts:340 · 2 replies, no SHA

Deferred / dismissed (0)
```

For each entry, show: reviewer login · file:line · one-line summary of the claim (first sentence of the comment body, stripped of markdown). Keep it tight — if the body is long, truncate to ~100 chars.

If the user wants detail on one entry, drill in: show the full comment body, the reply chain, and which file:line it touches. Don't edit or post anything.

### 5. Suggest next steps

End the overview with a short prompt:

- If there are pending items: "Run `/triage-pr-comments` to work through pending items."
- If everything is addressed: "No pending items — PR is ready for re-review."
- If there are in-discussion items: "N threads are mid-discussion — you may want to read those before triaging new items."

Do **not** auto-invoke `triage-pr-comments`. The user decides when to switch into active mode.

## Notes

- This skill is strictly read-only. No `git` mutations, no `gh` writes, no file edits.
- SHA detection uses a 7-40 hex regex. If a reply says "fixed in 5df52c3" that counts as addressed, but "5df" alone wouldn't. Lean slightly false-negative — better to flag "in-discussion" than claim something's done when it isn't.
- The `.pr-review-decisions/<pr>.md` format comes from `triage-pr-comments`. If the file doesn't exist, just skip the `deferred` bucket — don't error.
- CodeRabbit comments have long `<details>` blocks. For the one-line summary, extract the bold `**...**` headline near the top of the body (that's their "Proposed change" title) and fall back to the first non-empty line if no headline.
