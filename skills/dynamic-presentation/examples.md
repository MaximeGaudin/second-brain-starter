# Slide pattern examples

Concrete, copy-pasteable patterns. Imports use the `@components/…` alias, which works from any file under `decks/{id}/chapters/`.

---

## Pattern 1: Title slide

A full-screen opener with a sequenced GSAP entrance.

```tsx
import { useRef, useEffect } from "react";
import gsap from "gsap";
import SlideLayout from "@components/SlideLayout";

const ACCENT = "var(--color-brand)";

export default function TitleSlide() {
  const logoRef = useRef<HTMLImageElement>(null);
  const nameRef = useRef<HTMLSpanElement>(null);
  const subtitleRef = useRef<HTMLParagraphElement>(null);

  useEffect(() => {
    const tl = gsap.timeline({ defaults: { ease: "power3.out" } });
    tl.fromTo(logoRef.current,
        { opacity: 0, scale: 0.85 }, { opacity: 1, scale: 1, duration: 1.2 })
      .fromTo(nameRef.current,
        { opacity: 0, x: -40 }, { opacity: 1, x: 0, duration: 0.8 }, "-=0.2")
      .fromTo(subtitleRef.current,
        { opacity: 0, y: 20 }, { opacity: 0.7, y: 0, duration: 0.8 }, "-=0.3");
  }, []);

  return (
    <SlideLayout>
      <div style={{
        position: "absolute", inset: 0, display: "flex", flexDirection: "column",
        alignItems: "center", justifyContent: "center", gap: 40,
      }}>
        <div style={{ display: "flex", alignItems: "center", gap: 32 }}>
          <img ref={logoRef} src="/logo.png" alt="Logo"
            style={{ height: 80, width: "auto", opacity: 0 }} />
          <span ref={nameRef} style={{
            fontSize: 96, fontWeight: 700, letterSpacing: "-0.03em",
            lineHeight: 1, color: ACCENT, opacity: 0,
          }}>Title</span>
        </div>
        <p ref={subtitleRef} style={{
          fontSize: 26, fontWeight: 400, lineHeight: 1.6,
          color: "var(--color-text-secondary)", textAlign: "center", opacity: 0,
        }}>
          Subtitle text here.
        </p>
      </div>
    </SlideLayout>
  );
}
```

---

## Pattern 2: Chapter title

Use the shared `ChapterTitle` component — it handles the animated line, title, and subtitle entrance.

```tsx
import ChapterTitle from "@components/ChapterTitle";

// In the chapter's index.tsx:
if (localSlide === 0) {
  return (
    <ChapterTitle
      title="Architecture"
      subtitle="How the system is structured and why."
    />
  );
}
```

---

## Pattern 3: Morphing background with enter/exit content

A full-screen slide with a background motif that morphs between configs, and text that enters and exits with GSAP. Useful for a run of sibling slides — principles, pillars, chapters of an argument — where the background continuity signals "same idea, next facet".

**Chapter router:**

```tsx
import SlideLayout from "@components/SlideLayout";
import ChapterTitle from "@components/ChapterTitle";
import Waveform from "@components/Waveform";
import { principles } from "./data";
import PrincipleSlide from "./PrincipleSlide";

export default function PrinciplesChapter({ localSlide }: Props) {
  if (localSlide === 0) {
    return <ChapterTitle title="Principles" subtitle="..." />;
  }

  const idx = localSlide - 1;
  const active = principles[idx];

  return (
    <SlideLayout>
      <div style={{ position: "absolute", inset: 0 }}>
        <Waveform config={active.waveform} />
        {principles.map((p, i) => (
          <PrincipleSlide key={p.number} principle={p} visible={i === idx} />
        ))}
        <div style={{ position: "absolute", bottom: 48, left: "50%",
          transform: "translateX(-50%)", display: "flex", gap: 12, zIndex: 3 }}>
          {principles.map((p, i) => (
            <div key={p.number} style={{
              width: i === idx ? 32 : 8, height: 8,
              borderRadius: "var(--radius-full)",
              background: i === idx ? active.waveform.color : "var(--color-border)",
              transition: "all 400ms ease",
            }} />
          ))}
        </div>
      </div>
    </SlideLayout>
  );
}
```

