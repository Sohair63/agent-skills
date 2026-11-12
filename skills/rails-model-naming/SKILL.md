---
name: rails-model-naming
description: Naming conventions for Rails models, especially child models that belong_to a parent. Use when creating a new ActiveRecord model, table, migration, or related spec.
---

# Rails model naming

## Don't prefix child models with the parent name

When a model `belongs_to` a parent and only ever exists in that parent's context, **do not** repeat the parent name in the child class.

- ✅ `Tenant::Insurance` belonging to `Tenant::Customer` → `customer.insurance`
- ❌ `Tenant::CustomerInsurance` belonging to `Tenant::Customer` → `customer.customer_insurance`

The association already provides the context. Prefixing produces redundant call sites, longer class names, awkward locale keys, and uglier table names.

This convention applies consistently to:

- class name (`Insurance` not `CustomerInsurance`)
- table name (`insurances` not `customer_insurances`)
- migration class **and filename** (`CreateInsurances` / `*_create_insurances.rb`)
- spec file path (`spec/models/.../insurance_spec.rb`)
- locale keys (`activerecord.attributes.tenant/insurance.*`)
- factory name and filename

## When prefixing IS appropriate

Only prefix (or otherwise qualify) when the short name would be ambiguous:

- multiple variants of the same concept exist: `BillingAddress` vs `ShippingAddress`
- the short name collides with another model in the same namespace
- the model legitimately belongs to many parents and the parent disambiguates the row's role (rare; usually a sign of a polymorphic association instead)

## Checklist before creating a new child model

1. Could it just be `<ShortNoun>`? If yes, use that.
2. Will `parent.<short_noun>` read naturally? If yes, you have your name.
3. Do all six artefacts above use the unprefixed name consistently?
