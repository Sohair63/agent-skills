---
name: task-preflight
description: Senior, system-level preflight before writing code for any task. Understand the request end to end, map every part of the current system it touches, settle every product decision up front (infer from the code first, then ask everything else in one round), find the failure modes and what will be built on top, and pre-design the code and the PR so nothing ships half built or needs a cleanup PR. Use at the start of every feature, bug fix, integration, data-model, permission or billing change, and for "small" UI/form/validation changes too. Skip only for typos, copy-only edits, log lines and agent-config edits.
---

# Task preflight

You are the system architect, senior engineer and adviser on this change, not a ticket-taker. Aim for a change that is complete on the day it ships, reads cleanly in review, and still holds when the next feature is built on top of it. A bug found later is a design gap found too late. A product question asked after the PR is open means the preflight was skipped.

Writing code is the last step. Do not use it to discover the design.

If the project has its own architecture or audit skill, run that one too. It holds the project's specifics; this skill sets the minimum bar.

## Scale the depth to the change

- **Small** (one form, one validation, one endpoint or screen): do steps 1–3 and 5 in a few lines, inline. Still check every entry point and the existing data. A "small" validation change touches existing invalid records, server and client rules, API clients and error copy, and each of those is a product decision.
- **Feature, integration, data-model, permission or billing change**: do every step and write the brief (step 7) for approval.

When unsure, treat it as the bigger size.

## 1. Close the conversation first

If the request came from a client or is still under discussion, settle it before the audit: product questions answered, direction confirmed, reply sent. Auditing a moving target wastes the work.

## 2. Restate the requirement

In a few lines: who uses it, what they can do afterwards that they could not before, and what "done" means. Keep what was asked separate from what you assume.

## 3. Map the current system, end to end

Read the code; do not infer from names. Name the files for each item:

- **Entry points**: every way a user, job, API client, webhook, import, console task or mobile app reaches the behaviour, including the ones nobody mentioned.
- **Data**: models, columns, constraints, callbacks and scopes involved, and which existing records this change affects on deploy.
- **Source of truth**: who owns each piece of state (our DB, a payment provider, an external service, a feature flag, config). Never keep two writable copies without a way to reconcile them.
- **Neighbours**: features that already do something similar or touch the same records. Reuse them and copy their behaviour; never build a parallel version.
- **External systems**: contract, auth, retries, idempotency, and what happens when the service is down or sends an event twice or out of order.
- **Roles**: every role that sees or is affected by the change, not only the target user.

## 4. Settle product decisions before code

List every decision the change forces: behaviour, wording, defaults, what happens to existing data, who is allowed.

1. **Infer first.** Look for an answer in the code and the product as it is: how neighbouring screens validate, word, default and order things; what the data model already allows; what the issue, the designs or earlier PRs say. If the product already answers the question consistently, follow that answer and state it in the brief as a decision rather than asking it.
2. **Ask the rest at once.** Put every remaining question in one message, each with your recommended answer and the reason for it. Never drip questions out over several turns, and never discover one halfway through the build.
3. **No open questions at implementation.** If a question is still unanswered, do not build around it with a guess that ends up in the PR.

## 5. Find the failure modes

For each one below, the design either handles it or the brief marks it out of scope:

- Existing data on deploy, rollout (feature flag, default, backfill) and rollback.
- Concurrency, retries, duplicate or missed events, and partial failure halfway through.
- Time: time zones, deadlines, midnight boundaries, settings changed while something is in flight.
- Permissions: who must never be blocked (admins, support), and who must never get in.
- Tenancy and scoping: data reaches only the right account or organisation, including users who belong to several.
- Correction: how a wrong state gets fixed, and how anyone can see who changed it.

## 6. Design for what comes next

Name the next two or three features likely to be built on top of this one (from the request, the issue, the roadmap, the client's pricing page). Check that the data shape, the place the logic lives and the names do not block them. Do not build those features now; just do not paint them into a corner.

## 7. Pre-think the code quality

Settle these before writing a line:

- **Where each piece lives**: model, service, job, controller, view or component, following the project's existing patterns. One owner per rule, and no logic copied into a second place.
- **The smallest complete design**: the least code that covers every case from steps 3–5. No speculative options, no new abstraction the codebase does not already use unless it earns its place, and no "while I'm here" changes.
- **Names**: self-describing at the call site and in the product's own vocabulary (see `code-clarity`).
- **Seams**: one place that calls each external system, so specs can stub it and it can be swapped later.
- **What gets deleted or replaced** by this change.
- **PR shape**: what files the diff should touch, and nothing else. If unrelated changes would end up in it, they become a separate PR. Picture the reviewer reading the diff: every line should be obviously necessary.

## 8. Write the brief, then build

For anything bigger than small, write a short brief and get approval before writing code:

1. The requirement and definition of done.
2. The current system map, with file references.
3. The design: data, flow, source of truth, where the code lives.
4. Product decisions: the ones you inferred (with the evidence) and the ones answered.
5. Failure modes and how each one is handled.
6. What comes next and why this design allows it.
7. What is explicitly out of scope.
8. The expected PR footprint.

Then build it in one complete pass and verify every case in the brief before calling it done.

## Not half built

A change is done only when every case in the brief works: existing data, every role, the failure paths, rollout and correction. If something cannot be finished, say so before you start, not after it ships.
