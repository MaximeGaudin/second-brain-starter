// ─── Document template ───
// Grayscale by default, sentence case, no bold headings. One accent colour,
// used sparingly. Swap `accent-color` and the two font names below to make it
// yours — everything else is layout and should not need touching.
//
// Fonts: set these to any font installed on your machine, or drop .ttf files in
// a `fonts/` folder next to this file and compile with `--font-path fonts`.

// Listed in order of preference — Typst uses the first one installed, so these
// work on a clean machine and get better the moment you install a real font.
#let body-font = ("Inter", "Helvetica Neue", "Arial")
#let display-font = ("Inter", "Helvetica Neue", "Arial")

// ─── Palette ───
#let ink = rgb("#000000")        // headings, key figures
#let body-ink = rgb("#1C1C1E")   // body copy
#let gray = rgb("#727272")       // secondary / meta
#let gray-light = rgb("#A3A3A3") // tertiary
#let hairline = rgb("#E5E5E5")   // rules, borders
#let surface = rgb("#FAFAFA")    // table header tint, code blocks

#let accent-color = rgb("#1a56db") // your one accent — cover band, nothing else by default
#let amber = rgb("#B45309")
#let green = rgb("#16A34A")
#let red = rgb("#DC2626")
#let blue = rgb("#008CFF")

// ─── Helpers ───

// Highlighted callout box. Use sparingly — key takeaways only, not every paragraph.
#let callout(body, accent: amber) = {
  block(
    width: 100%,
    inset: (left: 14pt, rest: 12pt),
    radius: (right: 4pt),
    stroke: (left: 3pt + accent, rest: 0.5pt + hairline),
    fill: accent.lighten(94%),
  )[#body]
}

// Inline status badge, for status columns in tables.
#let badge(label, color) = {
  box(
    fill: color.lighten(88%),
    inset: (x: 6pt, y: 3pt),
    radius: 2pt,
  )[#text(font: body-font, 8pt, fill: color, tracking: 0.05em)[#upper(label)]]
}

// Page-constrained figure. As wide as possible, never taller than the page.
// Use this for every diagram and image — it handles wide/short and tall/narrow
// automatically, so you never size an image by hand.
#let page-fig(path, cap) = {
  layout(avail => {
    let full-w = image(path, width: avail.width)
    let natural = measure(full-w)
    let cap-reserve = measure(text(size: 9pt)[Figure 0: ] + cap).height + 24pt
    let max-h = avail.height - cap-reserve
    if natural.height > max-h {
      figure(image(path, height: max-h), caption: cap)
    } else {
      figure(full-w, caption: cap)
    }
  })
}

// Separator page between major document parts.
#let divider-page(title, subtitle: none) = {
  pagebreak()
  page(header: none, footer: none)[
    #v(1fr)
    #align(center)[
      #text(13pt, font: display-font, fill: gray)[#title]
      #if subtitle != none {
        v(0.35cm)
        text(9.5pt, fill: gray)[#subtitle]
      }
    ]
    #v(1fr)
  ]
}

// ─── Cover band ───
// Full-bleed strip on page 1: optional logo, then title and subtitle/date line.
// tone: "neutral" (paper gray) | "accent" (tinted) | "ink" (dark reversed)
//
// If you change the band height, move the trailing `v(...)` by the same amount —
// it is what pushes body content clear of the band.
#let cover-band(title, subtitle, date, band: "neutral", logo: none) = {
  let tone = (
    neutral: (fill: rgb("#E9E9E9"), fg: ink, sub: gray),
    accent: (fill: accent-color.lighten(92%), fg: ink, sub: accent-color.darken(20%)),
    ink: (fill: rgb("#0C0C0C"), fg: rgb("#FFFFFF"), sub: rgb("#A3A3A3")),
  ).at(band)

  place(
    top + left,
    dx: -2.6cm, dy: -2.9cm,
    block(width: 21cm, height: 6.2cm, fill: tone.fill)[
      #pad(top: 1.55cm, left: 2.6cm, right: 2.6cm)[
        #if logo != none {
          grid(
            columns: (auto, 1fr),
            align: (left + horizon, left + horizon),
            image(logo, width: 2.9cm),
            [],
          )
        } else {
          v(1.05cm)
        }
        #v(0.28cm)
        #align(center)[
          // Kill paragraph spacing — at 24pt it is ~1.14cm ink-to-ink otherwise.
          #set par(spacing: 0pt)
          #block(below: 0.75cm, text(24pt, font: display-font, fill: tone.fg)[#title])
          #if subtitle != none or date != none {
            block(text(10.5pt, font: body-font, fill: tone.sub)[
              #if subtitle != none { subtitle }
              #if subtitle != none and date != none { h(1em) + sym.dot.c + h(1em) }
              #if date != none { date }
            ])
          }
        ]
      ]
    ],
  )
  v(4.1cm)
}

