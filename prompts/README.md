# Prompt files

Three reusable VS Code prompt files. They name no project, so they work in any repository.

| File | Slash command | Attach |
|---|---|---|
| `understand.prompt.md` | `/understand` | nothing — optionally name the change you plan to make |
| `test-audit.prompt.md` | `/test-audit` | a test file and the spec it should prove — `#file:tests/test_rules.py #file:README.md` |
| `review-diff.prompt.md` | `/review-diff` | a change — `#changes`, `#activePullRequest`, or `#file:some.diff` |
| `pr-description.prompt.md` | `/pr-description` | `#changes`, and optionally `fixes #12` |

**Install:** Command Palette → *Chat: New Prompt File* → choose the **user data folder** → name it after the file → paste the contents → save. Then type `/` in a fresh chat.

The `model:` line must match a name in your model picker exactly. If it does not, delete the line.
