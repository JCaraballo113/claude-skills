# Config & Setup Gate

Notes are **optional** and configured **once per project**. Preferences and detected capabilities live in a per-repo config file so the skill never re-interrogates the user within a project.

## Config location

`.claude/.teach.md` (repo-local). Each project is asked once; the answer is stored here.

The file holds machine-specific paths and Notion page IDs, so it should not be committed — add `.claude/.teach.md` to the repo's `.gitignore` (or `.git/info/exclude`).

## Schema

```md
---
notes: obsidian            # obsidian | notion | none
style: visual              # visual | balanced | text  (optional; how the learner prefers material)
obsidian:
  cli: obsidian            # resolved invocation for this machine (see OBSIDIAN.md)
  vault: "/path/to/Vault"  # vault root (native or WSL path)
notion:
  learning_page_id: "<uuid>"
  project_page_ids:
    paxoslabs-solana-vaults-standard: "<uuid>"
  topic_page_ids:
    paxoslabs-solana-vaults-standard/rate-sync/net-rate-derivation: "<uuid>"
detected:
  platform: wsl            # macos | linux | windows | wsl
  obsidian: true
  notion: false
  checked: 2026-06-03
---

Notes config for the teach-me skill. Edit `notes:` or delete this file to reconfigure.
```

## Setup gate (runs only when `notes:` is unset for this project)

1. **Detect platform.** `uname -s` → `Darwin`=macos, `Linux`=linux; if `/proc/version` contains `microsoft` (or `$WSL_DISTRO_NAME` is set), it's `wsl`.

2. **Detect backends.**
   - Notion: `command -v ntn`.
   - Obsidian: see detection in [OBSIDIAN.md](./OBSIDIAN.md) (PATH on mac/linux; `Obsidian.com` under `/mnt/c/Users/*/AppData/Local/Programs/Obsidian/` on WSL).

3. **Ask once** with `AskUserQuestion`: *"Save study notes from teaching sessions, and where?"* Offer the detected backends first, plus "No notes". If the user picks a backend whose CLI was **not** detected, prompt them with its install command from [skill.deps.json](./skill.deps.json) and offer to: retry detection / pick the other backend / skip notes for now.

4. **Finish setup for the chosen backend** (discover vault, or run `ntn login` + create the Learning page) per its backend file.

5. **Persist** the answer (including `notes: none` if declined) to `.claude/.teach.md` with the detected capabilities and today's date.

## Reconfigure

If a saved backend later fails (CLI gone, vault moved, `ntn` logged out), tell the user plainly, then re-run the setup gate. The user can also force it by editing `notes:` or deleting the config file.
