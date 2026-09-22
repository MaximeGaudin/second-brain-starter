# Second Brain Starter

Everything from the **Build Your Second Brain** workshop — AI Summit Barcelona 2026.

A second brain is a folder of markdown files and an agent that can read it. No database, no app, nothing to migrate out of later. What follows is the folder scaffold and the skills built during the session.

## Fastest way to use this

You do not need to clone anything, and you do not need to copy and paste these files by hand. Open your second-brain folder in Cursor and tell the agent:

```
Install the daily-routine skill from github.com/MaximeGaudin/second-brain-starter
```

It will fetch the file and write it to `.cursor/skills/daily-routine/SKILL.md`. Same line for any other skill — swap the name. Two of them ship more than a `SKILL.md`, so let the agent copy the whole folder: `to-pdf` carries a `template.typ`, and `dynamic-presentation` carries `reference.md` and `examples.md`.

To get everything at once:

```
Install every skill from github.com/MaximeGaudin/second-brain-starter into .cursor/skills/,
and put tone-of-voice.md in me/
```

## Start here

`bootstrap-prompt.md` takes you from an empty folder to a working second brain: the folder structure, a README with the rules, an interview that writes your first files, and two sample notes so you have something to ask questions about immediately.

Paste it into the agent in an empty folder and answer the five questions it asks you. It is the only thing in this repo you should run before anything else.

## The skills

Build them in this order. Each one assumes the one before it exists.

| Skill | What it does |
|---|---|
| `daily-routine` | The big one. Syncs every source into the folder, triages what arrived, drafts the replies, reports in five lines. |
| `build-a-document` | Gathers sources, makes you approve them, and only then writes. Hands the markdown off to render. |
| `to-pdf` | Renders markdown into a designed PDF through Typst, diagrams included. Ships the Typst template. |
| `dynamic-presentation` | Builds an animated deck as a small React app, one file per slide. Ships the component reference and the slide patterns. |
| `draft-reply` | Writes replies in the voice defined in `me/tone-of-voice.md`. |
| `what-is-next` | Ranks what to work on, using your ranking order rather than a generic one. |
| `morning-brief` | Calls `daily-routine` and reads its report out loud as an audio brief. |

They call each other rather than growing into one enormous prompt: `build-a-document` never formats anything itself — it hands finished markdown to `to-pdf` or to `dynamic-presentation`, and `morning-brief` does no triage of its own, it just reads `daily-routine`'s report out loud. That indirection is the whole model. It is also why you can replace the renderer without touching the writing.

`draft-reply`, `what-is-next` and `morning-brief` are the ones the workshop does not have time for. They work exactly the same way, and `morning-brief` is the clearest example of one skill calling another if you want to see the pattern on its own.

Everything you saw during the session — the slides and the example PDF — came out of `dynamic-presentation` and `to-pdf`. These are the real skills, not summaries of them: the hard-won parts are in there, including the GSAP gotchas that cost an afternoon each and the mermaid flags without which diagrams silently render blank.

The first time you run `to-pdf` it asks for a name, an accent colour, a logo and a font, writes them into `template.typ`, and never asks again.

`me/tone-of-voice.md` is not a skill. It is a single file describing how you write, which `draft-reply` and anything else that writes for you reads every time.

## Rewrite them

These are my skills, tuned to how I work. They will be wrong for you in small ways, and those small ways are the point.

When an answer comes back wrong, resist fixing that one answer. Fix the instruction that produced it, so it stays fixed. That is the whole difference between using AI and building with it.

`daily-routine` is the exception. It is the heavy one and it took months of iteration to settle. Take it as it is, live with it for a few weeks, then start tuning.

## Two skills I did not write

Skills are files, so the good ones travel. These two are not mine, are not about second brains, and are on every machine I work from.

[adhd](https://github.com/UditAkhourii/adhd) — `npx skills add UditAkhourii/adhd`. Instead of answering your question once, it asks it six ways in parallel under different framings, scores the answers, throws out the traps and deepens what survives. Use it on naming, design decisions and anything shaped like "give me a few ways to…".

[caveman](https://github.com/JuliusBrussee/caveman) — `npx skills add JuliusBrussee/caveman -g`. Same answers, a quarter of the words. Code, paths and error messages are left alone; only the throat-clearing around them dies.

## The slides

[`slides/second-brain-workshop.pdf`](slides/second-brain-workshop.pdf) — all 58 slides, static, for reading on a train.

[`slides/second-brain-workshop.html`](slides/second-brain-workshop.html) — the same deck with the animations intact. Download it and open it; it needs no server and no network. Arrow keys move between slides.

Both were built out of a folder like this one, by the two skills above.

## Rules worth keeping

- Plain markdown only. The folder is the product; the editor is replaceable.
- Cite the file every fact came from. If it is not in the files, the agent says so rather than guessing.
- The agent drafts, you send. Keep that boundary on anything carrying a commitment.
- Approve the source list before a single sentence gets written.
- Do not automate the human parts. One-to-ones and growth conversations stay manual, on purpose.

## The seven-day challenge

Day 1–2: document your projects and your team. Day 3–4: document your processes. Day 5–6: capture a note after every meeting. Day 7: write your first skill of your own.

---

Questions, or you built something good with this — [Maxime Gaudin](https://www.linkedin.com/in/maximegaudin/), CTO at [Gladia](https://www.gladia.io).
