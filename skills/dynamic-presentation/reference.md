# Component and API reference

Full props, patterns, and implementation details for the dynamic presentation system.

---

## Core infrastructure

### `useSlideIndex` — slide index hook

```ts
useSlideIndex(totalSlides: number, deckId: string)
```

- Hash format: `#/{deckId}/{slideIndex}`, for example `#/my-deck/12`.
- **Escape** sets the hash to `#/`, returning to the portal.
- Reads and writes `window.location.hash` so `hashchange` stays in sync with routing.

**Returns:**

| Field | Type | Description |
|-------|------|-------------|
| `slide` | `number` | Current global index, 0-based |
| `goTo` | `(index: number) => void` | Jump to a specific slide |
| `next` / `prev` | `() => void` | Navigate forward or back |

Implementation:

```ts
import { useCallback, useEffect, useState } from "react";

export function useSlideIndex(totalSlides: number, deckId: string) {
  const parse = useCallback(() => {
    const m = window.location.hash.match(new RegExp(`^#/${deckId}/(\\d+)`));
    const n = m ? parseInt(m[1], 10) : 0;
    return Math.min(Math.max(n, 0), totalSlides - 1);
  }, [deckId, totalSlides]);

  const [slide, setSlide] = useState(parse);

  useEffect(() => {
    const onHash = () => setSlide(parse());
    window.addEventListener("hashchange", onHash);
    return () => window.removeEventListener("hashchange", onHash);
  }, [parse]);

  const goTo = useCallback((i: number) => {
    const next = Math.min(Math.max(i, 0), totalSlides - 1);
    window.location.hash = `#/${deckId}/${next}`;
  }, [deckId, totalSlides]);

  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "ArrowRight" || e.key === " ") { e.preventDefault(); goTo(slide + 1); }
      if (e.key === "ArrowLeft") { e.preventDefault(); goTo(slide - 1); }
      if (e.key === "Escape") { window.location.hash = "#/"; }
    };
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [slide, goTo]);

  return { slide, goTo, next: () => goTo(slide + 1), prev: () => goTo(slide - 1) };
}
```

### Deck router (`decks/{deck-id}/index.tsx`)

```tsx
const SLIDE_COUNTS = [1, 9, 2, 11, 2, 6, 8]; // one entry per chapter
const TOTAL = SLIDE_COUNTS.reduce((a, b) => a + b, 0);
```

`resolve(globalIndex)` returns `{ chapter, local }`. Each chapter component receives `localSlide`, 0-based within its chapter.

### `registry.ts`

```tsx
import { lazy } from "react";

export interface DeckDefinition {
  id: string;
  title: string;
  subtitle: string;
  accent: string;      // CSS colour or var()
  slideCount: number;  // portal card only — keep in sync by hand
  chapterCount: number;
}

export const DECK_DEFINITIONS: DeckDefinition[] = [
  { id: "my-deck", title: "My Deck", subtitle: "What it is about",
    accent: "var(--color-accent-blue)", slideCount: 24, chapterCount: 5 },
];

export const DECK_COMPONENTS: Record<string, React.LazyExoticComponent<any>> = {
  "my-deck": lazy(() => import("./my-deck")),
};
```

`slideCount` and `chapterCount` feed the portal card only. Nothing validates them against reality, so update them whenever slides change or the card starts lying.

---

## Layout components

### `SlideLayout`

Wraps slide content in the scaled viewport and renders `SlideHeader` automatically.

```tsx
interface SlideLayoutProps {
  children: ReactNode;
  /** Optional second logo; place the file in public/ */
  partnerLogoSrc?: string;
  partnerAlt?: string;
}
// Supports forwardRef for containerRef access
const SlideLayout = forwardRef<HTMLDivElement, SlideLayoutProps>(...)

export const SLIDE_W = 1512;
export const SLIDE_H = 739;
export const SLIDE_HEADER_ZONE = 100;
```

**Behaviour:** the outer div fills the viewport. The inner div is exactly `SLIDE_W × SLIDE_H`, scaled by `transform: scale(Math.min(vw / SLIDE_W, vh / SLIDE_H))` and centred with `transformOrigin: "center center"`.

### `SlideHeader`

Rendered by `SlideLayout`. Shows the deck logo at ~30% opacity, centred at the top. If `partnerLogoSrc` is set on `SlideLayout`, it renders a `×` separator and the second image.

### `ChapterTitle`

Full-screen chapter opener with a GSAP entrance.

```tsx
interface ChapterTitleProps {
  title: string;
  subtitle?: string;
}
```

**Animation:** a sequential timeline — a horizontal line scales in, the title fades up, the subtitle fades up. All `power3.out`.

---

## Visual components

### `Waveform`

An SVG waveform that morphs smoothly between configurations. One possible deck motif; skip it if your subject is not audio.

```tsx
interface WaveformConfig {
  frequency: number;   // burst density
  amplitude: number;   // peak height in SVG units
  color: string;       // stroke colour
  phase: number;       // horizontal shift
  yOffset: number;     // vertical offset from centre
  harmonic: number;    // high-frequency detail richness, 0–1
}

