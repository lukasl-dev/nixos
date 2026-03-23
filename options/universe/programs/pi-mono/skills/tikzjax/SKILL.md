---
name: tikzjax
description: Write TikZJax-compatible TikZ snippets for browser-based environments such as Obsidian and websites. Use when you need the agent to produce TikZ that is likely to render under TikZJax.
compatibility: Targets TikZJax-style browser rendering, especially Obsidian and websites. Focus on writing compatible TikZ, not full LaTeX documents.
---

# TikZJax Skill

Use this skill when you want the agent to **write TikZJax-compatible TikZ** for environments like:

- Obsidian notes
- static websites
- markdown renderers with TikZJax
- browser-based documentation

This skill is about **producing compatible TikZ output**.
It is **not** for explaining diagrams in general, analyzing existing figures, or discussing broad TikZ theory unless that is necessary to write the snippet.

If you are editing TikZ inside an Obsidian vault, also load the `obsidian` skill so you can use the Obsidian CLI workflow for post-edit validation and console debugging.

## Core rule

Write **small, self-contained figures** that are likely to render reliably in TikZJax.

Assume a constrained environment:

- keep diagrams simple
- avoid obscure libraries and advanced extensions
- avoid TeX features that depend on external tools, files, or complex preambles
- optimize for reliable rendering over fancy features

## Output format

For Obsidian and similar TikZJax setups, prefer a complete fenced `tikz` block that includes `\begin{document}` and `\end{document}` around the figure.

Default form:

````markdown
```tikz
\begin{document}
\begin{tikzpicture}
  ...
\end{tikzpicture}
\end{document}
```
````

Use this default unless the user explicitly asks for only the inner `tikzpicture`.

## What to write

Write TikZ using simple, compatible constructs such as:

- `\begin{tikzpicture} ... \end{tikzpicture}`
- `\draw`, `\path`, `\fill`, `\node`, `\coordinate`
- basic shapes such as `circle`, `rectangle`, and rounded rectangles
- simple arrows like `->`, `<-`, `<->`
- `scope`
- `child` for simple tree-like diagrams
- named nodes when later arrows or annotations need to refer back to earlier elements
- `xshift` and `yshift` for simple multi-panel layouts
- direct labels via `node[...] { ... }`
- simple fills and strokes

Important compatibility rule:

- some shapes or conveniences that look "basic" in full TikZ are actually provided by optional libraries
- do not assume a shape is safe just because it is common in normal LaTeX usage
- if a shape may depend on a library, prefer drawing it manually with paths
- for example, prefer a manually drawn diamond over relying on a `diamond` node shape

To improve compatibility, prefer:

- explicit coordinates over complex layout logic
- one diagram per snippet
- short labels
- limited nesting
- simple geometry
- step-by-step layouts when showing a process or transformation

## What not to write

Do **not** write these unless the user explicitly asks and accepts likely incompatibility:

- obscure libraries
- advanced TikZ extensions
- package-loading code beyond what is truly necessary
- complex scope nesting
- fragile macros
- syntax that depends on a full LaTeX setup
- shell-escape dependent features
- filesystem reads or writes
- externalization workflows
- code execution from LaTeX
- external images or included PDFs
- LuaTeX- or XeTeX-specific behavior
- PSTricks
- Asymptote
- minted
- gnuplot integration
- `\write18` or similar execution features
- multi-file LaTeX projects

## Risky / use only with caution

These may work in some setups but should generally be avoided unless specifically requested:

- `pgfplots`
- `circuitikz`
- `tikz-cd`
- advanced graph drawing libraries
- heavy automata libraries
- complex matrices
- advanced decorations
- pattern-heavy fills
- clipping-heavy art
- custom font packages
- uncommon TikZ libraries
- node shapes that may come from optional shape libraries rather than core TikZ

If the user asks for one of these, warn briefly and provide a simpler fallback when possible.

## Writing rules

- Write the code directly.
- Prefer giving the final TikZ snippet over long explanations.
- Keep comments minimal unless the user asks for explanation.
- If a diagram depends on referring back to a node later, name the node.
- If the figure shows a transformation, label the steps explicitly.
- If compatibility is uncertain, simplify first.
- If a heavy library can be replaced with ordinary TikZ, prefer ordinary TikZ.

## Default response behavior

When this skill is relevant:

1. Produce a TikZJax-friendly fenced `tikz` block.
2. Include `\begin{document}` and `\end{document}` unless the user asks otherwise.
3. Keep dependencies minimal.
4. Avoid unnecessary explanation.
5. If the requested figure is risky, say so briefly and provide a simpler compatible version.

## Fallback strategy

If a requested diagram would likely be incompatible with TikZJax:

- first write a simplified pure-TikZ version
- explain briefly which feature is risky only if needed
- replace specialized packages with manual drawing where practical
- reduce package dependencies
- reduce nesting and layout complexity

## Pitfalls

- A diagram that works in a full local TeX install may still fail in TikZJax.
- Package support is narrower in browser-based rendering setups.
- Large or heavily styled diagrams may render slowly or inconsistently.
- Minimal, explicit TikZ is usually the most portable choice.
