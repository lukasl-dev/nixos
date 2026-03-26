---
name: zig
description: Work with Zig projects, builds, tests, and stdlib/API discovery. Use when editing Zig code, troubleshooting build/test failures, locating the stdlib with `zig env`, or validating code against the active Zig version instead of relying on memory.
---

# Zig Skill

Use this skill for Zig code and Zig projects.

## First step: inspect the active Zig installation

Run `zig env` before making assumptions.

Use it to find:

- `.zig_exe` — the Zig binary actually being used
- `.version` — the active Zig version
- `.std_dir` — the stdlib directory for that version
- `.lib_dir` — the Zig library root

Do not assume the project is using the Zig version you remember. Zig APIs can change between releases and `master`, including modules like `std.ArrayList` and `std.io`.

When a change depends on stdlib behavior, inspect the relevant file under the `std_dir` reported by `zig env` before editing.

## Stdlib lookup

When you need stdlib details:

1. Run `zig env`.
2. Use the reported `.std_dir`.
3. Open or search the relevant file there instead of relying on memory.

Treat the stdlib as version-specific.

## Testing

Always run tests with:

```bash
zig build test
```

Do not use `zig test` for project validation.

Reasons:

- `zig build test` includes modules wired through `build.zig`
- it exercises the project the way the build defines it
- it avoids drifting from the actual project setup

Run the full test suite every time.

Do not use `--filter-test`; do not try to partially run tests.

## Validation steps

Some projects also define a `zig build check` step. Use it when present to validate the project state before or alongside `zig build test`.

Treat `check` as an additional validation step, not a replacement for tests.

## Practical workflow

- Inspect `build.zig` and `build.zig.zon` when present.
- Check the active Zig version with `zig env` before changing code.
- Verify stdlib symbols against the current `.std_dir`.
- Use `zig build check` when the project defines it.
- Build and test with `zig build test`.
- If a test fails, fix the code for the active Zig version rather than assuming older APIs still apply.
