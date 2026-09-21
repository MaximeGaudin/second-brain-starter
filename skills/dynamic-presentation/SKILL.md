---
name: dynamic-presentation
description: Build animated HTML presentations using React, TypeScript, Vite, and GSAP. Use when the user asks for an animated presentation, HTML slides, dynamic deck, interactive presentation, or wants to create/edit a React-based slide deck.
---

# Dynamic Presentation

Creates animated, full-screen presentations as modular React + TypeScript apps with GSAP animations and hash-based navigation.

These are not slides in the PowerPoint sense. Each one is a React component with its own animation timeline, which means a slide can do things a slide template cannot: type code out live, sweep a scan beam across a diagram, drop a stamp with an impact shake. That is the whole point of paying the cost of building them this way.

**Structure:** one Vite app holding every deck you ever make. A **portal** lists them; each deck is a folder under `src/decks/` sharing components from `@components/`. Build the app once, add decks forever.

## When to use

- The user asks for an animated presentation, HTML slides, or a dynamic deck
- The user wants to create or edit a React-based slide deck
- The user needs a presentation with GSAP animations and bespoke visuals

For a quick static deck that nobody will present from a stage, plain markdown is faster and you should say so.

---

## Quick start

### App structure

```
presentation-app/
├── src/
│   ├── App.tsx                 # Portal vs lazy-loaded deck; unknown id → 404 UI
│   ├── Portal.tsx              # Deck picker
│   ├── main.tsx
│   ├── hooks/
│   │   ├── useHashRoute.ts     # Parses #/ … (portal vs deck)
│   │   └── useSlideIndex.ts    # Per-deck: #/{deckId}/{slideIndex}
│   ├── components/             # Shared slide UI (import as @components/…)
│   ├── decks/
│   │   ├── registry.ts         # DECK_DEFINITIONS (portal cards) + DECK_COMPONENTS (lazy)
│   │   └── {deck-id}/
│   │       ├── index.tsx       # Deck router: SLIDE_COUNTS + useSlideIndex(TOTAL, deckId)
│   │       ├── chapters/       # One folder per chapter
│   │       └── lib/            # Deck-only modules
│   └── styles/
│       └── globals.css         # Reset + design tokens
├── public/                     # Logos, photos, deck assets (/file.png URLs)
├── package.json
├── vite.config.ts              # Aliases: @components, @hooks
└── tsconfig.json
```

- **Run**: `npm install && npm run dev`
- **Routes**: portal `#/`; deck `#/{deck-id}/{slide-index}`, for example `#/my-deck/0`. Omit the slide index and it is treated as `0`. **Escape** returns to the portal.

If the app does not exist yet, scaffold it with `npm create vite@latest -- --template react-ts`, add `gsap`, then build the files above. Full contents for `globals.css`, `main.tsx`, `index.html`, `vite.config.ts` and `tsconfig.json` are in [examples.md](examples.md) and [reference.md](reference.md).

#### Imports

| Alias | Points to | Use for |
|-------|-----------|---------|
| `@components/…` | `src/components/` | Shared slide UI |
| `@hooks/useSlideIndex` | `src/hooks/useSlideIndex.ts` | Deck router only — chapters never import this |

Chapter and slide files should **always** use these aliases. Do not duplicate a `components/` folder inside a deck unless the widget is genuinely unique to that deck, in which case it belongs in `decks/{id}/lib/`.

#### Creating a new deck

1. **Choose `deck-id`** — kebab-case, a stable URL segment. It must match the string passed to `useSlideIndex(TOTAL, "deck-id")` and the `id` in `registry.ts`.
2. **Scaffold** — copy the smallest existing deck as a starting point, rename the folder to `decks/{deck-id}/`.
3. **`decks/{deck-id}/index.tsx`** — define `SLIDE_COUNTS` (one integer per chapter, counting its cover slide), `TOTAL`, `resolve(global)`, and a default export that calls `useSlideIndex(TOTAL, deckId)` and switches on the chapter.
4. **`decks/registry.ts`** — append to `DECK_DEFINITIONS` (id, title, subtitle, accent, `slideCount`, `chapterCount`) and to `DECK_COMPONENTS` with `lazy(() => import("./{deck-id}"))`.
5. **`chapters/`** — one folder per chapter, each with `index.tsx`, an optional `data.ts`, and the slide files.
6. **`public/`** — add images, reference them as `/filename.png`.
7. **Verify** — `npm run build`, then smoke-test slide 0 and the last slide, and check the portal card opens the deck.

