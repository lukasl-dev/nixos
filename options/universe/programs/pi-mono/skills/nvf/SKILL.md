---
name: nvf
description: Search nvf options and inspect its manual from a specific branch, tag, or commit. Use when you need authoritative information from a specific nvf ref.
compatibility: Requires nix with flakes enabled for option search. Manual commands require network access.
---

# nvf Skill

Use this skill when you need information directly from the nvf repository instead of guessing from memory or only searching local files.

## When to use

- Search nvf options in a specific nvf ref
- Inspect nvf manual page names from a specific ref
- Read a specific nvf manual page from a branch, tag, or commit
- Compare results across nvf branches or commits

## Notes

- Replace `REF_NAME` with a branch, tag, or commit SHA such as `main`, a release tag, or a pinned revision.
- Prefer commit SHAs when reproducibility matters.
- Option search evaluates `github:NotAShelf/nvf/REF_NAME` and imports `<nixpkgs>` from the local Nix environment.
- Manual commands use the GitHub API and raw GitHub content, so they require network access.

## Helper scripts

All paths below are relative to this skill directory.

### Search nvf options

```bash
./scripts/search-options.sh REF_NAME QUERY
./scripts/search-options.sh main vim.lsp 20
```

Returns JSON objects with:

- `name`
- `description`
- `type`
- `default`

### List manual pages

```bash
./scripts/list-manual.sh REF_NAME
./scripts/list-manual.sh main
```

Returns a sorted JSON array of manual page paths relative to `docs/manual/`, without the `.md` suffix.

### Read one manual page

```bash
./scripts/read-manual.sh REF_NAME MANUAL_PATH
./scripts/read-manual.sh main configuring/languages/lsp
```

Returns the raw Markdown contents of `docs/manual/MANUAL_PATH.md`.

## Pitfalls

- Branches can change underneath you; use a commit SHA for stable results.
- nvf option docs can differ across branches and revisions.
- Option evaluation depends on the local `<nixpkgs>` available in the Nix environment.
- GitHub API rate limits may apply when listing manual pages repeatedly.
