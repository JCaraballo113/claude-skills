# Notion Backend

Notes are saved as Notion pages via the `ntn` CLI. Requires `ntn login` (OAuth, browser), live network, and `jq`. Hierarchy: a top-level **Learning** page → one sub-page per project → one page per topic. The note's markdown is the working copy; persist by **rewriting the page markdown** at each checkpoint.

## Setup

```bash
command -v ntn || echo "ntn missing — prompt the user with its install command from skill.deps.json"
ntn login                      # one-time; opens browser (use --no-browser on headless, then 'ntn login poll')
```

Create the Learning page once and cache its ID in config (`notion.learning_page_id`):

```bash
LEARNING_ID=$(jq -n '{parent:{workspace:true},
  properties:{title:{title:[{text:{content:"Learning"}}]}}}' \
  | ntn api v1/pages | jq -r '.id')
```

## Creating pages

Project page (once per project; cache under `notion.project_page_ids[<project>]`):

```bash
PROJECT_ID=$(jq -n --arg p "$LEARNING_ID" --arg t "$PROJECT" \
  '{parent:{page_id:$p}, properties:{title:{title:[{text:{content:$t}}]}}}' \
  | ntn api v1/pages | jq -r '.id')
```

Topic page (once per topic; cache under `notion.topic_page_ids[<project>/<subject>/<topic>]`). Pass the full note markdown as the body:

```bash
TOPIC_ID=$(jq -n --arg p "$PROJECT_ID" --arg t "$TITLE" --arg md "$(cat note.md)" \
  '{parent:{page_id:$p}, properties:{title:{title:[{text:{content:$t}}]}}, markdown:$md}' \
  | ntn api v1/pages | jq -r '.id')
```

Server-side markdown→blocks conversion supports headings, `- [ ]` checkboxes, quotes, code fences, tables — enough for the note template.

## Updating mid-session

Hold the note markdown locally (a scratch file) and rewrite the whole page on each checkpoint:

```bash
jq -n --arg md "$(cat note.md)" \
  '{type:"replace_content", replace_content:{new_str:$md}}' \
  | ntn api "v1/pages/$TOPIC_ID/markdown" -X PATCH
```
(`replace_content` overwrites; this is why we keep the working copy locally and re-push it — simpler than block-level appends.)

## Opening

```bash
ntn pages get "$TOPIC_ID"      # round-trip / verify; print the page URL for the user to open
```

## Note content

Same three-layer structure as the Obsidian template, minus YAML frontmatter (Notion pages don't render it). Put the metadata at the top of the body as a quote/callout line, then the sections:

```md
> project: <project> · subject: <subject> · status: learning · source: <commits · files · ADRs>

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

## Gaps found
```

Flip `status: learning` → `mastered` in the quote line and re-push when done. Cross-page links use Notion @-mentions or the page URL rather than `[[wikilinks]]`.
