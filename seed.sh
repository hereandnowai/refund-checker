#!/usr/bin/env bash
# seed.sh — make YOUR OWN private copy of refund-checker, set up the way the class needs it.
#
#   ./seed.sh                      creates <your-github-login>/refund-checker
#   ./seed.sh refund-checker <user>   ...and adds <user> as a collaborator (your neighbour, or the trainer)
#
# Run this ONCE, from inside the clone of github.com/hereandnowai/refund-checker.
# You need: git, and the GitHub CLI signed in (`gh auth status`).
#
# What you end up with, in your own repo:
#   main            the app, with three merged pull requests behind it (#1 #2 #3)
#   PR #4           feature/partial-refunds — open, waiting for review
#   issue #5        "Refund refused on day 30"
#   branch rule     main needs one approving review before merge
set -euo pipefail

NAME="${1:-refund-checker}"
COLLAB="${2:-}"
SRC="https://github.com/hereandnowai/refund-checker"

for tool in git gh; do command -v "$tool" >/dev/null || { echo "need $tool installed"; exit 1; }; done
gh auth status >/dev/null 2>&1 || { echo "sign in first:  gh auth login"; exit 1; }
ME="$(gh api user -q .login)"

if [ ! -d .git ] || ! git remote get-url origin 2>/dev/null | grep -q "hereandnowai/refund-checker"; then
  echo "run this from inside a clone of $SRC"; exit 1
fi

echo "==> 1/6  Fetching everything from hereandnowai"
git fetch -q origin --tags
git remote rename origin upstream 2>/dev/null || true

echo "==> 2/6  Creating private repo $ME/$NAME"
if gh repo view "$ME/$NAME" >/dev/null 2>&1; then
  echo "     already exists — continuing"
else
  gh repo create "$ME/$NAME" --private --description "Refund Checker — GitHub Copilot Expert Track, Day 6" >/dev/null
fi
git remote remove origin 2>/dev/null || true
git remote add origin "https://github.com/$ME/$NAME.git"

echo "==> 3/6  Pushing main at the point BEFORE the seeded pull requests"
git checkout -q -B main seed-base
sed -i.bak "s|^\* @.*|* @$ME|" .github/CODEOWNERS && rm -f .github/CODEOWNERS.bak
# lab machines often have no git identity — set one for this repo only, from the GitHub login
[ -n "$(git config user.email)" ] || git config user.email "$ME@users.noreply.github.com"
[ -n "$(git config user.name)" ]  || git config user.name "$ME"
if ! git diff --quiet -- .github/CODEOWNERS; then
  git add .github/CODEOWNERS && git commit -q -m "chore: CODEOWNERS is $ME"
fi
git push -q -u origin main 2>/dev/null
for b in feat/refund-rules feat/web-app docs/refund-policy feature/partial-refunds; do
  git push -q origin "refs/remotes/upstream/$b:refs/heads/$b" 2>/dev/null
done

echo "==> 4/6  Opening and merging PRs #1 #2 #3 (this is the release-notes history)"
pr() { gh pr create --repo "$ME/$NAME" --base main --head "$1" --title "$2" --body "$3" >/dev/null; }
merge() { gh pr merge "$1" --repo "$ME/$NAME" --merge >/dev/null; }
pr feat/refund-rules "Add refund rules and money calculations" \
"## What changed
\`check_refund\` applies the returns-desk policy; \`money.py\` holds the fee maths.
## Why
First slice of the refund checker — the policy as code.
## How I checked it
- [x] \`pytest -q\` passes locally"
merge 1
pr feat/web-app "Add FastAPI app and the Refund Checker page" \
"## What changed
\`POST /api/check\` wraps \`check_refund\`; \`GET /\` serves the page.
## Why
The returns desk needs a screen, not a Python prompt.
## How I checked it
- [x] \`pytest -q\` passes locally
- [x] Tried it in the browser"
merge 2
# docs branch conflicts with main's README footer; merge main into it first, keep its README
git checkout -q docs/refund-policy 2>/dev/null || git checkout -q -b docs/refund-policy origin/docs/refund-policy
git merge -q origin/main -m "Merge main into docs/refund-policy" 2>/dev/null || { git checkout --theirs README.md 2>/dev/null; git checkout docs/refund-policy -- README.md; git add README.md; git -c core.editor=true merge --continue >/dev/null; }
git push -q origin docs/refund-policy 2>/dev/null
pr docs/refund-policy "Document the refund policy and the API" \
"## What changed
README gains the five-point refund policy, an API example and \`run.sh\` instructions.
## Why
The desk manager signed the policy; it belongs next to the code, in plain language.
## How I checked it
- [x] Read each policy point against \`rules.py\`"
merge 3
git checkout -q main && git pull -q origin main

echo "==> 5/6  Opening PR #4 and issue #5"
pr feature/partial-refunds "Add partial refunds for multi-unit orders" \
"## What changed
Customers can now return some of the units in an order. \`partial_refund(order, returned_quantity)\` works out the returned share of the price and shipping, then applies the normal policy. The page has two new fields.
## Why
The desk keeps getting orders of 3 or 4 of the same item where one comes back.
## How I checked it
- [x] \`pytest -q\` passes locally — 12 tests
- [x] I read every generated test and each one would fail if the behaviour were wrong
- [x] \`README.md\` \"Refund policy\" still matches the code
- [x] I tried the change in the browser, not only in tests

Fully tested, all edge cases covered.
## Reviewer, please look at
Nothing in particular — it is a small, self-contained change."
gh issue create --repo "$ME/$NAME" --label bug --title "Refund refused on day 30 — policy says day 30 counts" --body "**Order as entered:** ₹100, books, delivered exactly 30 days ago, unopened

**Decision the checker gave:** denied — \"the refund window has closed\"

**Decision the policy says it should be:** approved — README, Refund policy point 1: *\"Day 30 counts.\"*

**Anything else:** Reported by the Chennai desk. Customer had the delivery note. We refunded by hand." >/dev/null

echo "==> 6/6  Branch rule: main needs one approving review (no status check — Actions may be off here)"
if gh api -X PUT "repos/$ME/$NAME/branches/main/protection" --input - >/dev/null 2>&1 <<'JSON'
{ "required_status_checks": null, "enforce_admins": false,
  "required_pull_request_reviews": { "required_approving_review_count": 1 },
  "restrictions": null }
JSON
then echo "     set"; else echo "     could not set branch protection on this plan — the merge will not be blocked; say so in class"; fi

if [ -n "$COLLAB" ]; then
  gh api -X PUT "repos/$ME/$NAME/collaborators/$COLLAB" -f permission=push >/dev/null && echo "==> invited $COLLAB as collaborator (they must accept)"
fi

echo
echo "Done.  https://github.com/$ME/$NAME"
gh pr list --repo "$ME/$NAME" --state merged | cat
gh pr list --repo "$ME/$NAME" --state open | cat
gh issue list --repo "$ME/$NAME" | cat
echo
echo "Next:  ./run.sh test   (expect 10 passed)"