// ─── Document setup ───
#let setup(
  title: "Document",
  subtitle: none,
  date: none,
  logo: none,          // path to an SVG/PNG for the cover band, e.g. "assets/logo.svg"
  footer-logo: none,   // small mark repeated in the footer of interior pages
  header-left: none,   // defaults to the title
  author: none,
  band: "neutral",
  lang: "en",
  doc,
) = {
  let hl = if header-left != none { header-left } else { title }

  set document(title: title, author: if author != none { author } else { "" })

  set page(
    paper: "a4",
    margin: (top: 2.9cm, bottom: 2.4cm, left: 2.6cm, right: 2.6cm),
    header: context {
      if counter(page).get().first() > 1 {
        set text(8pt, fill: gray, font: body-font, tracking: 0.03em)
        grid(
          columns: (1fr, 1fr),
          align(left)[#upper(hl)],
          align(right)[#if date != none { date }],
        )
      }
    },
    footer: context {
      set text(8pt, fill: gray-light, font: body-font)
      grid(
        columns: (1fr, auto, 1fr),
        align: (left + horizon, center + horizon, right + horizon),
        [],
        if footer-logo != none { image(footer-logo, height: 0.32cm) } else { [] },
        [#counter(page).display("1 / 1", both: true)],
      )
    },
  )

  set text(font: body-font, size: 10pt, fill: body-ink, lang: lang)
  set par(leading: 0.72em, justify: true)

  // Sentence case, no bold. Size and colour carry the hierarchy, not weight.
  set heading(numbering: none)
  show heading.where(level: 1): it => {
    v(0.95em)
    text(15pt, font: display-font, fill: ink)[#it.body]
    v(0.55em)
  }
  show heading.where(level: 2): it => {
    v(0.7em)
    text(11.5pt, font: display-font, fill: ink)[#it.body]
    v(0.3em)
  }
  show heading.where(level: 3): it => {
    v(0.5em)
    text(9.5pt, font: body-font, fill: gray, tracking: 0.02em)[#it.body]
    v(0.2em)
  }
  show heading.where(level: 4): it => {
    v(0.4em)
    text(9pt, font: body-font, fill: gray-light)[#it.body]
    v(0.1em)
  }

  set table(
    stroke: 0.5pt + hairline,
    inset: 8pt,
    fill: (_, row) => if row == 0 { surface } else { none },
  )
  show table.cell.where(y: 0): set text(font: display-font, size: 9pt, fill: ink)
  set table.cell(breakable: false)

  show raw.where(block: false): box.with(
    fill: surface, inset: (x: 3pt, y: 1pt), outset: (y: 2pt), radius: 2pt,
  )
  show raw.where(block: true): block.with(
    fill: surface, inset: 10pt, radius: 4pt, width: 100%,
  )

  show link: set text(fill: ink, weight: "regular")
  show link: underline
  set list(marker: text(fill: gray-light)[–], indent: 0.8em)
  set enum(indent: 0.8em)

  // The cover band replaces any inline title block on page 1.
  cover-band(title, subtitle, date, band: band, logo: logo)

  doc
}
