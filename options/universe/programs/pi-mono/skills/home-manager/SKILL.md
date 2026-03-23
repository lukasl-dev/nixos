---
name: home-manager
description: Search Home Manager options from the published options manual. Use when you need authoritative Home Manager option docs.
compatibility: Requires network access. Reads the published Home Manager options page from nix-community.github.io.
---

# Home Manager Skill

Use this skill when you need information directly from the published Home Manager options documentation instead of guessing from memory or only searching local files.

## When to use

- Search Home Manager options by name
- Inspect option descriptions, types, defaults, and declaration links
- Quickly find matching Home Manager options without evaluating nixpkgs locally

## Notes

- This skill reads the published Home Manager options page at `https://nix-community.github.io/home-manager/options.xhtml`.
- Results are based on the currently published docs, not an arbitrary git ref.
- Matching is case-insensitive and searches option names.
- Descriptions are truncated to keep output compact.

## Helper scripts

All paths below are relative to this skill directory.

### Search Home Manager options

```bash
./scripts/search-options.sh QUERY
./scripts/search-options.sh firefox 20
```

Returns a JSON array of objects with:

- `name`
- `description`
- `type_info`
- `default_value`
- `declared_by`

## Pitfalls

- This uses the published website, so results depend on whatever version of the docs is currently deployed.
- HTML parsing is best-effort and may need updates if the upstream page structure changes.
- Network access is required.
