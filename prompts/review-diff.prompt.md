---
name: review-diff
description: Review a change as the person who has to sign off on it — what it does, what is wrong, what it touches that the diff does not show, and whether its tests could fail.
argument-hint: attach the change — #changes for uncommitted work, or #file:some.diff
agent: ask
# This must match a name in your Copilot model picker EXACTLY, or the prompt
# may not run. Open the picker, copy the name, paste it here. Delete this line
# entirely to just use whichever model is currently selected.
model: GPT-5.6 Luna (copilot)
---

# Review this change

You are the reviewer whose approval lets this change merge. Nobody checks after you. Review the change I have attached — and open the surrounding files, not only the changed lines, because most defects live in what the diff does not show.

## 1. What this change actually does

Two or three sentences, derived from the diff itself — not from its commit message or description. If the description claims something the diff does not do, say so here.

## 2. Findings

A table, most serious first:

| # | File:line | Severity | Finding | Why it matters | Exact fix |

Severity is one of **blocker** (wrong result, data loss, security, silent failure), **should fix** (correct today, fragile tomorrow), **nit** (style — only if it hides a real problem).

Look specifically for:
- errors caught and swallowed, or turned into a normal-looking result
- arguments or shared state mutated when the caller would not expect it
- boundaries: `<` vs `<=`, off-by-one, empty input, zero, `None`
- money or time handled with floats, `round()`, or the local clock
- a check that can never run because an earlier line already returned
- anything the change adds that the project's README, spec or instructions file forbids or does not mention

## 3. What the diff does not show

Everything this change affects that is not in the diff: callers of changed functions, documentation that now disagrees, configuration, other tests, the UI. One line each.

## 4. The tests

For each test added or changed: would it fail on the code **before** this change? If not, what does it prove? Name any test that mocks the function it claims to test, or the collaborator that does the real work.

## 5. Questions for the author

Only questions whose answer would change your verdict.

## 6. Verdict

One line: **Approve**, **Approve with nits**, or **Request changes** — and the single finding that decided it.

## Rules

- Every finding cites `file:line`. A finding without a location is an opinion.
- **Do not edit any file.** You review; the author fixes.
- Do not pad. If the change is good, section 2 is empty and you say so in one sentence.
- If you cannot open a file you need, say which one and stop rather than guessing.