#### Updating an existing deck

- **Content:** edit files under `decks/{deck-id}/chapters/…`.
- **Slide counts changed:** update `SLIDE_COUNTS` and `TOTAL` in the deck's `index.tsx`, then update `slideCount` and `chapterCount` in `registry.ts` so the portal card stays honest. This is the single most commonly forgotten step.
- **New chapter:** add `chapters/{name}/`, extend `SLIDE_COUNTS`, add a `switch` case.
- **New widget used by two or more decks:** promote it to `src/components/`.
- **Widget for one deck only:** keep it in `decks/{deck-id}/lib/`.

#### Portal card copy

Titles, subtitles, and accent colours for the landing grid come **only** from `DECK_DEFINITIONS`. They are not inferred from the deck folder.

---

## Architecture

### Slide index and navigation

A single global index `0…TOTAL-1` maps to chapters through a cumulative offset array. `useSlideIndex(total, deckId)` reads and writes `window.location.hash` so `hashchange` stays in sync with routing. **Escape** jumps back to the portal.

Navigation is **keyboard-first**:
- **Arrow Right / Space**: next slide
- **Arrow Left**: previous slide

Do not rely on click-to-advance. Presenters use a clicker, and a clicker sends arrow keys.

### Chapter routing

```tsx
const SLIDE_COUNTS = [1, 9, 2, 11]; // slides per chapter
const TOTAL = SLIDE_COUNTS.reduce((a, b) => a + b, 0);

function resolve(global: number): { chapter: number; local: number } {
  let offset = 0;
  for (let i = 0; i < SLIDE_COUNTS.length; i++) {
    if (global < offset + SLIDE_COUNTS[i])
      return { chapter: i, local: global - offset };
    offset += SLIDE_COUNTS[i];
  }
  return { chapter: SLIDE_COUNTS.length - 1, local: SLIDE_COUNTS.at(-1)! - 1 };
}
```

Each chapter receives `localSlide`. The chapter's `index.tsx` routes `localSlide === 0` to its cover, then to the content slides.

### Viewport

A fixed logical canvas scaled to fit via `Math.min(innerWidth/W, innerHeight/H)`. All positioning is absolute px inside that frame, which is what makes pixel-precise layout possible at all.

Pick your canvas and commit to it. `SlideLayout` exports `SLIDE_W` and `SLIDE_H`; 1512×739 is a good default because it matches a laptop screen and projects cleanly. Reserve a header band of about 100px if you want a persistent logo.

**Layout budget.** With a canvas of 1512×739 and frame paddings of 24/64/32, the inner area is roughly **1384×583**. A title header eats ~80px plus a 16px gap; a takeaway bar eats ~58px plus 16px → the main scene gets about **1384×410–430**. Compute your diagram coordinates against that band and verify nothing crosses into the takeaway. Guessing here is the single largest source of visual bugs.

---

## Tech stack

| Layer | Choice |
|-------|--------|
| UI | React 19 |
| Build | Vite 6 + `@vitejs/plugin-react` |
| Language | TypeScript 5.8 (strict, `noUnusedLocals`, `noUnusedParameters`) |
| Animation | GSAP 3.12 |
| Styling | Inline styles + CSS custom properties from `globals.css` |
| Navigation | Hash `#/{deckId}/{slide}` |

No CSS framework, no component library, no animation library other than GSAP. Inline styles plus absolute positioning is unusual for an app and correct for a deck: every slide is a one-off drawing, and shared stylesheets fight that.

---

## Design tokens

Define every colour and font once in `globals.css` and **never hardcode them in slide content**. A starter dark palette:

