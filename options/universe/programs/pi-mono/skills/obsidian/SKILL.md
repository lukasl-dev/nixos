---
name: obsidian
description: Use the `obsidian` CLI for non-interactive vault inspection and debugging, especially links, backlinks, and developer console checks after edits. Always use this skill when working in Obsidian vaults.
compatibility: Requires the `obsidian` CLI. Never run bare `obsidian` because it enters interactive mode.
---

# Obsidian Skill

Use this skill when working with the `obsidian` CLI in a **non-interactive** way.

This skill is mainly for:

- link and backlink inspection
- unresolved-link inspection
- reading note metadata from the vault
- developer debugging after note edits
- checking console output after TikZ/TikZJax edits

## Core rule

Never run:

```bash
obsidian
```

Bare `obsidian` enters interactive mode and should not be used by the agent.
Always run a concrete subcommand.

## Important workflow for TikZ / TikZJax edits

After creating or editing TikZ pictures in Obsidian notes, use the developer debugging commands.

Important order:

1. First enable debugging:

```bash
obsidian dev:debug on
```

2. Then make the note edits.

3. After the edits, inspect the console:

```bash
obsidian dev:console
```

This order matters because if debugging was not enabled before the edit, you may not capture the relevant console output.

Useful variants:

```bash
obsidian dev:console limit=100
obsidian dev:console level=error
obsidian dev:console clear
obsidian dev:debug off
```

Use this workflow especially when a TikZJax snippet may have failed to render.

## Link-related commands

These are the most important content-inspection commands.

### Outgoing links

Use `links` to inspect links from a note:

```bash
obsidian links file="My Note"
obsidian links path="Knowledge/Topic.md"
obsidian links file="My Note" total
```

Use this when you want to know what a note links to.

## Backlinks

Use `backlinks` to inspect which notes link to a target note:

```bash
obsidian backlinks file="My Note"
obsidian backlinks path="Knowledge/Topic.md"
obsidian backlinks path="Knowledge/Topic.md" counts
obsidian backlinks path="Knowledge/Topic.md" format=json
obsidian backlinks path="Knowledge/Topic.md" total
```

Useful flags:

- `counts` to include link counts
- `total` to return only the count
- `format=json|tsv|csv` when structured output is helpful

Use this when you want to know what references a note.

## Related link-inspection commands

### Unresolved links

Use `unresolved` to inspect broken or unresolved links in the vault:

```bash
obsidian unresolved
obsidian unresolved counts
obsidian unresolved verbose
obsidian unresolved format=json
```

### Orphans

Use `orphans` to find notes with no incoming links:

```bash
obsidian orphans
obsidian orphans total
```

### Dead ends

Use `deadends` to find notes with no outgoing links:

```bash
obsidian deadends
obsidian deadends total
```

## File targeting rules

The CLI supports two main ways to target notes:

- `file=<name>` resolves by note name, like a wikilink
- `path=<path>` uses the exact vault path

Prefer:

- `path=...` when exact targeting matters
- `file=...` when the note name is unambiguous and wikilink-like resolution is desired

Quote values with spaces:

```bash
obsidian backlinks file="My Note"
```

## Useful supporting commands

These are secondary but sometimes helpful:

### Read a note

```bash
obsidian read file="My Note"
obsidian read path="Knowledge/Topic.md"
```

### List files

```bash
obsidian files
obsidian files folder="Knowledge"
obsidian files ext=md
```

### Search text

```bash
obsidian search query="TikZJax" format=json
obsidian search:context query="diamond" format=json
```

### Show outline

```bash
obsidian outline path="Knowledge/Topic.md" format=json
```

## Vault targeting

If needed, explicitly target a vault:

```bash
obsidian vault="My Vault" backlinks path="Knowledge/Topic.md"
```

Some Obsidian vaults are Quartz-style vaults with a `content/` directory.
In those vaults, run Obsidian commands from inside `content/` so that note paths resolve relative to that directory.

That means when a note lives at `content/Knowledge/Topic.md`, prefer:

```bash
cd ./content && obsidian read path="Knowledge/Topic.md"
```

and similarly for other subcommands such as `links`, `backlinks`, `search`, or `outline`.
Do not include the `content/` prefix in the Obsidian CLI path in that case.

## Practical rules

- Never run bare `obsidian`.
- Prefer concrete subcommands.
- For TikZ/TikZJax debugging, run `obsidian dev:debug on` before making edits.
- After editing, inspect `obsidian dev:console`.
- Prefer `path=...` when precision matters.
- Use `format=json` when structured output is useful.
- Use link/backlink/unresolved commands before resorting to broader search.

## Pitfalls

- Bare `obsidian` is interactive and should not be used.
- If `dev:debug on` was not enabled before an edit, the relevant console output may be missing.
- `file=...` resolution can be ambiguous if multiple notes share similar names.
- Many commands default to the active file if no file or path is given, which may be unsafe if you need precise targeting.
