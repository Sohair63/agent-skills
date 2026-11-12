---
name: change-impact-check
description: Blast-radius check. Before shipping any change, prove it does not break the other paths that reach the changed code. Use when editing a shared method, callback, service interface, constant, enum, query or scope, view partial or anything with more than one caller, and as the final gate before committing or opening a PR.
---

# Change impact check

If the project has its own ripple or impact skill, use that one as well; it holds the project's specifics.

## The rule

> A change is done when every other path that reaches the changed code has been checked and shown to still be correct, not when the target path works.

The bug this prevents: you fix path A by editing shared code S, and silently change paths B, C and D that also run through S. A's tests pass; B, C and D break in production.

## When it matters most

- Changing the **behaviour inside** a method whose signature stays the same. Callers still run and break silently. This is the most dangerous kind.
- Changing callback timing or conditions, or validation guards.
- Changing a signature, default argument, return shape, constant or enum value.
- Changing a partial or component rendered from several places.

## The loop

1. **Map the callers.** Grep every reference to the symbol you changed, including specs, jobs, rake tasks, and other callbacks. For a callback or condition, list every path that triggers it.
2. **Classify each caller.** For each one, does it reach the branch, argument or timing you changed?
   - **Reaches it**: verify the new behaviour is correct for that caller.
   - **Avoids it**: confirm it lands on an unchanged path.
   - **Unclear**: read it. Do not assume.
3. **Walk the checklist below.**
4. **Cover every caller that reaches the change** with an existing passing spec, a manual check, or a new spec if a spec pass was agreed. If a path is out of scope, say so in the PR body.
5. **Report the blast radius**: what reaches the code, which paths change behaviour, which do not, and how each changed path was checked. For example: "Checked X, Y, Z; only X changes; covered by spec S." Never stay silent about it.

## Where ripples hide

- [ ] **Direct callers**: every grep hit classified.
- [ ] **Signature and defaults**: added, removed or reordered params and changed defaults are reflected at every call site. Positional `nil` arguments are landmines; count them again.
- [ ] **Return shape**: callers that destructure, index, call `.success?` or pattern-match the result still work.
- [ ] **New branch inside a shared method**: which callers can now reach it?
- [ ] **Callback timing**: in-transaction vs after-commit. Does anything read the side effect before commit? Jobs enqueued inside a transaction can run against a row that is not committed yet, or was rolled back.
- [ ] **Callback conditions**: tightened or loosened guards. Do other update paths still fire it, or now fire it wrongly?
- [ ] **Shared in-memory state**: memoised values or request-global state read after the data changed can be stale.
- [ ] **Shared partials and components**: every render path (sibling actions, error re-renders, streamed updates) passes what the partial now expects.
- [ ] **Constants, enums and scopes**: a changed value reaches every query and comparison that uses it.
- [ ] **Rewritten conditions**: when a guard or visibility rule is rewritten (denylist to allowlist, `!= x` to `in?(list)`, reusing an existing status list), list every value the old and new conditions treat differently. Each one is either named in the request or is scope creep. Keep the old outcome for values nobody asked about, and grep copy, tooltips and specs that promise behaviour for them.
- [ ] **Null objects**: a placeholder whose `id` is `nil` can collide with records that genuinely have none.
- [ ] **Specs are a net, not a proof**: passing specs cover only the paths that have specs. A mocked collaborator proves the call was made, not that the real collaborator still behaves.

## Two regressions this loop catches

**Shared service, two callers.** A fix gated every removal in a `RemoveUser` service on current eligibility. That fixed enrolment, but the email-change path also called the service, to remove the *old* address, and still-eligible users now kept stale access. The only spec mocked the service. Mapping the callers would have shown two behaviours running through one method. The right fix gates only the current-email path and removes the old address unconditionally.

**Allowlist that dropped a value.** A request to hide *draft* items replaced a denylist with an existing status allowlist, which also dropped *archived* items. A tooltip still promised those stayed usable. The PR and a new spec recorded the side effect as if it were the requirement. Listing the values the two conditions disagree on (draft: requested; archived: not) would have caught it.

## In review

Flag, diff-scoped: a new branch in a multi-caller method with no check on the newly reachable behaviour; a callback timing or condition change with no statement of the affected paths; a shared partial not updated for every render path; a rewritten condition whose PR body does not list each value it changes. Severity scales with the number of callers.