| Token | Value | Usage |
|-------|-------|-------|
| `--color-bg` | `#000000` | Slide background |
| `--color-surface` | `#0C0C0C` | Sunken surfaces |
| `--color-surface-raised` | `#1C1C1E` | Raised elements |
| `--color-border` | `#252525` | Default borders |
| `--color-text-primary` | `#FFFFFF` | Headings, body |
| `--color-text-secondary` | `#A3A3A3` | Supporting copy |
| `--color-text-tertiary` | `#727272` | Labels, counters |
| `--color-brand` | *your brand colour* | Primary accent, default highlight |
| `--color-accent-blue` | `#008CFF` | Section accent |
| `--color-accent-pink` | `#FF5FB0` | Section accent |
| `--color-accent-green` | `#4ADE80` | Section accent |
| `--color-accent-orange` | `#FF630F` | Section accent |
| `--color-accent-yellow` | `#F2CB45` | Section accent |
| `--font-sans` | Inter, system-ui | Body text |
| `--font-mono` | JetBrains Mono | Overlines, labels, counters |

Ask the user for their brand colour the first time, write it into `globals.css`, and stop asking.

### Typography scale

These are projected-screen minimums, not suggestions. When in doubt, size up.

| Role | Size | Weight | Extras |
|------|------|--------|--------|
| Display / hero | 80px | 600 | `-0.04em` tracking, line-height 1.1 |
| Chapter title | 72px | 600 | `-0.03em` tracking |
| Section heading | 44–52px | 600 | `-0.02em` tracking |
| Subtitle / heading | 28–32px | 400–500 | |
| Card / body text | 21–26px | 400–500 | line-height 1.35–1.5. **Never below 20px.** |
| Tags / badges | 15–17px | 500 | inside pills or chips |
| Overline / label | 12–14px | 400 | mono, uppercase, `0.16em` tracking |
| Counter | 14px | mono | `0.08em` tracking |
| Icon | 32–48px | — | Custom SVG only — **emojis are banned** |

### Colour usage

- **Backgrounds:** pure black base, `#0C0C0C` surface, `#1C1C1E` raised.
- **One accent per chapter or section**, held across every slide in it. A colour change means a new idea — never a new kind of slide. Changing accent mid-section is the fastest way to confuse a room.
- **Low-opacity accents:** borders at `color + "40"`, backgrounds at `rgba(color, 0.08)`.

---

## Component library

Build these once in `src/components/` and reuse them across every deck. Full props in [reference.md](reference.md).

| Component | Purpose |
|-----------|---------|
| `SlideLayout` | Scaled stage + automatic header; optional partner logo props |
| `SlideHeader` | Logo at ~30% opacity, top-centre; optional second logo |
| `ChapterTitle` | Full-screen chapter opener with GSAP entrance |
| `StepBox` | Numbered step card with title, description, optional badges |
| `StepIcon` | Animated icon circle next to steps |
| `LightBeam` | Gradient line that animates in, vertical or horizontal |
| `WaveConnector` | Wavy SVG connector between steps with a traveling beam |
| `Waveform` | SVG waveform that morphs between configs — one possible motif |

The last two are a motif, not a requirement. Pick one visual signature for the deck — a waveform, a grid, a rail, a circuit — and let it recur. A deck with no recurring motif looks like a folder of unrelated images.

### Cinematic kit

Build these as deck-local modules first, then promote them to `@components/` once a second deck needs them. They are what separates a deck that looks designed from one that looks generated:

| Module | What it gives you |
|---|---|
| `AmbientBackground.tsx` | Deck-wide animated backdrop: two drifting aurora glows tinted by the accent, a masked dot grid, rising specks, a vignette. Mount once per chapter wrapper at `zIndex 0`, content above at `zIndex 1`. |
| `SlideTitle.tsx` | Cinematic header: accent tick draws in, mono overline, title reveals word by word from an overflow mask (`yPercent: 115 → 0` with a slight rotation), radial glow. Props: `overline`, `title`, `accent`, `accentWords`, `align`. It self-animates — start the slide's own timeline at `delay: 0.55`. |
| `TakeawayBar.tsx` | Box-free closing statement: a rule draws in, the body fades up, a pulsing diamond anchors it. Tune `delay` so it lands after the main scene. |
| `ChapterCover.tsx` | Full-screen chapter opener: giant outlined mono numeral (`WebkitTextStroke`), masked word reveal, baseline with a looping traveling spark. |
| `ProgressRail.tsx` | 4px fixed gradient progress bar at the viewport bottom with chapter ticks and a glowing head. |
| `anim.ts` | `typeTween(el, text, dur)` (typewriter via `textContent` slicing), `countTween(el, to, {prefix, decimals})` (number count-up), `shakeTween(el, intensity)` (impact shake). All return tweens you can `tl.add()`. |

