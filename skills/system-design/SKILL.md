---
name: system-design
description: Choose the best system-design solution by commissioning an independent architectural audit instead of defending your own proposal. Spawns parallel Plan agents that critique each candidate approach against the actual code and a "least code" constraint, plus a parallel cross-check, then synthesises a verdict. Use when picking an architecture, comparing implementation approaches, or stress-testing a design before building.
---

# System Design

The trap this skill exists to break: you propose an approach, then spend the rest of the conversation defending it. Self-defence finds reasons your idea works; it does not find the idea that is actually best for *this* codebase. The fix is to **stop being the advocate and become the convener** — commission an independent audit, then follow the evidence.

The mechanism: enumerate the real candidates, then **fan out independent `Plan` agents in parallel** — each audits the candidates against the actual code and the **least-code constraint**, with no stake in any one winning — while a **cross-check** agent runs concurrently to attack the front-runner. Synthesise the verdict from what comes back.

Do not skip phases. The value is in the independence, not the speed.

## Phase 1 — Frame the decision (you, inline)

Before spawning anything, write down — briefly — four things. Get these wrong and every agent audits the wrong question.

- **The problem.** One or two sentences. What must the solution do? What is explicitly out of scope?
- **The hard constraints.** What is non-negotiable: existing patterns it must fit (services / facades / concerns / null-objects), data model, multi-tenancy scoping, backward compatibility, performance budget. **The "least code" constraint is always in force** — see below.
- **The candidate approaches.** At least **2**, ideally **3–4**, materially different — not one real plan plus strawmen. Include the obvious/boring one (often it wins) and your own preferred one if you have one. If you can only think of one, that is a signal to explore the code more before auditing.
- **What "actual code" the audit must reckon with.** Name the files, modules, models, and existing conventions a solution lives among. Audits against an imagined codebase are worthless. If you don't know the lay of the land yet, run an `Explore` pass first.

### The "least code" constraint

The winning design is the one that solves the problem with the **least net new code and the least new surface area** — fewest new classes, fewest new abstractions, most reuse of what already exists — *while still meeting the hard constraints and the project's quality bar* (services for logic, Sandi limits, no shortcuts). "Least code" is not "golf" and not "skip the right abstraction"; it is a tie-breaker and a bias against speculative generality. A design that introduces a new pattern the codebase doesn't have must *earn* it against a design that reuses an existing one. Every auditor scores against this explicitly.

## Phase 2 — Commission the independent audit (parallel agents)

Spawn these **concurrently in a single message** (multiple `Agent` tool uses in one turn). Give each the same Phase-1 frame verbatim, so they all audit the same question against the same facts.

**Auditors — 2 to 3 `Plan` agents, each with a distinct lens.** Pick the lenses that fit the decision; typical set:

- **Least-code / reuse lens** — which candidate ships the smallest, most-reuse-heavy diff while meeting constraints? Where does each one duplicate something that already exists?
- **Fit-to-codebase lens** — which candidate sits most naturally in the existing architecture (patterns, layering, naming, multi-tenancy)? Which one fights the grain and will need follow-up refactors?
- **Risk / longevity lens** — where does each candidate break under edge cases, scale, future change, or the existing test surface? Which new abstractions will become tomorrow's debt?

Each auditor must: read the actual named files (not guess), **score every candidate** against the frame and the least-code constraint, name the trade-offs it sees, and **end with a ranked recommendation with reasons** — even if it dislikes all of them. Tell each one explicitly: *you have no stake in any approach; rank on evidence from the code, not on what was proposed first.*

**Cross-check — 1 `Plan` agent, run in parallel with the auditors.** Its job is adversarial: take the approach the convener (you) currently leans toward — state it in the prompt — and **try to refute it**. Find the case where it fails, the cheaper alternative it overlooks, the existing code it ignores or duplicates, the constraint it quietly violates. Default to "this is not the best option" and make it argue its way back. If you have no lean yet, point it at the boringest candidate instead.

Use the `Plan` agent type for all of these (read-only architect; it reads code and returns a plan, never edits). Spawn them with the schema-free `Agent` tool. If the codebase context in Phase 1 is thin, prepend a shared `Explore` pass and feed its map into every agent.

## Phase 3 — Synthesise the verdict (you, inline)

The agents return evidence; you make the call. Do **not** just average their rankings.

1. **Tally the rankings** and, more importantly, *why* — a 2–1 split where the dissent names a concrete code fact beats a unanimous vote built on vibes.
2. **Take the cross-check seriously.** If it landed a real hit on your preferred approach, your preference is wrong — switch. If it whiffed, say why the attack fails. Never wave it away to protect the original proposal.
3. **Resolve disagreement against the actual code**, not by picking the agent you like. When two auditors conflict, open the file they disagree about and settle it.
4. **Apply least-code as the tie-breaker.** When candidates are genuinely close on fit and risk, the smaller-surface-area one wins unless a hard constraint says otherwise.
5. Where the winner is strong but a loser had one better idea, **graft it in** — the output is the best synthesis, not a pure pick.

## Phase 4 — Report

Deliver, concisely:

- **The recommended design** and the one-paragraph case for it, grounded in specific files/patterns.
- **Why the alternatives lost** — one line each, citing the deciding factor (not "it was worse").
- **What the cross-check found** and how the recommendation answers it.
- **The least-code accounting** — what new surface this adds (new classes/abstractions) and what it reuses, and why that's the floor.
- **Open risks** the audit surfaced that survive into implementation.

Then stop for the user's decision — this skill chooses the design; it does not start building it. Hand off to `/plan` or `/implement` once the user approves the direction.

## When to reach for this

- Choosing between materially different ways to build a feature or refactor.
- A design you proposed is being pushed back on and you're tempted to defend rather than re-examine.
- A change touches load-bearing architecture (new pattern, new model, cross-cutting concern) where the wrong call is expensive to unwind.

Not worth it for: one-obvious-way changes, mechanical edits, or anything where the candidates aren't materially different — there's nothing for independent auditors to disagree about.
