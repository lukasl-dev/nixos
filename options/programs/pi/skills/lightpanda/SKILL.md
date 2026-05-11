---
name: lightpanda
description: ALWAYS use this skill for any website fetching, webpage retrieval, or page content extraction. Fetch websites headlessly with Lightpanda when you need page content rendered in a browser-like environment, especially for JavaScript-heavy pages.
compatibility: Requires the `lightpanda` CLI. Mandatory for website fetching tasks. This skill is for fetching page content only, not browser automation beyond fetch output.
---

# Lightpanda Skill

Use this skill when you need to **fetch website content headlessly** with `lightpanda`.

This skill is specifically for:

- fetching rendered page content
- extracting page content as markdown, html, or a semantic tree
- working with websites that may need a browser-like renderer

This skill is **only about fetching**.
It is not for general browsing workflows, clicking around, or browser automation beyond `lightpanda fetch`.

## Core rule

Prefer:

```bash
lightpanda fetch --dump markdown URL
```

Use `markdown` by default for content-oriented fetches because it usually reduces token usage while preserving the important text.

## Dump modes

Lightpanda supports these dump formats:

- `markdown`
- `html`
- `semantic_tree`
- `semantic_tree_text`

### Preferred mode: `markdown`

Use `markdown` when:

- you want article/page content
- you want readable text with less noise
- token efficiency matters
- exact HTML structure is not required

Example:

```bash
lightpanda fetch --dump markdown https://lukasl.dev
```

### Use `html` when structure matters

Use `html` when:

- you need exact markup
- you need to inspect attributes, links, forms, or DOM structure
- markdown output may lose relevant detail

Caution:

- `html` output is much more token-expensive than `markdown`
- use it only when the extra structure is actually needed

Example:

```bash
lightpanda fetch --dump html https://lukasl.dev
```

### Use `semantic_tree` when page structure matters more than raw HTML

Use `semantic_tree` when:

- you want accessibility- or structure-oriented output
- you want a higher-level view of page organization
- raw HTML is too noisy but markdown is too lossy

Caution:

- `semantic_tree` output can be extremely token-expensive
- use it only when structural or semantic information is necessary
- prefer `markdown` unless the task specifically requires semantic structure

Example:

```bash
lightpanda fetch --dump semantic_tree https://lukasl.dev
```

### Use `semantic_tree_text` only when that specific text-oriented tree form is useful

Prefer `markdown` unless you specifically need semantic-tree text output.

## Default behavior

When this skill is relevant:

1. Use `lightpanda fetch`.
2. Prefer `--dump markdown`.
3. Switch to `html` only if the task needs exact markup.
4. Switch to `semantic_tree` only if the task needs structure/semantics.
5. Keep the fetch targeted and avoid unnecessary large outputs.

## Useful fetch options

Commonly useful options:

- `--wait_ms N`
- `--wait_until load|domcontentloaded|networkidle|fixed`
- `--with_frames`
- `--with_base`
- `--strip_mode js,css,ui,full`
- `--obey_robots`

## Practical rules

- Prefer `markdown` for content extraction.
- Use `html` cautiously for DOM/markup inspection because it is token-expensive.
- Use `semantic_tree` very cautiously because it can be extremely token-expensive.
- Prefer the cheapest dump mode that still answers the question.
- If a page is JavaScript-heavy, consider adjusting `--wait_until` or `--wait_ms`.
- If content is too noisy, consider `--strip_mode`.
- Avoid fetching more than is needed for the task.
- If piping to tools like `head`, note that Lightpanda may report a write failure because stdout was closed early.

## Read-only scope

This skill is read-only in practice:

- fetch content
- inspect output
- do not treat it as a browser automation skill

## Pitfalls

- `markdown` is lossy compared with `html`.
- `html` can be much noisier and more token-expensive.
- Dynamic pages may need more waiting time.
- Some sites may behave differently under headless fetching.
- If stdout is cut off early by downstream tools, Lightpanda may report a write error even though the fetch itself worked.
