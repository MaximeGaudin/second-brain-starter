---
name: to-pdf
description: Turns a markdown document into a designed PDF using Typst. Use when I say "make this a PDF", "export this properly" or "send me a clean version".
---

# Markdown to PDF

Word processors are where documents go to look like everyone else's. This renders markdown through Typst instead, so the layout lives in code, the content stays plain text, and the same document can be regenerated the day the numbers change.

## Once, before the first run

Check the toolchain and install what is missing:

- `typst` — the typesetter. `brew install typst`, or see typst.app/docs for other systems.
- `mmdc` — only needed if documents contain diagrams. `npm install -g @mermaid-js/mermaid-cli`

Then look for `templates/document.typ` in this folder. If it is not there, write one and show it to me before you use it. Ask me first for:

- my name and how I want to be credited in the footer
- one accent colour
- whether documents carry a logo, and where the file is
- the font I want, or say you will use a system one

The template defines page geometry, heading styles, a cover, a running header and footer, and three helpers used by every document: a page-constrained figure, a callout box, and an inline badge. Write those helpers once, use them everywhere.

## Every run

**1. Diagrams first.** Extract every `mermaid` block into `diagrams/<name>.mmd` and render each to a vector PDF:

```bash
mmdc -i diagrams/flow.mmd -o diagrams/flow.pdf -b white -f
```

Vector PDF, not PNG and not SVG. PNG scales badly in print; Typst cannot render the text inside a mermaid SVG because it comes out as `foreignObject`. The `-f` flag fits the diagram onto one page — without it you get a multi-page PDF and Typst shows only the first, which is often blank.

If a diagram has more than about ten nodes, split it into several rather than producing one tall narrow strip nobody can read.

**2. Translate the markdown.**

| Markdown | Typst |
|---|---|
| `# H1` | `= H1` |
| `## H2` | `== H2` |
| `**bold**` | `*bold*` |
| `*italic*` | `_italic_` |
| `[text](url)` | `#link("url")[text]` |
| `![alt](img.png)` | the figure helper, never raw `#image` |
| `1. item` | `+ item` |
| table | `#table(columns: (...), [...])` |

**3. Compile**, passing the font path if the template ships its own fonts:

```bash
typst compile --font-path fonts document.typ document.pdf
```

**4. Open it and actually look at it.** A heading stranded at the bottom of a page, a figure broken across two, a table running off the edge — fix those before telling me it is done. Do not hand me a PDF you have not read.

## Rules

- No cover page and no table of contents unless I asked for them. Most documents are three pages and need neither.
- Every image and diagram goes through the figure helper. It is what keeps them inside the page instead of overflowing it.
- Callouts are for the one thing I must not miss, not for every paragraph. If everything is highlighted, nothing is.
- If a claim in the document has no source in my files, mark it TO CHECK in the output rather than quietly dropping it or filling the gap from general knowledge.
- Keep the `.typ` next to the source markdown and commit both. The PDF is a build artifact; the markdown is the document.
