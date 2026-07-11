---
name: add-agent-skill
description: Scaffold a new agent skill. Interviews for purpose, triggers, and name, picks the destination (global ~/.claude/skills, project .claude/skills, or the user's own skills repo/plugin), and writes a SKILL.md with proper frontmatter plus a skill.deps.json when the skill has external deps. Leaves the workflow body for the user to fill in; never commits or pushes. Use when the user says "add an agent skill", "scaffold an agent skill", "new agent skill", or wants to start writing a new skill.
---

# Add Agent Skill

Scaffold a new skill. The goal is a clean stub with correct frontmatter —
the user fills in the workflow body themselves, or with follow-up help.
This skill only creates files: no commits, no pushes — version control
and publishing are the user's business.

## Step 1 — Pick the destination

Ask where the skill should live (AskUserQuestion):

- **Global** — `~/.claude/skills/<name>/`: available in every project on
  this machine.
- **Project** — `<repo>/.claude/skills/<name>/`: ships with the current
  repo.
- **Own skills repo / plugin** — the user names the path. Confirm it
  before writing; a Claude Code plugin repo has
  `.claude-plugin/plugin.json` at its root.

Never scaffold into an **installed** plugin's directory — installed
copies are managed by the plugin system and get overwritten on update.

## Step 2 — Interview the user

Ask for these, one at a time or in a single message — whichever fits the
flow. Keep it short.

1. **What does the skill do?** One or two sentences. This shapes the
   description and purpose.
2. **When should Claude invoke it?** What phrases would the user type?
   (e.g. "triage the PR comments", "what's the status of X"). These
   become the trigger examples in the description.
3. **Suggested name** (kebab-case, lowercase, short). Propose one based
   on the purpose; let the user override.

If the user gives terse answers, don't re-interview — work with what you
have and show a draft in step 3.

## Step 3 — Draft the frontmatter, show to user first

The `description` field is what Claude uses at skill-resolution time, so
it has to do two jobs:

- **State what the skill does** in plain language (first sentence or two).
- **List trigger phrases** near the end: "Use when the user says X, Y, Z,
  or ...".

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

Show the drafted frontmatter + title + outline (not full body) to the
user. Wait for approval or edits before writing to disk. Push back on:

- Descriptions that are too vague to discriminate ("help with code") —
  they'll over-trigger.
- Descriptions without trigger examples — Claude won't know when to
  invoke.
- Names that collide with a skill already in the destination (check by
  listing its directories) or in the available-skills list.

## Step 4 — Write the files

Create `<destination>/<name>/SKILL.md` with the approved frontmatter and
the outline. Leave placeholder content under the step headings —
explicitly marked as TODO so the user knows to fill it in:

```markdown
### 1. <First step>

TODO: describe what happens here.
```

Do **not** invent a workflow body the user didn't ask for. The skill is
a stub — the user completes it.

If the skill will need anything not installed alongside it — external
skills, MCP servers, system CLIs — scaffold `<name>/skill.deps.json`
too: a map of dep name → install command, using an object keyed by
`darwin`/`linux`/`win32` when the command is OS-dependent. Have the
SKILL.md prompt the user with the install command when a dep is missing.

## Step 5 — Make it available

- **Global / project destination**: nothing to install — Claude Code
  picks the skill up on the next session start.
- **The user's own plugin repo**: their plugin flow applies. Remind them
  that plugin updates are version-gated — bump the plugin version in
  `.claude-plugin/plugin.json` before pushing, then refresh with
  `/plugin marketplace update <their-marketplace>` and `/reload-plugins`
  (user-run slash commands — you can't execute them). If the repo keeps
  a skills index (e.g. a README table), offer to add a row.

## Notes

- This skill scaffolds; it doesn't write the skill's actual workflow. If
  the user wants help designing the workflow body, offer to continue
  once the stub is in place.
- If the destination can't be resolved confidently, stop and ask. Don't
  scaffold into the wrong location.
- Name collision: if `<destination>/<name>/` already exists, ask before
  overwriting — this is almost always a mistake.
- Frontmatter must be valid YAML. Descriptions with colons, quotes, or
  newlines need escaping — prefer keeping descriptions single-line with
  straight punctuation.
