---
name: github
description: Use the GitHub CLI (`gh`) to inspect repositories, issues, pull requests, workflows, releases, and related metadata from GitHub. Use when GitHub information or actions are needed and `gh` is available.
compatibility: Requires the GitHub CLI (`gh`). Some commands require authentication via `gh auth login` and appropriate repository permissions.
---

# GitHub Skill

Use this skill when working with GitHub through the `gh` CLI.

Typical use cases:

- inspect repositories
- view issues and pull requests
- read PR discussions and reviews
- inspect workflow runs and jobs
- list releases, tags, and branches
- query GitHub metadata with `gh api`
- create or update issues/PRs when explicitly asked

This skill is about using **`gh` as the default interface to GitHub**.
Prefer `gh` over ad-hoc HTTP calls when the CLI already supports the task well.

## Core rule

Prefer `gh` commands that return structured, minimal output.

When possible:

- use `--json` for machine-readable output
- use `--jq` to reduce noise
- scope commands to the relevant repo with `--repo OWNER/REPO`
- avoid dumping huge responses when a narrower query will do
- prefer read-only inspection unless the user explicitly asks to modify GitHub state

## What to use `gh` for

Good fits for this skill:

- `gh repo view`
- `gh repo list`
- `gh issue list`
- `gh issue view`
- `gh pr list`
- `gh pr view`
- `gh pr diff`
- `gh pr checks`
- `gh run list`
- `gh run view`
- `gh release list`
- `gh release view`
- `gh search code`
- `gh search issues`
- `gh api`

## Preferred command style

Prefer commands like:

```bash
gh pr view 123 --repo OWNER/REPO --json title,body,author,state
```

```bash
gh issue list --repo OWNER/REPO --state open --json number,title,author
```

```bash
gh run list --repo OWNER/REPO --limit 10 --json databaseId,workflowName,status,conclusion,headBranch
```

Use `gh api` when higher-level `gh` subcommands are insufficient.

Example:

```bash
gh api repos/OWNER/REPO/pulls/123/comments
```

## Read-only by default

Unless the user explicitly asks to create, edit, merge, close, label, comment, rerun, or delete something, prefer read-only commands.

Default to inspection rather than mutation.

## Mutating actions

Only perform mutating GitHub actions when the user clearly asks.
Examples:

- creating issues or PRs
- editing titles/bodies
- adding comments
- changing labels or assignees
- merging or closing PRs
- rerunning workflows
- creating releases

Before a destructive or high-impact action, be explicit about what will happen.

## Repository scoping

When the current local checkout is not clearly tied to the target repo, prefer explicit scoping:

```bash
gh ... --repo OWNER/REPO
```

Do not assume the current repo unless it is obvious from context.

## Authentication and permissions

Some commands require authentication.
If `gh` is unauthenticated or lacks permission:

- say so clearly
- mention that `gh auth login` may be required
- do not pretend a private-resource lookup succeeded

## Output rules

Prefer concise, relevant output.

- Use `--json` when available.
- Use `--jq` to narrow fields.
- Avoid huge blobs of markdown or diffs unless the user wants them.
- Summarize the result after running the command.
- If a large response is necessary, extract the important fields first.

## When to use `gh api`

Use `gh api` when:

- the normal `gh` subcommand does not expose the needed data
- GraphQL or REST gives a cleaner answer
- you need an endpoint-specific field not surfaced elsewhere

Prefer targeted endpoints and minimal payloads.

## Practical rules

- Prefer `gh` over manual GitHub API requests.
- Prefer structured output over human-formatted CLI output.
- Prefer repo-scoped commands.
- Prefer read-only inspection first.
- Avoid state-changing commands unless explicitly requested.
- If the user asks for GitHub data across many repos, query narrowly and incrementally.

## Pitfalls

- `gh` behavior may depend on the current checked-out repo if `--repo` is omitted.
- Some subcommands produce human-oriented output unless `--json` is requested.
- Private repos, workflow data, and write operations may require authentication and permissions.
- `gh api` can return very large payloads if not filtered.