---

## Animation conventions

### Entrance (on mount)

```tsx
useEffect(() => {
  const tl = gsap.timeline({ defaults: { ease: "power3.out" } });
  tl.fromTo(el1, { opacity: 0, y: 24 }, { opacity: 1, y: 0, duration: 0.8 })
    .fromTo(el2, { opacity: 0, y: 16 }, { opacity: 0.5, y: 0, duration: 0.7 }, "-=0.3");
}, []);
```

### Morphing (config-driven)

```tsx
useEffect(() => {
  gsap.to(proxy, {
    ...newConfig,
    duration: 1.2,
    ease: "power2.inOut",
    onUpdate: render,
  });
}, [config]);
```

### Enter/exit (visibility toggle)

```tsx
useEffect(() => {
  if (visible) {
    gsap.set(container, { visibility: "visible" });
    gsap.fromTo(els, { y: 40, opacity: 0 },
      { y: 0, opacity: 1, duration: 0.8, ease: "power3.out", stagger: 0.1 });
  } else {
    gsap.to(els, { y: -30, opacity: 0, duration: 0.5, ease: "power2.in", stagger: 0.04,
      onComplete: () => gsap.set(container, { visibility: "hidden" }) });
  }
}, [visible]);
```

### Traveling beam (infinite loop along an SVG path)

```tsx
const proxy = { t: 0 };
gsap.to(proxy, {
  t: 1, duration: 1.4, repeat: -1, ease: "none",
  onUpdate() {
    const pt = path.getPointAtLength(proxy.t * pathLength);
    beam.setAttribute("cx", String(pt.x));
    beam.setAttribute("cy", String(pt.y));
  },
});
```

### Animation monitor and PDF export sync

If you ever want to export the deck to PDF or capture screenshots, `main.tsx` should ship an animation monitor that dispatches a `slide-animations-done` event once all finite entrance animations settle. Any exporter then waits for that event before capturing.

How it works:
1. On every `hashchange`, the monitor resets `window.__slideAnimationsDone = false` and starts polling GSAP's global timeline.
2. It waits a 600ms grace period for React to mount and GSAP to start delayed tweens.
3. It checks all tweens, skipping any that is infinite (`totalDuration() === Infinity`, `repeat() === -1`) or nested inside an infinite parent timeline.
4. Once no finite tween is active, it sets `window.__slideAnimationsDone = true` and dispatches the event.
5. Safety net: after 10 seconds the event fires regardless.

Slides with infinite loops — typing demos, pulsing icons, traveling beams — work automatically, because the monitor walks up each tween's `.parent` chain and treats children of a `repeat: -1` timeline as infinite.

**Manual signal** — for a slide with a complex lifecycle where detection is not sufficient, call the explicit signal from the entrance timeline's `onComplete`:

```tsx
useEffect(() => {
  const tl = gsap.timeline({
    defaults: { ease: "power3.out" },
    onComplete: () => (window as any).__signalAnimationsDone?.(),
  });
  tl.fromTo(el1, { opacity: 0, y: 24 }, { opacity: 1, y: 0, duration: 0.8 });
  // infinite loops created separately are fine
}, []);
```

### Rules

- Use `gsap.timeline()` for sequenced entrances; overlap with `"-=0.3"` offsets.
- Stagger multi-element reveals with `stagger: 0.1`.
- Standard durations: entrance 0.6–1.2s, exit 0.4–0.6s, morph 1.0–1.4s.
- Standard eases: `power3.out` (entrance), `power2.in` (exit), `power2.inOut` (morph).
- **EMOJIS ARE BANNED.** Never use text emojis anywhere in slide content — they break the premium feel instantly. Always build custom SVG icons as React components.
- All animated SVGs need `pointerEvents: "none"` and absolute positioning.
- Set initial `opacity: 0` on anything that animates in, to prevent a flash on mount.

### Custom SVG animated icons

