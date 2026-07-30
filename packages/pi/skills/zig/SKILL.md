---
name: zig
description: Work with Zig projects, builds, tests, stdlib/API discovery, and idiomatic architecture. Use when reading or writing Zig, designing comptime APIs, troubleshooting build failures, or validating code against the active Zig toolchain.
---

# Zig

Use these as defaults unless the repository says otherwise.

## Start with the active toolchain

Run `zig env` before making assumptions. Check:

- `.zig_exe`
- `.version`
- `.std_dir`
- `.lib_dir`

Zig's APIs move quickly. When code depends on stdlib behaviour, inspect the
active source under `.std_dir`; do not write from memory or target another Zig
release by accident.

Read `build.zig` and `build.zig.zon` before changing build or test behaviour.

## Write direct Zig

- Prefer simple, flat control flow. Use early exits and clear phases.
- A reasonably long function is better than a trail of one-use helpers.
- Add a helper when it names a real operation, owns an invariant, or removes
  genuine duplication—not merely to shorten the caller.
- Keep hot paths allocation-free when practical. Prefer caller-owned or
  preallocated storage over hidden allocation.
- When a set of types is known at comptime, specialise and dispatch directly.
  Avoid runtime registries, function-pointer tables, and type erasure unless
  the runtime variability is real.
- Do not force inlining on intuition. Let the optimiser work unless a measured
  experiment shows that an explicit choice helps.
- Optional hooks should be optional declarations. Do not require empty no-op
  methods just to satisfy an interface.

## Use the type system

- Give domain values concrete types. Use `anytype` only when the operation is
  genuinely generic, not to avoid deciding where a shared type belongs.
- Put shared event and protocol types in a small neutral module when that
  avoids dependency cycles.
- Compare enums and union tags as values:

  ```zig
  const tag = std.meta.activeTag(value);
  if (tag == .item) { ... }
  ```

  Prefer this or a `switch` to `@tagName()` followed by string comparison.
  String-based field matching is acceptable for comptime reflection over a
  generated union, but not for runtime dispatch between known tags.
- Prefer named option structs to positional booleans. For a comptime type
  factory, use the direct name:

  ```zig
  pub const ParserOptions = struct {
      feature: bool = false,
  };

  pub fn Parser(comptime options: ParserOptions) type { ... }
  ```

  Do not add a `ParserWith` alias when `Parser(options)` is the actual API.

## Keep modules independent

- A module owns its own syntax, state, and invariants.
- Do not make one module import or name another merely to special-case it.
- Keep low-level utilities domain-neutral. Syntax and policy stay with the
  module that owns them.
- Route collaboration through a typed shared event, a small protocol, or the
  component that owns the composition.
- When walking heterogeneous state, handle the module's own tags directly and
  let an unrelated state stop or decline propagation. Do not identify foreign
  modules by tag-name strings.
- Put cross-module precedence and policy in composition code rather than in
  either participant.
- Core dispatch should use the shared protocol, not switch on the concrete
  modules selected by a configuration. If order affects correctness, encode
  explicit precedence instead of relying on registration order.

## Names, comments, and documentation

- Use names that say what the operation does. Avoid vague verbs such as
  `note`, `handle`, or `process` when a precise verb exists.
- Comments explain intent, invariants, ownership, or a non-obvious constraint.
  Do not narrate the next line of code.
- Use British English in comments and prose unless spelling an API or standard
  term verbatim.
- Field comments begin with lowercase and omit the trailing full stop.
- Keep public documentation concise and concrete. Write like a maintainer, not
  a product page: avoid filler, sales language, and generic corporate prose.
- Prefer a small diagram or example when it explains control flow better than
  several paragraphs.

## Validation

Format touched Zig files with `zig fmt`.

Always run the project's full build-driven tests:

```bash
zig build test
```

Do not substitute `zig test` for project validation, and do not rely on a
filtered test run. `zig build test` includes the modules and options wired by
`build.zig`.

When the project defines a check step, run it as well:

```bash
zig build check
```

For code that ships optimised, validate both the default mode and ReleaseFast:

```bash
zig build check
zig build test
zig build check -Doptimize=ReleaseFast
zig build test -Doptimize=ReleaseFast
```

Finally run `git diff --check`. Fix failures for the active Zig version rather
than working around them with assumptions from an older release.
