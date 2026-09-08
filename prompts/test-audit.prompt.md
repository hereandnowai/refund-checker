---
name: test-audit
description: Audit a test file against the behaviour it is supposed to prove. Finds tests that cannot fail, tests that protect a bug, and behaviour nothing tests.
argument-hint: attach the test file and the spec — e.g. #file:tests/test_rules.py #file:README.md
agent: ask
# This must match a name in your Copilot model picker EXACTLY, or the prompt
# may not run. Open the picker, copy the name, paste it here. Delete this line
# entirely to just use whichever model is currently selected.
model: GPT-5.6 Luna (copilot)
---

# Audit these tests

You are the reviewer who decides whether a green test run means anything. I have attached one or more test files and the document that says what the code is supposed to do — a README, a spec, a policy, a ticket. Read both fully before you answer.

For **every** test in the attached test files — the ones I wrote and the ones that were already there — produce one row in a table with these columns:

| Test | Proves which requirement | Smallest code change that makes it fail | Verdict |

- **Proves which requirement** — quote the numbered point, sentence or acceptance criterion from the attached specification that this test demonstrates. If the test proves no stated requirement, write **"the code's current habit"** — it is testing what the code does, not what it should do.
- **Smallest code change that makes it fail** — name the exact one-line edit to the code under test that would turn this test red. If you cannot name one, the test cannot fail; write **"cannot fail"**.
- **Verdict** — one of:
  - **keep** — proves a requirement and can fail
  - **weak** — can fail, but would also pass on a plausible wrong implementation; say which
  - **protects a bug** — passes on the current code **and contradicts the specification**; quote both sides
  - **delete** — cannot fail, or asserts nothing, or mocks the very thing it claims to test

Then, below the table:

## Requirements nobody tests

List every numbered point or sentence in the specification that no test in the file proves. Boundaries count: if the specification says "within 30 days, day 30 included", a test at day 10 and a test at day 31 do not prove day 30.

## Tests that mock the subject

Name any test that replaces, stubs or monkeypatches the function or module it is supposed to be testing, or the collaborator that does the real work. Explain in one sentence what such a test can no longer detect.

## Rules

- **Do not edit any file.** Report only. I will decide what to change.
- **Do not fix the code** to make a contradicting test pass, and do not rewrite a test to make it agree with the code. When code and specification disagree, say so and stop.
- Cite `file:line` for every claim about the code under test.
- Where you are unsure whether a test can fail, say "unsure" rather than guessing — I would rather check it than trust it.