Whenever an icon or illustration is needed, build it as a custom SVG React component animated with GSAP:

```tsx
function HourglassIcon() {
  const ref = useRef<SVGSVGElement>(null);
  useEffect(() => {
    if (!ref.current) return;
    const ctx = gsap.context(() => {
      gsap.to(".hg-group", {
        rotation: 180, duration: 1, ease: "back.inOut(1.5)",
        repeat: -1, repeatDelay: 3, transformOrigin: "center",
      });
      gsap.fromTo(".hg-top-sand",
        { scaleY: 1 },
        { scaleY: 0, duration: 3, ease: "none", repeat: -1, repeatDelay: 1, transformOrigin: "bottom" });
      gsap.fromTo(".hg-bottom-sand",
        { scaleY: 0 },
        { scaleY: 1, duration: 3, ease: "none", repeat: -1, repeatDelay: 1, transformOrigin: "bottom" });
    }, ref);
    return () => ctx.revert();
  }, []);

  return (
    <svg ref={ref} width="40" height="40" viewBox="0 0 100 100" fill="none">
      <g className="hg-group" style={{ transformOrigin: "50px 50px" }}>
        <path d="M25 15 L75 15 L75 25 L55 50 L75 75 L75 85 L25 85 L25 75 L45 50 L25 25 Z"
          stroke="var(--color-brand)" strokeWidth="6" strokeLinejoin="round" />
        <path className="hg-top-sand" d="M35 25 L65 25 L50 45 Z" fill="var(--color-brand)"
          opacity="0.6" style={{ transformOrigin: "50px 45px" }} />
        <path className="hg-bottom-sand" d="M50 55 L65 75 L35 75 Z" fill="var(--color-brand)"
          opacity="0.6" style={{ transformOrigin: "50px 75px" }} />
        <line className="hg-stream" x1="50" y1="45" x2="50" y2="75" stroke="var(--color-brand)"
          strokeWidth="2" opacity="0.6" strokeDasharray="2 2" />
      </g>
    </svg>
  );
}
```

---

## File organization

### One file per slide

Each slide is a self-contained `.tsx` file: `Slide01{Name}.tsx`, `Slide02{Name}.tsx`. A slide is a drawing, and drawings do not share files.

### Chapter structure

```
chapters/{chapter-name}/
├── index.tsx          # Routes localSlide → cover or content slides
├── data.ts            # Typed content arrays
├── Slide01{Name}.tsx
├── Slide02{Name}.tsx
└── DetailSlide.tsx    # Optional reusable layout for this chapter
```

### Chapter `index.tsx` pattern

```tsx
export default function MyChapter({ localSlide }: Props) {
  if (localSlide === 0) {
    return <ChapterTitle title="My Chapter" subtitle="..." />;
  }
  return (
    <SlideLayout>
      <div style={{ position: "absolute", inset: 0 }}>
        {contentSlides[localSlide - 1]}
      </div>
    </SlideLayout>
  );
}
```

### Slide conventions

- Every slide is wrapped in `SlideLayout`.
- No click handlers — navigation is keyboard-only.
- Every chapter starts with a cover slide.
- Optional slide counter: bottom-right, mono, `01 / 08` format.

### Space usage — critical

These slides are projected and must be readable from the back of the room. **Readability is the number one layout priority.**

**Fill the canvas:**
- NEVER constrain content with `maxWidth`. Spread across the full width.
- Padding tight enough to maximise content area: 48–64px sides, 48–56px top and bottom.
- Empty space is wasted space.

**Text sizing — go big:**
- Body text ≥ 21px, prefer 22–24px. Never below 20px.
- Labels and tags ≥ 15px. Never below 14px.
- Section headings ≥ 24px, prefer 26–28px.
- Slide headings ≥ 30px.
- SVG icons next to text ≥ 32px.
- When in doubt, go bigger. Text that feels slightly large on your monitor is correct on a projector.

**Centring:**
- Vertically centre content in the available space. Never let content stick to the top with a void below it.

---

## Slide design language — every slide gets a unique visual

### The cardinal rule: no card grids

