# claude-skills

Personal collection of [Claude Code](https://docs.claude.com/en/docs/claude-code) skills, portable across machines.

## Install

Clone anywhere, then run the install script:

```bash
git clone git@github.com:JCaraballo113/claude-skills.git ~/Repos/claude-skills
cd ~/Repos/claude-skills
./install.sh                    # install all skills globally
```

The install script symlinks each skill in this repo into the target skills dir. Because they're symlinks, edits in either location stay in sync — commit from the repo, keep using from `~/.claude/skills/` (or the project `.claude/skills/`).

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

### Uninstall

```bash
./install.sh --uninstall                             # remove all (global)
./install.sh --uninstall <name>                      # remove just one (global)
./install.sh --uninstall --project                   # remove all (project)
./install.sh --uninstall --project <name>            # remove just one (project)
```

## Skills

| Skill | Description |
|---|---|
| [triage-pr-comments](./triage-pr-comments/SKILL.md) | Triage review comments (CodeRabbit, reviewers) on the current branch's open PR. Verifies each claim against actual code, reports validity + priority, asks before committing/pushing, then posts replies that credit the fix commit. |

## Adding a new skill

1. Create a directory at the repo root with the skill name (kebab-case).
2. Add a `SKILL.md` file with frontmatter (`name`, `description`) — see existing skills for examples.
3. Run `./install.sh <name>` to symlink it locally.
4. Commit and push.

The `description` field is what Claude uses to decide when to invoke the skill, so make it specific about the triggers (e.g. "use when user says X" / "use when Y condition").
