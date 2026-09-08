---
name: pr-description
description: Write a pull-request title and description from the actual change — grounded in the diff, honest about what was not tested, in the repository's PR template if it has one.
argument-hint: attach the change (#changes) and optionally the issue it closes — e.g. #changes fixes #12
agent: ask
# This must match a name in your Copilot model picker EXACTLY, or the prompt
# may not run. Open the picker, copy the name, paste it here. Delete this line
# entirely to just use whichever model is currently selected.
model: GPT-5.6 Luna (copilot)
---

# Write the pull request

Write the title and description for a pull request containing the change I have attached. Context I want you to use: **${input:context:the issue this closes, or anything the diff cannot tell you — optional}**

## Before you write

1. Read the diff. Every sentence you write must be traceable to a line in it.
2. Look for `.github/pull_request_template.md` (or `PULL_REQUEST_TEMPLATE.md`). If it exists, **use its headings exactly and fill every section**. If a section asks for something the diff does not show — "tried it in the browser", "read every test" — leave that checkbox **unchecked** and write what would need to happen to tick it. Do not tick what you cannot verify.
3. Look for an issue number in my context above. If there is one, the description must include `Fixes #N` on its own line so the issue closes on merge.

## The title

Under 70 characters. Imperative mood. Says what changes for a user or a caller, not which file was edited. `Count day 30 inside the refund window` beats `Update rules.py`.

## The description

- **What changed** — from the reader's point of view. Behaviour first, files second.
- **Why** — the problem this solves. Link the issue.
- **How it was checked** — only what the diff proves: tests added or changed, and what each one would catch. Do not write "fully tested" or "all edge cases covered" — name the cases.
- **What the reviewer should look at first** — the one line in the diff you are least sure about, with `file:line`.

## Then attack it

After the description, add a short section titled **"Reviewer's note to self"** containing the one claim in your own description that a reviewer should verify before believing, and the command or file that verifies it.

## Rules

- Do not describe changes that are not in the diff, even if they seem like they should be.
- No filler: no "this PR", no "in this pull request", no restating the title.
- Plain text and markdown only. Output the title on its own first line, then a blank line, then the description — so I can paste both straight into GitHub.