**Card grids, bordered boxes, 2×2 grids, stat dashboards, and any layout that is "N bordered rectangles in a grid" are BANNED.** They are the number one tell of a generated deck. They make every slide look identical, waste the canvas, and are boring to present.

This means:
- **NO** `gridTemplateColumns: "1fr 1fr"` with bordered `div`s inside
- **NO** "4 stat cards" or "3 feature cards" or "2×2 grid of capabilities"
- **NO** rows of boxes with `border` + `borderRadius` + background + text inside
- **NO** "numbered circle + title + description" repeated N times down a column — that is a vertical card grid wearing a hat
- A box is acceptable only when the box IS the metaphor: an editor window, a terminal, a receipt, a badge

### What to do instead

Every content slide gets **one bespoke visual metaphor** that embodies its idea, built from typography, drawn SVG, positioned text, connectors, and animation on the open canvas — not from boxes containing text.

**Before writing a slide, ask: what real-world object or spatial relationship does this idea look like?** Then build that.

### Alternatives for the slide types that tempt you toward cards

| You want to show… | DON'T | DO instead |
|---|---|---|
| 3–5 key stats | 2×2 card grid with big numbers | **Typographic wall**: giant numbers (80–120px) at specific x/y coordinates across the canvas, small labels below, staggered entrance, count-up animation. Let the numbers be the slide. |
| A timeline or history | Horizontal cards or a vertical list | **Metro map / rail**: horizontal SVG line, station dots at fixed x positions, labels alternating above and below, a traveling pulse |
| Layered concepts | Stacked cards | **Geological cross-section**: layers draw in from the bottom, each wider than the last, connected by glowing risers, bracket label on the side |
| A feature list | Card grid with icons | **Constellation / orbital**: a central anchor with items positioned radially, connected by drawn arcs, items animating in along their connection lines |
| Before and after | Two columns of cards | **Split-screen**: a glowing central divider, items on each side at specific y coordinates, connected to the axis by accent dashes |
| Geographic presence | Cards per region | **Dot map**: simplified SVG map or positioned dots with pulse animations, scale-in labels, connection lines between clusters |
| A process or pipeline | Numbered step cards | **Horizontal pipeline**: SVG path connecting nodes at fixed x positions, traveling beam, labels alternating above and below |
| Company or profile info | Info card with bullets | **Dossier**: left-aligned key-value pairs with mono labels like a case file, one hero visual on the right |

### Metaphor patterns worth stealing

| Idea to convey | Metaphor |
|---|---|
| Two trajectories from one starting point | **Metro map**: two horizontal lines, stations and labels at fixed x positions, a traveling pulse |
| Division of labour | **Central axis**: a glowing vertical line, items hanging left and right with accent dashes |
| Code shipped blind | **Live editor**: code types itself with `typeTween`, a stamp slams in with a shake, floating annotations wired to specific lines by drawn bezier connectors |
| Dangerous automation | **Live terminal**: commands type in, BLOCKED/ALLOWED verdicts pop per line, a blinking cursor |
| Hidden problems in a file | **X-ray scan**: a beam sweeps the code block, bad lines flash as it passes, side annotations connected by lines |
| Wasted money | **Printed receipt**: a mono-font till receipt slides out of a slot, prices pop, barcode footer |
| Safety net present or absent | **Physics scene**: a ball drops and bounces on the intact net via an elastic path morph, or falls through the torn one, looping |
| Where to look in a huge diff | **Diff minimap**: a thin segment column, hot segments glow and connect to checklist items |
| Active control vs passivity | **Cockpit gauge**: an animated attitude indicator between two floating lists |
| A structural change | **Construction scene**: the floor draws, pillars rise, a beam drops with bounce and shake |
| A chain of responsibility | **Horizontal node chain**: full-width line, icon nodes, traveling pulse, a badge slamming onto the broken link, then a huge typographic punch below |
| A recap people will photograph | **Typographic poster**: outlined mono numerals, centre divider, corner brackets, a camera-flash overlay and a "screenshot this" hint |

### Composition rules

