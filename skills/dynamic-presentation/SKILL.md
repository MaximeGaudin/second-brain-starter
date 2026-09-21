---
name: dynamic-presentation
description: Builds an animated presentation as a small React app, one file per slide. Use when I say "make a deck", "build a presentation" or "turn this into slides".
---

# Dynamic presentation

Slides as code. A React app where each slide is one file, animated with GSAP, navigated with the arrow keys. It takes longer than a template and it is the only way I have found to get a deck that does not look like everyone else's.

## The app

Vite plus React plus TypeScript plus GSAP, nothing else.

```
src/
  App.tsx            routes a slide index from the URL hash to a slide
  slides/
    Slide01Hook.tsx
    Slide02Problem.tsx
  components/        anything used by more than one slide
  styles/globals.css design tokens, never hardcode a colour in a slide
public/              images, audio, anything referenced as /file.png
```

Navigation is keyboard only: right arrow and space go forward, left arrow goes back, and the index lives in the hash so any slide can be linked and reloaded.

The canvas is a fixed logical size scaled to fit the window with `Math.min(innerWidth / W, innerHeight / H)`. Everything inside is positioned in absolute pixels against that canvas, so what you see while building is exactly what projects.

## The rules that decide whether it is good

**One idea per slide.** If a slide needs a comma in its title, it is two slides.

**No card grids.** No two-by-two grids of bordered boxes, no rows of feature cards, no stat dashboards, no repeated "numbered circle, title, description" down a column. This is the single clearest sign of a generated deck, it wastes the screen, and it makes every slide look identical. A box is allowed only when the box *is* the thing — an editor window, a terminal, a receipt.

**Every slide gets one visual metaphor.** Before writing any slide, ask what real-world object or spatial relationship the idea looks like, then build that out of typography, drawn SVG, positioned text and connectors on an open canvas.

| Instead of | Do this |
|---|---|
| Four stat cards | Giant numbers at chosen coordinates across the canvas, small labels beneath, counting up |
| A timeline of cards | A drawn rail with station dots and alternating labels, a pulse travelling along it |
| Stacked concept cards | A cross-section that builds from the bottom up, each layer wider than the last |
| A feature grid | A constellation: one anchor, items placed around it, connected by drawn lines |
| Two columns of before and after | One glowing axis down the middle, items hanging off each side |
| Numbered process cards | A pipeline path with nodes and a beam travelling through it |

**Typography for a projected screen.** Body text never below 20px and usually 22 to 24. Labels never below 14. Section headings 26 and up. Hero numbers 80 to 120. When unsure, go bigger — text that looks slightly large on your monitor is correct on a wall.

**No emojis anywhere.** Build icons as small SVG components and animate them. An emoji in a deck reads as a first draft.

**Fill the canvas.** No `maxWidth` on content. Empty space is wasted space unless it is deliberate.

## Animation

One GSAP timeline per slide for the entrance, sequenced like a beat: draw the stage, populate it, land the point. Two and a half to four and a half seconds total. Stagger groups by about 0.1s, overlap segments with negative offsets, and use `power3.out` coming in.

Then leave one to three subtle infinite loops running — a pulse travelling a path, a glow breathing, a cursor blinking — so the slide stays alive while I talk over it. Transform and opacity only.

Set `opacity: 0` on anything that animates in, or it flashes on mount.

Two things that will cost you an hour if nobody warns you. An absolutely positioned SVG overlaid on HTML must not have a `viewBox`, or the drawing recentres itself and everything sits a few dozen pixels off; omit it so user units equal CSS pixels and share the same constants between both. And GSAP overwrites CSS transforms, so never tween position on an element that relies on `transform: translate(-50%, -50%)` for its layout — wrap it and animate the wrapper.

## Before you tell me it is done

Screenshot every slide at the canvas size and look at them. In code, an overlap is invisible.

```python
page = await browser.new_page(viewport={"width": W, "height": H})
await page.goto(f"http://localhost:5173/#{i}"); await page.reload()
await page.wait_for_timeout(4000)
await page.screenshot(path=f"slide-{i:02d}.png")
```

Check each one for text crossing a line it should sit beside, anything clipped by the edge, content hugging the left third, and margins that drift between slides. Fix what you find before showing me.
