---
name: done-verification
description: Run before reporting any feature or bug fix as done, and before handing work over for manual testing. Exercises the change against existing data, changes over time, neighbouring actions on the same record, rollout, every role, odd data shapes and presentation, then reports what was and was not checked in an axis table. Also the list a spec pass must cover.
---

# Done verification

If the project has its own verification skill, use that one as well; it holds the project's roles, ports, sign-in and tooling.

Sohair should never be the first person to find a defect a scripted check could have found. Defects found by hand after specs pass are rarely exotic. They sit just outside the path the code was written for: a duplicate created when a parent record changes, a new default that never reaches existing rows, an admin who cannot see the thing, a parent screen nobody opened, dark mode left unchecked, an item reported done that was never built.

Passing specs prove only what was already assumed. Factories build fresh rows, one role per person, complete data and today's defaults, so none of the defects above fail a spec.

## When to run

- Before saying a feature or fix is done, or asking anyone to test it.
- Again after any follow-up change, for the axes the change touches.

This is verification, not a spec pass. It writes no spec files.

## The axes

Walk every axis. Either run it or write down why it does not apply, with a reason a reviewer would accept.

1. **Requirement walk.** List every item asked for in this task. Open the screen or call the path for each and watch it work. Never report an item done from reading the diff.
2. **Existing data.** For every new or changed default, setting, scope or rule, count the existing rows that will **not** get the new behaviour (a changed default never reaches existing rows). State the count, and ask before relying on a backfill or leaving them. Also query for records earlier code left in odd states, and run the feature against one of each.
3. **Changes over time.** Run the lifecycle of each record the feature creates or reads: create it, change what it hangs off (owner moves, role changes, parent archived or added), archive and restore, run any sync twice. Expect no duplicates and nothing orphaned. Assert the record a person acts on (the bill, its status and amount), never only a computed total.
   - **Every action from every state**: list the states the record can be in and run every new action from each one.
   - **Neighbouring actions**: list the existing actions on the same record or screen (pay, unpay, refund, cancel, edit, archive). Run each one before and after the new action, in both orders, then undo the new action. Print a grid of state × action. A database rollback never undoes a call to a payment provider, so run those cells only with the provider stubbed or in confirmed test mode; otherwise mark them not run.
4. **Rollout.** If a flag or setting gates the feature, turn it on for an account that already has data, turn it off and on again, and turn it on the way admins actually do (through the app's own UI or service, so its setup hooks run). Check what people see while background work is still running.
5. **Roles.** Script or sign in as each role the feature can reach: top-level admin with no membership, scoped admins, the target user, a peer in another group, read-only or limited users, and one user holding several roles. For each, check what they see, what they can do, how they are labelled and who gets notified. An admin-only feature still reaches the people it changes things for, so open their pages too.
6. **Data shapes.** Test the shapes factories never build: missing optional relations, empty lists, several groups or tenants, very long names, every accepted file type, and one record that spans the kinds the feature tells apart.
7. **Presentation.** Check every touched screen in light mode, dark mode and at phone width (390 px). Check identity rendering and every empty, loading and error state. Render each new string where custom terminology applies and read it.

## How to run it

- Use only the local dev database and server. Never touch staging or production.
- **Scripted scenarios**: write a script in the scratchpad (for Rails, `bin/rails runner`). Wrap every write in a transaction and roll it back, and print each observed value next to the expected one so the output reads as pass or fail. A rolled-back transaction never runs after-commit callbacks, so it proves what a job does, not that the job gets triggered. Check the trigger separately or list it as not run.
- **Browser**: use Playwright against a server on a port that is not the developer's own. Capture each touched screen in each theme and width, look at every capture, and stop the server afterwards.
- **Existing specs**: run the spec files for the code you changed.

If something cannot be run locally (production volumes, push delivery, email), say so. Never imply it was checked.

## Report

Every "done" message ends with one row per axis:

```md
| Axis | What I ran | Result |
|---|---|---|
| Existing data | counted accounts still on the old default | 2,559 keep the old value; asked how to handle |
| Roles | admin without membership, target user, limited user | admin can read without a membership |
| Presentation | light, dark, phone for the two touched screens | header stayed white in dark mode → fixed |
| Changes over time | not run | the change has no record lifecycle |
```

List each defect fixed during verification together with its fix. List each axis not run, with the reason. Never write "verified" or "done" over an axis that was not run.

## Spec pass

When a spec pass is agreed, each row that found a defect or exercises a lifecycle, rollout or role rule gets one example. Build it on realistic data (records from before a default changed, multi-role users, a second sync run), not only on fresh factory defaults.

## In review

- A "done" report with no axis table: **P1**
- An axis marked as run with no script or screenshot behind it: **P1**
- A changed default reported without the count of existing rows it misses: **P1**
- No neighbouring-actions grid for a record other actions also change: **P1**
- A flag-gated feature never turned on for an account with existing data: **P2**
- A touched screen with no dark-mode capture, or a user-visible feature checked as one role only: **P2**
- A lifecycle step asserted on a computed total instead of the record: **P2**