**Individual slide with enter/exit:**

```tsx
import { useRef, useEffect } from "react";
import gsap from "gsap";

export default function PrincipleSlide({ principle, visible }: Props) {
  const containerRef = useRef<HTMLDivElement>(null);
  const els = [useRef(null), useRef(null), useRef(null), useRef(null), useRef(null)];

  useEffect(() => {
    const targets = els.map(e => e.current);
    if (visible) {
      gsap.set(containerRef.current, { visibility: "visible" });
      gsap.fromTo(targets,
        { y: 40, opacity: 0 },
        { y: 0, opacity: 1, duration: 0.8, ease: "power3.out", stagger: 0.1 });
    } else {
      gsap.to(targets, {
        y: -30, opacity: 0, duration: 0.5, ease: "power2.in", stagger: 0.04,
        onComplete: () => gsap.set(containerRef.current, { visibility: "hidden" }),
      });
    }
  }, [visible]);

  return (
    <div ref={containerRef} style={{
      position: "absolute", inset: 0, display: "flex", flexDirection: "column",
      justifyContent: "center", padding: "0 120px", visibility: "hidden", zIndex: 2,
    }}>
      <span ref={els[0]} style={{
        fontFamily: "var(--font-mono)", fontSize: 14, letterSpacing: "0.16em",
        textTransform: "uppercase", color: principle.waveform.color,
        opacity: 0, marginBottom: 24,
      }}>
        Principle {String(principle.number).padStart(2, "0")}
      </span>
      <div ref={els[1]} style={{
        width: 64, height: 3, borderRadius: "var(--radius-full)",
        background: principle.waveform.color, marginBottom: 32, opacity: 0,
      }} />
      <h1 ref={els[2]} style={{
        fontSize: 80, fontWeight: 600, lineHeight: 1.1, letterSpacing: "-0.04em",
        color: "var(--color-text-primary)", opacity: 0, marginBottom: 12,
      }}>
        {principle.title}
      </h1>
      <span ref={els[3]} style={{
        fontSize: 32, fontWeight: 400, color: principle.waveform.color,
        opacity: 0, marginBottom: 40,
      }}>
        {principle.subtitle}
      </span>
      <p ref={els[4]} style={{
        fontSize: 24, fontWeight: 400, lineHeight: 1.6,
        color: "var(--color-text-secondary)", opacity: 0,
      }}>
        {principle.description}
      </p>
    </div>
  );
}
```

---

## Pattern 4: Typographic wall (instead of a stat grid)

The replacement for "four stat cards". Numbers at fixed coordinates, counting up, with small mono labels underneath.

```tsx
import { useRef, useEffect } from "react";
import gsap from "gsap";
import { countTween } from "../../lib/anim";

const STATS = [
  { x: 60,   y: 40,  value: 94,   suffix: "%",  label: "Faster to draft" },
  { x: 620,  y: 150, value: 12,   suffix: "h",  label: "Saved per week" },
  { x: 180,  y: 290, value: 3.4,  suffix: "×",  label: "More output" },
];

export default function StatsSlide() {
  const ref = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!ref.current) return;
    const ctx = gsap.context(() => {
      const tl = gsap.timeline({ defaults: { ease: "power3.out" } });
      gsap.utils.toArray<HTMLElement>("[data-num]").forEach((el, i) => {
        tl.fromTo(el, { opacity: 0, y: 30 }, { opacity: 1, y: 0, duration: 0.7 }, i * 0.18)
          .add(countTween(el.querySelector("[data-val]")!, Number(el.dataset.num), {
            decimals: el.dataset.num!.includes(".") ? 1 : 0,
          }), "<");
      });
      tl.fromTo("[data-label]", { opacity: 0 }, { opacity: 1, duration: 0.5, stagger: 0.18 }, 0.3);
    }, ref);
    return () => ctx.revert();
  }, []);

  return (
    <div ref={ref} style={{ position: "absolute", inset: 0 }}>
      {STATS.map((s) => (
        <div key={s.label} data-num={s.value}
          style={{ position: "absolute", left: s.x, top: s.y, opacity: 0 }}>
          <div style={{
            fontSize: 112, fontWeight: 600, letterSpacing: "-0.04em",
            lineHeight: 1, color: "var(--color-text-primary)",
          }}>
            <span data-val>0</span>{s.suffix}
          </div>
          <div data-label style={{
            fontFamily: "var(--font-mono)", fontSize: 14, letterSpacing: "0.16em",
            textTransform: "uppercase", color: "var(--color-text-tertiary)",
            marginTop: 12, opacity: 0,
          }}>
            {s.label}
          </div>
        </div>
      ))}
    </div>
  );
}
```