- **Geometry as named constants.** Put every x and y in a const block at the top of the file (`STATIONS_X`, `LINE_Y`, `WIN_X`), in px of the main area. Never measure SVG paths at runtime to place labels — design fixed lanes so collisions are impossible by construction.
- **Spacing and alignment is the number one review criterion.** Centre groups on shared axes, keep label bands at least 20px clear of the lines they describe, and screenshot-verify before declaring anything done.
- **Takeaway is typography, not a box.** A hairline rule, a glowing diamond, one sentence with accent spans.
- **When in doubt, go typographic.** A single massive number or word filling half the canvas beats four bordered boxes of small text every time.

### Choreography

- One master `gsap.timeline` per slide for the entrance. Sequence the metaphor like a story: draw the stage, populate it, deliver the verdict, land the takeaway. Total entrance 2.5–4.5s.
- End with one to three **subtle infinite loops** — a traveling pulse, a breathing glow, a blinking cursor, a re-sweeping scan — so the slide stays alive while you talk. Transform and opacity only.
- Impact moments (a stamp, a badge, a blocked command): `scale: ~2.5 → 1` with `power4.in` plus a `shakeTween` on the parent. Once or twice per slide at most.

### Hard-won gotchas

Every one of these cost hours to find. Read them before you debug.

- **SVG + HTML overlays: never use `viewBox`** when an absolutely positioned SVG must align with HTML elements. With `viewBox`, `preserveAspectRatio` recentres the drawing inside the taller or wider container and everything shifts — about 44px in practice. Omit `viewBox` so user units equal CSS px, and share the same constants between paths and HTML.
- **GSAP clobbers CSS transforms.** Never tween `x`, `y`, `scale` or `rotation` on an element that relies on CSS `transform` for layout, such as `translate(-50%, -100%)` centring or a `scale(-1, 1)` mirror flip. Either wrap it in a positioned parent and animate an inner element, or animate `opacity` only. This is what puts labels on top of the lines they belong to, and drifts a centred logo off-centre the moment a scale tween runs.
- **SVG rotate and scale pivots: use `svgOrigin`, not `transformOrigin: "Xpx Ypx"`.** On an SVG child, GSAP measures a px `transformOrigin` against the element's own bounding box, not the SVG user-coordinate canvas, so a group rotating around `"120px 120px"` pivots off-centre. `svgOrigin: "120 120"` pins the pivot to absolute canvas coordinates and just works.
- **`tl.duration()` bookmark.** When scheduling flashes in sync with a moving beam, capture `const start = tl.duration()` and place each flash at `start + fraction * sweepDuration`.
- **Delayed takeaways miss PDF capture.** A tween with `delay > ~2s` can start after the animation monitor has already declared the slide finished. If you plan to export, put the takeaway on the master timeline rather than in a standalone delayed tween.

### Screenshot review loop — do this before declaring a deck done

Visual bugs are invisible in code. Overlaps, clipped text, and dead zones only show up when you look. With the dev server running, capture every slide headlessly and actually inspect them:

```python
# python3 + playwright; viewport must match SLIDE_W × SLIDE_H
page = await browser.new_page(viewport={"width": 1512, "height": 739})
await page.goto(f"http://localhost:5173/#/{deck_id}/{i}"); await page.reload()
await page.wait_for_function("window.__slideAnimationsDone === true", timeout=12000)
await page.wait_for_timeout(1200)  # let delayed takeaways land
await page.screenshot(path=f"slide-{i:02d}.png")
```

Note the `page.reload()` — navigating by hash alone does not remount the React tree, so without it you capture the previous slide's animation state.

Check each shot for: text crossing lines or markers, anything clipped by the canvas edge, content not filling the width, takeaway overlap, and consistent margins across slides.

---

## Workflow

### Creating a new presentation

1. Scaffold or open the app, `npm install`, `npm run dev`.
2. Write the outline first, as chapters and slide titles, and agree it with the user before building a single slide. Rebuilding a bespoke animated slide because the argument changed is expensive.
3. Create the deck folder and register it.
4. Build chapter by chapter, one metaphor per slide.
5. Run the screenshot review loop.
6. `npm run build` to confirm it compiles.

Do not rewrite shared components from scratch per deck. Extend `src/components/` when two decks need the same widget; otherwise keep the code in `decks/{id}/lib/`.

For detailed component APIs and props, see [reference.md](reference.md).
For copy-pasteable slide patterns and full config files, see [examples.md](examples.md).
