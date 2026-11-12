---
name: lean-code
description: Write the same behaviour in fewer lines. Use idiomatic language and framework built-ins and the project's own helpers, avoid single-use variables and forwarding methods, and skip defensive checks for impossible states. Use when writing, changing or reviewing any code, and before pushing.
---

# Lean code

Write it the way an experienced developer in this stack would: same behaviour, fewer lines, still easy to read. The examples are Ruby and Rails; the rules apply to any language.

## Use what already exists

Built-ins, the framework and the gems or packages already installed come before a hand-rolled loop:

```ruby
# ❌
with_daily, without_daily = [], []
schools.each do |name, studios|
  (studios.any? { |studio| daily?(studio) } ? with_daily : without_daily) << [name, studios]
end
# ✅
with_daily, without_daily = schools.partition { |_name, studios| studios.any? { |studio| daily?(studio) } }
```

```ruby
# ❌
record = Enrollment.find_by(user: user, studio: studio)
record = Enrollment.create!(user: user, studio: studio) if record.nil?
# ✅
Enrollment.find_or_create_by!(user: user, studio: studio)
```

The project's own helpers, components and base classes come before a local copy. Search for them before writing one.

## Fewer moving parts

```ruby
# ❌ single-use variable
studios = accessible_studios
studios.any?
# ✅
accessible_studios.any?
```

```ruby
# ❌ forwarding method
def school_name = school.name
# ✅
delegate :name, to: :school, prefix: true
```

```ruby
# ❌ private method for a single one-line use
def call = user.update!(settings: merged_settings)
private
def merged_settings = user.settings.merge(key => true)
# ✅
def call = user.update!(settings: user.settings.merge(key => true))
```

```ruby
# ❌
if studio.present?
  if studio.uses_board?
    return true
  end
end
false
# ✅
studio.present? && studio.uses_board?
```

Do not add a class, module, constant or config entry for one call site. Write the line where it is used.

## No defensive code for impossible states

```ruby
# ❌ the association is required and validated
return if enrollment.studio.nil?
```

```ruby
# ❌ a rescue that only hides the failure
def cadence
  preferences.fetch(studio.id)
rescue KeyError
  nil
end
# ✅ when nothing says how a missing key should be handled
def cadence = preferences[studio.id]
```

Do not handle input formats or edge cases nobody described.

## Tests the same way

Skip setup the example never reads. Group related assertions in one example instead of one assertion per example. Use the project's factories and sign-in helpers.

## No narrating comments

Comment only on a constraint the code cannot express. If the code needs narration, fix the names instead.

## Readability still wins

```ruby
# ❌ shorter, but the reader has to decode it
s.map(&:ss).flatten.uniq.reject { _1.a? }.size
# ✅
studios.flat_map(&:sessions).uniq.count { |session| !session.archived? }
```

No code golf and no abbreviated names. If the short version reads worse, keep the clear one.

## Before finishing: the rewrite pass

- Once tests pass, reread every changed hunk and ask how an experienced developer would write it in fewer lines. Rewrite it, rerun the tests, and keep the shorter version if it reads at least as clearly.
- For each added line, ask whether behaviour changes if you delete it. If it doesn't, delete it.