---

## Pattern 5: Horizontal pipeline (instead of step cards)

A rail with nodes at fixed x positions, labels alternating above and below, and a pulse traveling the line forever.

```tsx
const RAIL_Y = 210;
const NODE_X = [120, 400, 680, 960, 1240];
const LABELS = ["Capture", "File", "Enrich", "Draft", "Send"];

// In the entrance timeline:
// 1. draw the rail:      tl.fromTo(rail, { scaleX: 0 }, { scaleX: 1, duration: 1, transformOrigin: "left center" })
// 2. pop the nodes:      tl.fromTo("[data-node]", { scale: 0 }, { scale: 1, duration: 0.4, stagger: 0.1, ease: "back.out(2)" }, "-=0.5")
// 3. fade the labels:    tl.fromTo("[data-label]", { opacity: 0, y: 10 }, { opacity: 1, y: 0, stagger: 0.1 }, "-=0.4")
// 4. then start the infinite traveling pulse (see SKILL.md → Traveling beam)
```

Keep every coordinate in the const block at the top. Labels alternate `RAIL_Y - 60` and `RAIL_Y + 40` so they can never collide with the rail or each other.

---

## Pattern 6: Chapter `index.tsx` with a slide array

For chapters with several slides:

```tsx
import { type ReactNode } from "react";
import SlideLayout from "@components/SlideLayout";
import ChapterTitle from "@components/ChapterTitle";
import Slide01Overview from "./Slide01Overview";
import Slide02Detail from "./Slide02Detail";

const contentSlides: ReactNode[] = [
  <Slide01Overview key="overview" />,
  <Slide02Detail key="detail" />,
];

export const CHAPTER_SLIDE_COUNT = contentSlides.length + 1;

export default function MyChapter({ localSlide }: Props) {
  if (localSlide === 0) {
    return <ChapterTitle title="My Chapter" subtitle="..." />;
  }

  return (
    <SlideLayout>
      <div style={{ position: "absolute", inset: 0 }}>
        {contentSlides[localSlide - 1]}
        <div style={{
          position: "absolute", bottom: 48, right: 64,
          fontFamily: "var(--font-mono)", fontSize: 14,
          letterSpacing: "0.08em", color: "var(--color-text-tertiary)", zIndex: 3,
        }}>
          {String(localSlide).padStart(2, "0")} / {String(contentSlides.length).padStart(2, "0")}
        </div>
      </div>
    </SlideLayout>
  );
}
```

Exporting `CHAPTER_SLIDE_COUNT` and importing it into the deck router beats hardcoding the number in `SLIDE_COUNTS`, because it cannot drift when you add a slide.

---

## Pattern 7: `anim.ts` helpers

```tsx
import gsap from "gsap";

/** Typewriter effect by slicing textContent. */
export function typeTween(el: Element, text: string, dur = 1.2) {
  const proxy = { i: 0 };
  return gsap.to(proxy, {
    i: text.length, duration: dur, ease: "none",
    onUpdate: () => { el.textContent = text.slice(0, Math.round(proxy.i)); },
  });
}

/** Count a number up, with optional prefix and decimals. */
export function countTween(el: Element, to: number,
  { prefix = "", decimals = 0 }: { prefix?: string; decimals?: number } = {}) {
  const proxy = { v: 0 };
  return gsap.to(proxy, {
    v: to, duration: 1.4, ease: "power2.out",
    onUpdate: () => { el.textContent = prefix + proxy.v.toFixed(decimals); },
  });
}

/** Impact shake — pair with a scale slam. */
export function shakeTween(el: Element, intensity = 8) {
  return gsap.fromTo(el,
    { x: -intensity },
    { x: 0, duration: 0.5, ease: "elastic.out(1, 0.3)" });
}
```

