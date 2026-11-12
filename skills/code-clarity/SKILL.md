---
name: code-clarity
description: Naming, consistency and shape rules Sohair expects in review — self-describing method and variable names, sibling APIs that behave alike, aligned i18n keys, no vague jargon, no over-engineering. Use when writing or reviewing any Ruby, ERB, i18n or JS change, and before pushing a branch.
---

# Code clarity

Sohair reviews for names first. A reviewer who has to open a method to learn what it
does has found a bug in the name, not in themselves.

## Names must say what they do

Every method, variable, constant and symbol has to be understandable from the call
site alone, without reading the body.

- ❌ `warm(products)` — warm what, and what does warming mean?
- ✅ `prefetch(products)` — it fetches ahead of time.

The test: read the call site out loud. If you cannot say what happens next, rename it.

Applies equally to:

- **predicates vs collections** — do not give a filter and a predicate the same name.
  `priced_by_erp?(product)` (predicate) next to `priceable_by_erp(products)` (filter),
  never `priced_by_erp` for both.
- **flag constants** — name them for the fact they record. `ARTICLE_UNKNOWN = false`
  beats `NO_PRICE = false`; the caller needs to know *why* there is no price.
- **detail/reason symbols** — keep one family. `:no_erp_pricing`, `:no_contract_price`,
  `:not_from_erp` read as a set; `:other_erp_product` does not.
- **memo variables** — match the method. `@catalogue_stamped_by_erp` for
  `catalogue_stamped_by_erp?`.

## Sibling APIs behave alike

Two methods that sit next to each other and do the same kind of job must handle the
same edge cases the same way. If `client_for` raises on an unsupported ERP,
`contract_pricing_for` raises too — silently returning `nil` from one and raising from
the other is the inconsistency a reader will trip on.

Distinguish deliberately between "not configured" (a legitimate `nil`) and "configured
but unsupported" (raise). Do not collapse them into one silent `nil`; see the sibling
rule about silent rescues.

## i18n keys match their neighbours

A new key adopts the shape of the keys around it. Do not nest one child under a parent
just to name it:

```yaml
# ❌
checkout:
  contract_price_missing:
    tooltip: "Catalogue price…"

# ✅
checkout:
  contract_price_missing: "Catalogue price…"
```

Add to `en.yml` and `de.yml` at the same path, then run `bin/i18n_check`.

## English on our side of the boundary

The external system's German stops where we parse it. `params[:Filiale]` is the TopM
XML parameter and stays German; everything upstream of it is `shop_number`. A German
identifier appearing in a method signature, a local, a hash key or a cache key part is
a bug. Same for env vars in rake tasks: `CUSTOMER_NUMBER`, not `KUNDE`.

## Comments

Only for a constraint the code cannot express. Never narrate what the next line does —
if the code needs narrating, the names are wrong. Put the reasoning in the commit
message instead, where it belongs and where it does not rot.

## Split for clarity, not for architecture

Break a method up when a piece of it has a name worth reading. Do not introduce a
class, a module, a service object or an abstraction layer because a change *might*
need it later. Propose the lightest thing that works and let Sohair ask for more.

## Destructive defaults

A maintenance task's no-argument path must not be the destructive one.
`Rails.cache.clear` behind a missing env var is a footgun; require the arguments and
gate the blunt version behind an explicit `ALL=1`.

## Before pushing

- names read correctly at every call site
- `bin/rubocop` clean
- `bin/i18n_check` parity OK
- specs run **alone** — a concurrent suite against the same tenant test DB produces
  deadlocks, FK violations and uniqueness errors that look like real failures