interface WaveformProps {
  config: WaveformConfig;
  className?: string;
}
```

**Implementation:** an 800-point SVG path across the full canvas. Three layers: an envelope (bursts), a carrier (the base oscillation), and harmonics plus noise. Two rendered paths — a blurred glow (6px stroke, 6% opacity, 24px blur) and a sharp line (1.5px, 18% opacity).

**Morphing:** when `config` changes, GSAP tweens every numeric property on a proxy object and re-renders the path in `onUpdate`. Colour transitions via `gsap.to(pathEl, { attr: { stroke } })`.

**Example configs**, one per section, so each section reads as a different shape:

| Section | freq | amp | phase | yOffset | harmonic |
|---------|------|-----|-------|---------|----------|
| 1 | 3 | 120 | 0 | 0 | 0.6 |
| 2 | 2 | 160 | π/4 | 40 | 0 |
| 3 | 5 | 80 | π/2 | −30 | 0.8 |
| 4 | 4 | 100 | π | 20 | 0.4 |
| 5 | 2.5 | 140 | 3π/2 | −20 | 0.3 |
| 6 | 1.5 | 180 | π/3 | 0 | 0.5 |

### `WaveConnector`

A wavy SVG connector between steps with an animated traveling beam.

```tsx
interface WaveConnectorProps {
  color: string;
  length: number;       // px
  delay?: number;       // seconds before animating
  direction?: "vertical" | "horizontal";
}
```

**Implementation:** a 40-point sinusoidal SVG path. A glowing circle travels along it in an infinite GSAP loop (1.4s cycle, `ease: "none"`), fading in after `delay`.

### `LightBeam`

A gradient line that animates in.

```tsx
interface LightBeamProps {
  direction?: "vertical" | "horizontal";
  color: string;
  length: number;
  delay?: number;
  style?: React.CSSProperties;
}
```

**Implementation:** a 2px div with `linear-gradient(transparent → color → transparent)`, scaled from 0 to 1 on the relevant axis by GSAP.

### `StepBox`

A numbered step card with a title, description, and optional badges. Note the cardinal rule in SKILL.md: a row of these is a card grid. Use them when a box is genuinely the metaphor, not as a default layout.

```tsx
interface StepBoxProps {
  number: string;        // "1.3" or "Phase 01"
  title: string;
  description?: string;
  accentColor: string;
  compact?: boolean;     // smaller padding, hides the description
  highlighted?: boolean; // default true; dims to 0.45 opacity when false
  badges?: string[];     // top-right badges
  style?: React.CSSProperties;
}
```

**Styling:** `background: var(--color-surface-raised)`, border `accentColor + "40"` when highlighted. Number in mono, accent colour. Title 24–28px. Description 20px, secondary colour.

### `StepIcon`

An icon that scales in with a bounce and then floats.

```tsx
interface StepIconProps {
  icon: string;    // key from your icon registry
  color: string;
  delay?: number;
}
```

**Animation:** scales in from 0.6 with `back.out(1.7)`, then floats ±2px infinitely with `sine.inOut` and yoyo.

Build the icon registry as a map of keys to SVG path data, and keep it in one file so icons stay visually consistent. Emojis are banned.

---

## Data patterns

### Typed data arrays

Each chapter defines its content in `data.ts` with typed exports. This keeps the copy editable without touching animation code, which matters when the user wants a wording change ten minutes before presenting.

```tsx
export interface Principle {
  number: number;
  title: string;
  subtitle: string;
  description: string;
  waveform: WaveformConfig;
}

export const principles: Principle[] = [
  { number: 1, title: "First principle", subtitle: "Short qualifier",
    description: "...", waveform: { frequency: 3, amplitude: 120, /* … */ } },
];
```

```tsx
export interface SubStep {
  title: string;
  description: string;
  icon: string;
  badges?: string[];
}

export interface Phase {
  number: number;
  title: string;
  lane: string;   // grouping label, e.g. "Control" | "Data"
  color: string;
  steps: SubStep[];
}

export const phases: Phase[] = [...];
```

---

## Layout patterns

### Two-column step layout

When a phase has more than four steps, split into two columns and connect the last item of column one to the first of column two with a bridging SVG path.

### Slide counter

```tsx
<div style={{
  position: "absolute", bottom: 48, right: 64,
  fontFamily: "var(--font-mono)", fontSize: 14,
  letterSpacing: "0.08em", color: "var(--color-text-tertiary)", zIndex: 3,
}}>
  {String(index + 1).padStart(2, "0")} / {String(total).padStart(2, "0")}
</div>
```

### Progress dots

```tsx
{items.map((_, i) => (
  <div key={i} style={{
    width: i === active ? 32 : 8, height: 8,
    borderRadius: "var(--radius-full)",
    background: i === active ? accentColor : "var(--color-border)",
    transition: "all 400ms ease",
  }} />
))}
```

---

## Config files

### `index.html`

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=1512, initial-scale=1.0" />
    <title>Presentation Title</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
```

The explicit viewport width makes the presentation render at full slide width before scaling.

### `vite.config.ts`

```ts
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import path from "node:path";

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      "@components": path.resolve(__dirname, "src/components"),
      "@hooks": path.resolve(__dirname, "src/hooks"),
    },
  },
});
```

### `tsconfig.json`

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "isolatedModules": true,
    "moduleDetection": "force",
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,
    "noUncheckedSideEffectImports": true,
    "baseUrl": ".",
    "paths": {
      "@components/*": ["src/components/*"],
      "@hooks/*": ["src/hooks/*"]
    }
  },
  "include": ["src"]
}
```

The alias must be declared in both files: Vite resolves it at build time, TypeScript at check time, and they do not read each other's config.
