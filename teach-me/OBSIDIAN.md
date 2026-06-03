# Obsidian Backend

Notes are saved as `.md` files in the user's Obsidian vault. The official CLI ships with Obsidian desktop (1.12.7+) and drives the **running** app. Write note bodies **directly to the vault filesystem** (reliable for any markdown, and lets us edit checkboxes/frontmatter in place); use the CLI only to discover the vault path and to open notes.

## Resolving the CLI (store as `obsidian.cli` in config)

| Platform | Invocation |
|---|---|
| macOS | `obsidian` (symlinked at `/usr/local/bin/obsidian`) |
| Linux | `obsidian` (at `~/.local/bin/obsidian`; ensure it's on PATH) |
| Windows | `Obsidian.com` |
| WSL | full path, e.g. `/mnt/c/Users/<User>/AppData/Local/Programs/Obsidian/Obsidian.com` — find with `find /mnt/c/Users -maxdepth 6 -iname 'obsidian.com' 2>/dev/null` |

On WSL, wrap to strip CRLF: ``obsidian() { "$CLI" "$@" | tr -d '\r'; }``. The CLI is not on the Windows PATH by default, so the full-path invocation is expected.

## Finding the vault (store as `obsidian.vault`)

```bash
WIN_VAULT=$(obsidian vault info=path)     # native path; on WSL a Windows path
VAULT=$(wslpath -u "$WIN_VAULT")          # WSL only; on mac/linux use the path as-is
```
Always quote `"$VAULT"` (paths may contain spaces). If this errors, ask the user for the vault path once and cache it.

## Organization

```
<VAULT>/Learning/<project-slug>/<subject-slug>/<topic-slug>.md
```
Slug everything to kebab-case (no spaces). Two MOC index notes, created lazily: `Learning/Learning.md` (lists projects) and `Learning/<project>/<project>.md` (status table of topics).

## Writing / updating

```bash
mkdir -p "$VAULT/Learning/$PROJECT/$SUBJECT"
# write "$VAULT/Learning/$PROJECT/$SUBJECT/$TOPIC.md" with the Write tool (full content)
obsidian open path="Learning/$PROJECT/$SUBJECT/$TOPIC.md"
```
Mid-session, edit the file in place to check boxes and flip `status:`; the running app re-indexes automatically.

## Note template

```md
---
project: <project-slug>
subject: <subject-slug>
topic: <topic-slug>
date: <today>
tags: [learning, <subject-slug>]
status: learning        # learning | mastered
source: "<commits · files · ADRs this grounds in>"
---

# <Title>

> [[<project-slug>]] · #learning/<subject-slug>

## 1. The problem
- [ ] What the problem was
- [ ] Why it existed
- [ ] The branches/approaches on the table

## 2. The solution
- [ ] What was done
- [ ] Why it was resolved this way (the trade-off)
- [ ] Key design decisions
- [ ] Edge cases

## 3. Broader context
- [ ] Why it matters
- [ ] What it impacts downstream

## Notes
_Jot the non-obvious in my own voice — insights, gotchas, the numbers that tripped me up. Terse, not prose._

## Gaps found
_What I got wrong and the fix — short, blunt, first person._
```

## Project index (MOC)

```md
# <project-slug>

> [[Learning]]

| Topic | Subject | Status | Updated |
|-------|---------|--------|---------|
| [[net-rate-derivation]] | rate-sync | mastered | <date> |
```
