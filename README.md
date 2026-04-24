# claude-skills

Personal collection of [Claude Code](https://docs.claude.com/en/docs/claude-code) skills, portable across machines.

## Install

Clone anywhere, then run the install script:

```bash
git clone git@github.com:JCaraballo113/claude-skills.git ~/Repos/claude-skills
cd ~/Repos/claude-skills
./install.sh                    # install all skills globally
```

Each install is a **copy**, not a symlink. The repo folder and the installed skill are independent — deleting or moving the repo later doesn't break the installed skills.

### Global vs project scope

```bash
./install.sh --global                     # default: ~/.claude/skills/ (all projects see it)
./install.sh --project                    # $(pwd)/.claude/skills/ (just this repo)
```

### Install a single skill

```bash
./install.sh triage-pr-comments                      # global
./install.sh --project triage-pr-comments            # project-local
```

### Updating installed skills

When you pull new versions from origin, re-run install to sync:

```bash
cd ~/Repos/claude-skills
git pull
./install.sh                                          # re-copies everything
./install.sh triage-pr-comments                      # re-copy just one
```

Re-install safely overwrites skills this repo owns (tracked via a `.installed-from` marker file). It won't clobber skills that came from somewhere else — if there's a name collision and the existing skill isn't ours, install skips with a warning.

### Uninstall

```bash
./install.sh --uninstall                             # remove all (global)
./install.sh --uninstall <name>                      # remove one (global)
./install.sh --uninstall --project                   # remove all (project)
./install.sh --uninstall --project <name>            # remove one (project)
```

Uninstall only removes skill directories whose `.installed-from` marker matches this repo — safe to run even if you have unrelated skills in the same dir.

## Editing workflow

The installed copy is a snapshot. To change a skill:

1. Edit in the repo: `~/Repos/claude-skills/<skill>/SKILL.md`
2. Commit + push
3. Re-run `./install.sh <skill>` to update the installed copy

Do **not** edit files inside `~/.claude/skills/<skill>/` directly — those edits will be overwritten on next install and don't get tracked in git.

## Skills

| Skill | Description |
|---|---|
| [add-agent-skill](./add-agent-skill/SKILL.md) | Scaffold a new agent skill in this repo. Interviews for name and triggers, writes the frontmatter + outline, installs locally, and suggests a commit. Use when starting a new skill. Named `agent-skill` to avoid collision with a potential future Anthropic-shipped `add-skill`. |
| [pr-review-status](./pr-review-status/SKILL.md) | Read-only overview of the current branch's PR review comments — groups into addressed / pending / in-discussion / deferred. No edits, no posts. Pair with `triage-pr-comments` when you want to act on what you see. |
| [triage-pr-comments](./triage-pr-comments/SKILL.md) | Active triage workflow: classifies each comment into one of five states (valid-fix / partial / invalid / defer / needs-info), asks clarifying questions when ambiguous, implements approved fixes, and gates commit/push/reply on explicit user approval. |

## Adding a new skill

1. Create a directory at the repo root with the skill name (kebab-case).
2. Add a `SKILL.md` file with frontmatter (`name`, `description`) — see existing skills for examples.
3. Run `./install.sh <name>` to install it locally.
4. Commit and push.

The `description` field is what Claude uses to decide when to invoke the skill, so make it specific about the triggers (e.g. "use when user says X" / "use when Y condition").
