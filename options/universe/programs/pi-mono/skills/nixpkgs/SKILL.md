---
name: nixpkgs
description: Search and inspect nixpkgs packages, NixOS options, and module definitions using nix commands and helper scripts. Use when you need authoritative information from a specific nixpkgs branch, tag, or commit. Always use this skill when working with Nix.
compatibility: Requires nix with flakes enabled. Some commands require network access and use --impure.
---

# Nixpkgs Skill

Use this skill when you need information directly from nixpkgs instead of guessing from memory or only searching local files.

## When to use

- Search NixOS options in a specific nixpkgs ref
- Inspect an exact NixOS option, including declarations
- Search packages in a specific nixpkgs ref
- Inspect a package attribute's version and metadata
- Compare results across nixpkgs branches or commits

## Notes

- Replace `REF_NAME` with a branch, tag, or commit SHA such as `nixos-unstable`, `nixos-24.11`, `master`, or a pinned revision.
- Prefer commit SHAs when reproducibility matters.
- Commands using `github:NixOS/nixpkgs/...` may require network access.
- `nix search` searches packages, not NixOS options.

## Helper scripts

All paths below are relative to this skill directory.

### Search NixOS options

```bash
./scripts/search-options.sh REF_NAME QUERY
./scripts/search-options.sh nixos-unstable openssh 10
```

Returns JSON objects with:

- `name`
- `description`
- `type`
- `default`

### Inspect one exact NixOS option

```bash
./scripts/show-option.sh REF_NAME OPTION_PATH
./scripts/show-option.sh nixos-unstable services.openssh.enable
```

Returns JSON with details including:

- `description`
- `type`
- `default`
- `example`
- `declarations`

### Search packages

```bash
./scripts/search-packages.sh REF_NAME QUERY
./scripts/search-packages.sh nixos-unstable ripgrep
```

This wraps `nix search github:NixOS/nixpkgs/REF_NAME QUERY`.

Notes:

- It searches package metadata in the selected nixpkgs ref.
- It does not search NixOS options.
- Output is the normal `nix search` text output, not JSON.
- The displayed attribute names are often useful starting points, but may not always be the exact attr path you want to inspect further.
- After finding a candidate, use `./scripts/show-package.sh REF_NAME ATTR_PATH` to inspect it more precisely.

### Inspect a package attribute

```bash
./scripts/show-package.sh REF_NAME ATTR_PATH
./scripts/show-package.sh nixos-unstable hello
./scripts/show-package.sh nixos-unstable python3Packages.requests
```

Returns JSON with package metadata including:

- `pname`
- `version`
- `description`
- `homepage`
- `license`
- `platforms`
- `broken`
- `insecure`

## Pitfalls

- Branches can change underneath you; use a commit SHA for stable results.
- Some package attrs and option docs differ across channels and branches.
- Evaluating nixpkgs can be expensive.
- Some values are not easily serializable; helper scripts try to return useful JSON summaries rather than raw derivations.
- Attribute names shown by `nix search` are not always the exact attr paths you want to inspect.
