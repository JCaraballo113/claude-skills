# `code-review.md` — the generated rule

Applies to **every project**.

After any code change, run `/code-review` and fix findings **before** committing — only when the code-review skill passes the installed-check (wording in SKILL.md); if it doesn't, commit without improvising an ad-hoc review. Docs-only changes are exempt; when in doubt, review anyway.

The point: the working branch's history is what reviewers read, so findings get fixed pre-commit instead of surfacing in PR review.