---

## Pattern 8: `globals.css`

```css
@import url("https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500&display=swap");

:root {
  --color-bg: #000000;
  --color-surface: #0C0C0C;
  --color-surface-raised: #1C1C1E;
  --color-border: #252525;
  --color-text-primary: #FFFFFF;
  --color-text-secondary: #A3A3A3;
  --color-text-tertiary: #727272;

  /* Replace with your own brand colour. */
  --color-brand: #947AFC;
  --color-accent-blue: #008CFF;
  --color-accent-pink: #FF5FB0;
  --color-accent-green: #4ADE80;
  --color-accent-orange: #FF630F;
  --color-accent-yellow: #F2CB45;

  --font-sans: "Inter", -apple-system, BlinkMacSystemFont, sans-serif;
  --font-mono: "JetBrains Mono", "Geist Mono", monospace;

  --space-xs: 8px;
  --space-sm: 16px;
  --space-md: 24px;
  --space-lg: 32px;
  --space-xl: 48px;
  --space-2xl: 64px;
  --space-3xl: 96px;

  --radius-sm: 8px;
  --radius-md: 16px;
  --radius-lg: 24px;
  --radius-full: 9999px;
}

*, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }

html, body, #root {
  width: 100%; height: 100%; overflow: hidden;
  background: var(--color-bg); color: var(--color-text-primary);
  font-family: var(--font-sans);
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

#root { display: flex; align-items: center; justify-content: center; }
```

---

## Pattern 9: `main.tsx` with the animation monitor

```tsx
import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import gsap from "gsap";
import App from "./App";
import "./styles/globals.css";

// Signals when a slide's finite entrance animations have settled, so a
// screenshot or PDF exporter knows when to capture.
declare global { interface Window {
  __slideAnimationsDone?: boolean;
  __signalAnimationsDone?: () => void;
} }

function watchAnimations() {
  let timer: number;
  const signal = () => {
    window.__slideAnimationsDone = true;
    window.dispatchEvent(new Event("slide-animations-done"));
  };
  window.__signalAnimationsDone = signal;

  const isInfinite = (t: gsap.core.Animation): boolean => {
    if (t.totalDuration() === Infinity || (t as any).repeat?.() === -1) return true;
    const parent = (t as any).parent;
    return parent ? isInfinite(parent) : false;
  };

  const start = () => {
    window.__slideAnimationsDone = false;
    clearTimeout(timer);
    const safety = window.setTimeout(signal, 10_000);
    window.setTimeout(function poll() {
      const busy = gsap.globalTimeline.getChildren(true, true, true)
        .some(t => t.isActive() && !isInfinite(t));
      if (busy) { timer = window.setTimeout(poll, 120); return; }
      clearTimeout(safety);
      signal();
    }, 600);
  };

  window.addEventListener("hashchange", start);
  start();
}

createRoot(document.getElementById("root")!).render(
  <StrictMode>
    <App />
  </StrictMode>,
);

watchAnimations();
```

---

## Naming conventions

| Item | Convention | Example |
|------|-----------|---------|
| Deck folder | kebab-case, matches the URL | `decks/customer-deep-dive/` |
| Chapter folder | kebab-case | `chapters/async-lifecycle/` |
| Slide file | `Slide{NN}{PascalName}.tsx` | `Slide01Overview.tsx` |
| Chapter router | `index.tsx` | `chapters/principles/index.tsx` |
| Data file | `data.ts` | `chapters/principles/data.ts` |
| Shared component | `PascalCase.tsx` | `components/WaveConnector.tsx` |
| Reusable slide layout | `{Role}Slide.tsx` | `PrincipleSlide.tsx` |
