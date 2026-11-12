---
name: branch-self-review
description: Senior review of your own unpushed work before it reaches a reviewer. Invoke only when the user asks for a self-review or says yes to pre-push checks; do not run it automatically after implementation.
---

# Branch self-review

If the project has its own self-review skill or reviewer agents, use those as well.

Sohair pushes this work under his own name. A defect a careful read would have caught costs him credibility with the reviewer. Passing specs and a clean linter are not a review; they only show the code does what you already assumed.

## 1. Establish the scope

```bash
git rev-parse --abbrev-ref HEAD
git status --short
git diff <base>...HEAD --stat
```

Review everything that would land: the commits on the branch **and** uncommitted work. On a stacked branch the base is the parent branch, not the default branch.

Findings are limited to the diff. Pre-existing code you read for context is out of scope, apart from at most two or three non-blocking legacy notes.

## 2. Fan out to independent reviewers

Launch reviewer agents (the project's own reviewer agents if it has them, otherwise `general-purpose`) with the scope stated exactly: branch, base, and whether uncommitted work is included. For a diff spanning more than a few files, launch two in one message, each with a different focus:

- **Correctness and ripple**: what breaks elsewhere and what happens on the failure path (`change-impact-check`).
- **Complexity, naming and tests**: what should be deleted, what a name fails to say, and which failure path has no test (`lean-code`, `code-clarity`).

When the diff touches anything a user sees (views, components, copy, validation or flash messages, emails), add a third reviewer that reads the flow from the user's side: states, forms, feedback, confirmations, mobile, accessibility, wording.

The agents review; they do not edit. When two reports flag the same line for the same issue, keep one, at the higher severity.

## 3. Verify before you act

Open the file for every finding and confirm it. Agents make claims about callers they never read, and a fix built on a wrong finding is worse than the finding. Drop anything that does not hold up.

Then add what only you know: which decisions were guesses, which parts you wrote quickly, and which behaviour nobody has run yet. Review those hardest.

## 4. Fix P1 and P2

- **P1**: wrong behaviour, data loss, a scoping or authorisation hole, a failure path that leaves persisted state inconsistent, lost user input, an irreversible action without a real confirmation, or copy that misstates the system. Never push a P1.
- **P2**: correct but fragile or wasteful. Fix it unless the fix materially grows the change; if it does, say so instead.
- **P3**: leave it, and mention it in the PR description so the reviewer knows it was weighed rather than missed.

Deleting code is a fix. If a finding is unnecessary machinery, remove it.

## 5. Re-verify what you touched

Fixes invalidate the earlier run. Re-run the affected specs, the linter and the security scanner the project uses. Do not invent new specs unless a spec pass was agreed.

## 6. Report

List the P1s and P2s you fixed, and the P3s you left with the reason for each. Name the ripples you checked and cleared, not only the ones that became findings. "The renamed partial has three other callers, all updated" is what shows the review actually happened. If the pass found nothing, say so plainly.
