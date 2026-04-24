---
name: add-agent-skill
description: Scaffold a new agent skill in the user's claude-skills repository. Interviews the user for name, triggers, and purpose, writes a SKILL.md with proper frontmatter, installs it locally via install.sh, and leaves the content for the user to fill in. Use when the user says "add an agent skill", "scaffold an agent skill", "new agent skill", "new skill in my claude-skills repo", or wants to start a new skill in their claude-skills repository.
---

# Add Agent Skill

Scaffold a new skill in the user's `claude-skills` repo. The goal is a clean, installable stub with correct frontmatter — the user fills in the workflow body themselves, or with follow-up help.

## Prerequisites

- The user has a `claude-skills` repo cloned locally (the one this skill ships in).

## Step 1 — Locate the repo

Resolve the repo path in this order, stopping at the first match:

1. `$CLAUDE_SKILLS_REPO` env var, if set
2. The repo that contains this skill — derive from `$(dirname "$(readlink -f "$0")")/..` equivalent. In practice: check if `$HOME/.claude/skills/add-skill/.installed-from` exists, read its `repo=` line
3. Common locations: `$HOME/Repos/claude-skills`, `$HOME/claude-skills`, `$HOME/src/claude-skills`
4. Ask the user for the absolute path

Confirm the resolved path before writing anything. The repo must have an `install.sh` at its root — if not, you're in the wrong place.

## Step 2 — Interview the user

Ask for these, one at a time or in a single message — whichever fits the flow. Keep it short.

1. **What does the skill do?** One or two sentences. This shapes the description and purpose.
2. **When should Claude invoke it?** What phrases would the user type? (e.g. "triage the PR comments", "what's the status of X"). These become the trigger examples in the description.
3. **Suggested name** (kebab-case, lowercase, short). Propose one based on the purpose; let the user override.

If the user gives terse answers, don't re-interview — work with what you have and show a draft in step 3.

## Step 3 — Draft the frontmatter, show to user first

The `description` field is what Claude uses at skill-resolution time, so it has to do two jobs:

- **State what the skill does** in plain language (first sentence or two).
- **List trigger phrases** near the end: "Use when the user says X, Y, Z, or ...".

Pattern:

```markdown
---
name: <kebab-case-name>
description: <one or two sentences on purpose>. Use when the user says "<trigger 1>", "<trigger 2>", "<trigger 3>", or <situational trigger>.
---

# <Title Case Name>

<One-paragraph overview of what this skill does and the outcome it produces.>

## Workflow

### 1. <First step>

<Describe the action, including any `gh`/`bash`/tool calls that are core to it.>

### 2. <Next step>

...

## Notes

- <Anything non-obvious about running this skill — gotchas, limits, when not to use it.>
```

Show the drafted frontmatter + title + outline (not full body) to the user. Wait for approval or edits before writing to disk. Push back on:

- Descriptions that are too vague to discriminate ("help with code") — they'll over-trigger.
- Descriptions without trigger examples — Claude won't know when to invoke.
- Names that collide with existing skills in the repo (check by listing existing directories).

## Step 4 — Write the file

Create `<repo>/<name>/SKILL.md` with the approved frontmatter and the outline. Leave placeholder content under the step headings — explicitly marked as TODO so the user knows to fill it in:

```markdown
### 1. <First step>

TODO: describe what happens here.
```

Do **not** invent a workflow body the user didn't ask for. The skill is a stub — the user completes it.

## Step 5 — Install locally

Run `<repo>/install.sh <name>` to copy the skill into `~/.claude/skills/<name>/`. Show the output. The skill becomes available immediately.

```bash
cd <repo> && ./install.sh <name>
```

## Step 6 — Update the README

Add a row to the skills table in `<repo>/README.md`:

```markdown
| [<name>](./<name>/SKILL.md) | <one-line description, can be a trimmed version of the frontmatter description> |
```

Keep the table alphabetical unless the user prefers another order.

## Step 7 — Suggest commit + push

Do **not** auto-commit. Show the user the new files (`git status` + `git diff README.md`), and propose a commit message:

```
feat(<name>): scaffold <name> skill

<brief purpose>
```

Ask if they want to commit and push. Only do it on explicit approval.

## Notes

- This skill scaffolds; it doesn't write the skill's actual workflow. If the user wants help designing the workflow body, offer to continue once the stub is in place.
- If the repo path can't be resolved confidently, stop and ask. Don't scaffold into the wrong location.
- Name collision: if `<repo>/<name>/` already exists, ask before overwriting — this is almost always a mistake.
- Frontmatter must be valid YAML. Descriptions with colons, quotes, or newlines need escaping — prefer keeping descriptions single-line with straight punctuation.
