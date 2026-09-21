# Second Brain Starter

Everything from the **Build Your Second Brain** workshop — AI Summit Barcelona 2026.

A second brain is a folder of markdown files and an agent that can read it. No database, no app, nothing to migrate out of later. What follows is the folder scaffold and the six skills built during the session.

## Fastest way to use this

You do not need to clone anything, and you do not need to copy and paste these files by hand. Open your second-brain folder in Cursor and tell the agent:

```
Install the daily-routine skill from github.com/MaximeGaudin/second-brain-starter
```

It will fetch the file and write it to `.cursor/skills/daily-routine/SKILL.md`. Same line for any other skill — swap the name.

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
| `to-pdf` | Renders markdown into a designed PDF through Typst, diagrams included. |
| `dynamic-presentation` | Builds an animated deck as a small React app, one file per slide. |
| `morning-brief` | Calls `daily-routine` and reads its report out loud. |
| `draft-reply` | Writes replies in the voice defined in `me/tone-of-voice.md`. |
| `what-is-next` | Ranks what to work on, using your ranking order rather than a generic one. |

They call each other rather than growing into one enormous prompt: `morning-brief` calls `daily-routine`, and `build-a-document` never formats anything itself — it hands finished markdown to `to-pdf` or to `dynamic-presentation`. That indirection is the whole model. It is also why you can replace the renderer without touching the writing.

`draft-reply` and `what-is-next` are the two the workshop does not have time for. They work the same way.

Everything you saw during the session — the slides and the example PDF — came out of `dynamic-presentation` and `to-pdf`.

`me/tone-of-voice.md` is not a skill. It is a single file describing how you write, which `draft-reply` and anything else that writes for you reads every time.

## Rewrite them

These are my skills, tuned to how I work. They will be wrong for you in small ways, and those small ways are the point.

When an answer comes back wrong, resist fixing that one answer. Fix the instruction that produced it, so it stays fixed. That is the whole difference between using AI and building with it.

`daily-routine` is the exception. It is the heavy one and it took months of iteration to settle. Take it as it is, live with it for a few weeks, then start tuning.

## Rules worth keeping

- Plain markdown only. The folder is the product; the editor is replaceable.
- Cite the file every fact came from. If it is not in the files, the agent says so rather than guessing.
- The agent drafts, you send. Keep that boundary on anything carrying a commitment.
- Approve the source list before a single sentence gets written.
- Do not automate the human parts. One-to-ones and growth conversations stay manual, on purpose.

## The seven-day challenge

Day 1–2: document your projects and your team. Day 3–4: document your processes. Day 5–6: capture a note after every meeting. Day 7: write your first skill of your own.

---

Questions, or you built something good with this — [Maxime Gaudin](https://www.linkedin.com/in/maximegaudin/), VP Engineering at [Gladia](https://www.gladia.io).
