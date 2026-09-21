---
name: to-pdf
description: Convert a markdown document to a polished PDF using Typst. Use when the user asks to generate a PDF, export to PDF, make a document printable, or wants a clean PDF version of a markdown file.
---

# Markdown to PDF

Convert markdown documents to polished, well-designed PDFs using Typst.

Word processors are not in this loop. The source of truth is a markdown file in the knowledge base; the PDF is a build artifact you can regenerate at any time.

## Toolchain

| Tool | Purpose | Install |
|------|---------|---------|
| typst | PDF compilation | `brew install typst` |
| mmdc | Mermaid diagram rendering | `npm install -g @mermaid-js/mermaid-cli` |

Only install `mmdc` if the document actually contains mermaid blocks.

## Workflow

### Step 1: Render mermaid diagrams (if any)

Extract each `mermaid` code block from the source markdown into a `.mmd` file in a `diagrams/` folder next to the output `.typ` file.

#### Mermaid theme

Every `.mmd` file must start with an init directive so all diagrams in a document look like they belong together. Set `primaryColor` and `primaryBorderColor` to your accent colour:

```
%%{init: {'theme': 'base', 'themeVariables': {'primaryColor': '#1a56db', 'primaryBorderColor': '#1a56db', 'primaryTextColor': '#fff', 'lineColor': '#64748b', 'secondaryColor': '#f1f5f9', 'tertiaryColor': '#e2e8f0', 'tertiaryTextColor': '#1e293b', 'edgeLabelBackground': '#ffffff', 'fontSize': '14px'}}}%%
```

Key rules for node text:
- Use `<br>` for line breaks inside nodes (never `\n` — Mermaid renders it literally).
- Avoid parentheses inside node labels — Mermaid interprets them as shape syntax and the parse fails.
- Wrap node labels in `["..."]` for consistent rectangular shapes.

#### Rendering to vector PDF

Generate single-page vector PDFs, not PNGs or SVGs. SVGs use `foreignObject` for text, which Typst cannot render; PNGs are raster and scale poorly.

```bash
mmdc -i diagrams/my-diagram.mmd -o diagrams/my-diagram.pdf -b white -f
```

Flags:
- `-b white` — white background (transparent backgrounds cause issues in PDF viewers).
- `-f` (`--pdfFit`) — scale the diagram to fit on a single PDF page. Without this flag, `mmdc` often produces multi-page PDFs where Typst only displays the first page, which may be partial or blank.

Batch-render all diagrams:

```bash
for f in diagrams/*.mmd; do
  mmdc -i "$f" -o "${f%.mmd}.pdf" -b white -f
done
```

#### Splitting large diagrams

If a single diagram has more than ~8–10 nodes and flows vertically, it will produce a very tall, narrow PDF. Even with `page-fig`, readability suffers. Split it into stage-specific diagrams and render each separately.

### Step 2: Write the Typst document

Copy `template.typ` from this skill's folder next to the output `.typ` file. If you are using a custom logo or bundled fonts, put `assets/` and `fonts/` at the same level, flat.

Minimal document structure:

```typst
#import "template.typ": *

#show: doc => setup(
  title: "Document Title",
  subtitle: "Context or team",
  date: "Feb 18, 2026",
  doc,
)

== First section

Content here.
```

### Making the template yours — once, not per document

The first time this skill runs in a knowledge base, ask the user four questions and bake the answers into `template.typ`:

1. **Name or organisation** for the cover and footer.
2. **One accent colour** (hex). Set `accent-color` at the top of the template.
3. **A logo file**, if they have one. SVG preferred. Put it in `assets/` and pass `logo: "assets/logo.svg"` to `setup()`.
4. **A font.** Any font installed on the machine works — set `body-font` and `display-font` at the top of the template. If they hand you `.ttf` files, drop them in `fonts/` and compile with `--font-path fonts`.

After that, every document reuses the same template and nobody answers those questions again. If a later document genuinely needs a different identity, copy the template and say so explicitly rather than silently mutating the shared one.

### Branding — on by default

Every document gets a full-bleed cover band on page 1: optional logo top-left, then the title and the subtitle/date line centred, all inside the band. Interior pages get a plain running header (title left, date right) and a page counter in the footer. Typography is sentence case with no bold headings — size and colour carry the hierarchy, not weight. The default `band` tone is `"neutral"` (light paper gray).

Tune it via `setup()` params — all optional:

```typst
#show: doc => setup(
  title: "Document Title",
  subtitle: "Context or team",
  date: "Feb 18, 2026",
  band: "neutral",         // "neutral" | "accent" | "ink" (dark reversed)
  logo: "assets/logo.svg",
  footer-logo: "assets/mark.svg",
  doc,
)
```

If you change the band height, move the trailing `v(...)` in `cover-band` by the same amount — it is what pushes body content clear of the band.

### Step 3: Translate markdown to Typst

Mapping reference:

| Markdown | Typst |
|----------|-------|
| `# H1` | `= H1` |
| `## H2` | `== H2` |
| `**bold**` | `*bold*` |
| `*italic*` | `_italic_` |
| `[text](url)` | `#link("url")[text]` |
| `![alt](img.png)` | `#page-fig("img.png", [alt])` |
| `\|table\|` | `#table(columns: (...), [...], [...])` |
| `` `code` `` | `` `code` `` |
| `- item` | `- item` |
| `1. item` | `+ item` |
| page break | `#pagebreak()` |

Available helpers from the template:

```typst
// Page-constrained figure (diagrams and images)
// As wide as possible, never taller than remaining page height.
// Use for ALL diagram/image inclusions.
#page-fig("diagrams/flow.pdf", [Caption text here])

// Highlighted callout box (blue, green, amber, red)
#callout(accent: green)[*Key point.* Supporting text.]

// Inline status badge
#badge("DONE", green)
#badge("PENDING", amber)
#badge("BLOCKED", red)

// Separator page between major sections
#divider-page("Technical Appendix", subtitle: "Detailed implementation notes follow.")
```

`page-fig` measures the image at full available width and compares its natural height to the remaining page height. If it fits, it renders at full width. If it would overflow, it constrains by height instead. This handles both wide/short and tall/narrow diagrams automatically — no manual sizing needed.

### Step 4: Compile

```bash
typst compile output.typ output.pdf
```

If you bundled `.ttf` files in `fonts/`, pass `--font-path` so Typst finds them instead of falling back to a system font:

```bash
typst compile --font-path fonts output.typ output.pdf
```

Place the `.typ` and `.pdf` next to the source markdown file, with `assets/` and `fonts/` alongside them if used.

### Step 5: Look at it

Compiling without errors is not the same as looking right. Render the pages to images and actually inspect them before telling the user it is done:

```bash
typst compile --format png --ppi 120 output.typ "preview-{p}.png"
```

Check for: diagrams pushed onto a page of their own with a blank page behind them, tables running past the margin, a heading orphaned at the bottom of a page, and a cover band that crops the title. Fix, recompile, look again.

## Style guidelines

- Keep it light: no formal cover pages or tables of contents unless explicitly asked.
- The title lives in the cover band on page 1, followed immediately by content.
- Use callout boxes sparingly, for key takeaways, not for every paragraph.
- Use badges for status indicators in tables.
- Use `#divider-page(...)` to separate major document parts, for example an executive summary from a technical appendix.
- One accent colour per document. If everything is highlighted, nothing is.
