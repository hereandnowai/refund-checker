---
name: understand
description: Orientation for a codebase you did not write — what it does, where state lives, what breaks if you change it. Every claim cited, nothing invented.
argument-hint: what you have been asked to change (optional)
agent: ask
# This must match a name in your Copilot model picker EXACTLY, or the prompt
# may not run. Open the picker, copy the name, paste it here. Delete this line
# entirely to just use whichever model is currently selected.
model: GPT-5.6 Luna (copilot)
---

# Understand this codebase

I am a developer working in this repository and I need an orientation before I change anything.

My intended change: **${input:change:leave blank if you are just getting oriented}**

Give me a written orientation covering the following, in this order.

## 1. What this is

What this project does, from a user's point of view, in three sentences. Then its type — web app, API, library, CLI, batch job, something else — and what it is built with.

## 2. How it runs

The runtime topology. Which processes start, in what order, on which ports, and how a request reaches the code. Give me the actual command that starts it, taken from the repository — a README, a Makefile, a script, a compose file — not a command you assume is conventional.

## 3. The shape of the code

Every top-level module or package, and what each one holds in one line. Then, specifically:

- Where does application state live? Name the variables, tables, caches or files that hold it.
- What is the lifetime of that state — request, process, or durable? What happens to it on restart, and what happens if this runs as more than one process?
- Which code paths mutate shared state, and are those mutations safe under concurrent requests? Quote the lines.

## 4. The public surface

Everything the outside world can call: HTTP endpoints, CLI commands, exported functions, queue consumers, scheduled jobs — whichever apply. For each, give its name or path, its inputs, and the exact shape of what it returns.

## 5. Data and dependencies

Where data is persisted and in what schema. Every external dependency and what it is used for. Every external service this talks to.

## 6. What is deliberately absent

Anything a project of this kind usually has that this one does not — tests, authentication, validation, migrations, logging, error handling, CI. This section is often the most useful one, so do not skip it or soften it.

## 7. Blast radius

**Only if I named an intended change above.** For that change, list every file that would have to be modified, one line each on what changes in it. Include configuration, scripts, infrastructure and frontend files, not only the obvious source files. Then list what would break for an existing consumer if this were done carelessly.

If I left the change blank, skip this section entirely rather than inventing a change to analyse.

## 8. Check your own work

List the three claims in this answer you are least confident about. For each, give me the exact command to run or the exact file and line to open so I can verify it myself in under a minute.

---

## Rules

- **Cite a file and line number for every factual claim.** A claim without a citation is not usable.
- **If something is not present in the code, write "not present."** Do not infer it, do not describe what a project like this usually does, and do not fill a gap with a convention.
- **Read before you answer.** If a section requires opening a file you have not read, read it.
- **Do not propose changes, do not recommend improvements, and do not write or edit any code.** This prompt produces understanding only. I will ask for changes separately.
- Where the code and a comment or a README disagree, trust the code and say the documentation is stale.
