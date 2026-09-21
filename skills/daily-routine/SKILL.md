---
name: daily-routine
description: Execute the daily communication routine — sync every source into the brain, triage the inbox, process messages, handle the calendar, reach Inbox Zero. Use when the user asks to run their daily routine, check their inbox, do their morning triage, or reach Inbox Zero.
---

# Daily Routine

Orchestrate the daily communication triage across every connected source. The goal is **Inbox Zero**: every item is either acted upon or acknowledged, then archived. The routine is complete when every source comes back empty — not when you get tired.

**Prerequisite:** connectors installed from the marketplace for the sources the user actually lives in. Typically mail, chat, and calendar. The routine degrades gracefully: skip any step whose connector is missing, and say so in the final report rather than failing.

## Configuration

Declare the user's sources once, in `me/sources.md`, and read that file at the start of every run. A source entry is a connector plus an account, because "mail" is rarely one inbox:

```
mail      · work account
mail      · personal account
chat      · workspace
calendar  · work account
```

The daily digest lives in the knowledge base, one cumulative file per day:

```
digest/YYYY-MM-DD.md
```

## Date format convention

Work in **ISO 8601 / RFC 3339** strings (`2026-03-15T14:00:00Z`), never raw Unix timestamps, for every timestamp you read or write. When creating events or querying date ranges, include the timezone offset (`2026-03-15T14:00:00+01:00`). Half the bugs in a routine like this are a date silently interpreted in the wrong zone.

## Inbox Zero model

- The inbox is everything **unarchived** across every connector.
- Each item must be **processed**: replied to, reacted to, delegated, written down, or simply acknowledged.
- Once processed, **archive** it.
- The routine is done when every source returns empty.
- Purely informational items are archived after appearing in a digest or report — but they do appear. Archiving something the user never saw is the same as deleting it.
- **Never archive a starred or flagged item.** If the user marked it, they kept it on purpose, and it must be presented for manual processing regardless of what it contains or who sent it.
- **Never delete anything.** Archiving is the strongest action you may take.

## Routine steps

### 1. Calendar overview

Start with today's schedule, so everything after this has context for time-sensitive decisions.

Review upcoming meetings. If any need preparation, note it. If invitations need a response, handle them now — accept, decline with a one-line reason, or mark tentative.

### 2. Sync — nothing is read until it is filed

Pull what arrived since the last run and write it into the folder, because anything that stays in a chat window is gone tomorrow:

- meeting transcripts and recordings → `notes/YYYY/MM/YYYY-MM-DD - title.md`
- decisions taken in a thread → the initiative folder they belong to
- a person you had not met before → `people/<name>.md`, with where you met
- anything about a project → `initiatives/<project>/`

Cite the source and the date on everything you write. Do not summarise away the numbers.

Report this step as a list of file paths, nothing more. The user does not want to read the sync, they want to know it happened.

### 3. Action items from recent meetings

**Before processing any inbox**, scan the knowledge base for meeting notes from **yesterday morning through now**. The point is to surface every commitment made in a meeting, so the user's working list is built from what they promised rather than from what happens to be loudest in their inbox.

1. Determine the date range: yesterday 00:00 → now.
2. Search `notes/` for files in that window.
3. For each note found, extract:
   - **Action items** assigned to the user — tasks, commitments, "I will", TODO-style items.
   - **Action items** assigned to others that the user should follow up on.
   - **Decisions** made that imply downstream work.
   - **Open questions** left unresolved.
4. **Cross-reference each item** against messages, knowledge base entries, and conversation context to determine its current status. An item is often already done — the message was sent, the decision was communicated — or blocked, waiting on someone else.
5. Present the items in **three categories**, in this order:

```
## Action Items

### Actionable Now
Items the user can act on right now. Start here.
- [ ] [Action item] [deadline if any] [source: meeting/note]

### Waiting / Blocked
Items where the user has done their part and is waiting on someone else.
- [ ] [Action item] — waiting on [person] for [what] [since when]

### Done
Items already completed. Kept for traceability.
- [x] [Action item] — [how/when it was completed]
```

Always present **Actionable Now** first — that is the working list. Flag anything due today or overdue inside that section.

6. **Be maximally proactive on actionable items.** For every item in "Actionable Now", if you can execute the action, you MUST draft it and propose it for validation — not merely list it:
   - **"Send a message to X"** → draft the message, show it, ask "Want me to send this?"
   - **"Organise a meeting with X"** → check availability, propose a slot, draft the invitation
   - **"Write a brief / spec / doc"** → draft the content from knowledge base context, propose it for review
   - **"Ask X about Y"** → draft the message, show it, ask for validation
   - **"Follow up with X"** → draft the follow-up with the context already in it

   The goal: every actionable item arrives with a ready-to-execute draft. The user should only ever need to say "go" or "change this", never "ok, now write it".

### 4. Triage the inbox

**Always fetch by source and by account**, and keep them separate. A single mixed pile is harder to process and hides which account is actually drowning.

Process source by source. Each source follows an iterative loop: fetch → process the current batch → fetch again → repeat until empty. Messages that arrive during processing are caught on the next pass.

### 5. Enrich items with knowledge base context

**Before presenting any item to the user**, enrich it. Never present a bare subject line.

Search the knowledge base while you fetch — `people/`, `initiatives/`, `notes/`, and anything else the folder holds — for entries matching each sender, company, project, or deal. Run these lookups in parallel with the fetch rather than serially after it.

For every item presented, include:

```
### [#] [Source] — [Subject / topic]
**From:** [Sender name + role/company if known]
**Content:** [Full substance — what they actually say, key points, numbers, questions.
              Enough detail to decide without opening the original.]
**Context:** [Matching knowledge base entries — person file, project, recent meeting notes —
              with file paths. "Nothing in the folder" if there is no match.]
**What they want:** [Explicit or implicit ask — decision, reply, action, information, or "Nothing (FYI)".]
**Recommended action:** [Archive / Reply (with draft) / Escalate / Investigate]

```

The test: the user reads your summary and decides immediately, without opening the original or searching the folder themselves.

### 6. Process mail

1. Fetch the inbox per account, separately.
2. Start with the most important email, not the most recent.
3. **Auto-archive**: marketing and promotional mail, calendar update notifications (not invitations), shipping and delivery notices, unsolicited recruiter outreach, automated tool notifications, and generic role-address traffic the user does not personally own.
4. **Never auto-archive**: self-sent mail, anything labelled as a TODO, and anything starred or flagged.
5. For each remaining email, present the enriched summary plus the expected action, and ask: archive, answer, or next.
6. When answering, **create a draft — never send**. Offer a scheduling link when the reply is about finding a slot.
7. Log each action to `history/email.md`, one line per item.
8. Loop until the inbox is empty.
9. Track invoices and receipts for the end-of-session summary.

#### 6b. Receipt and invoice archiving

Expense mail is worth handling properly once, because the alternative is searching your mail for a receipt eleven months later during an audit.

When you encounter an invoice, receipt, or expense email — travel bookings, ride receipts, hotels, SaaS invoices, payment notifications with an attached document:

1. **Download** every PDF attachment.
2. **Rename** each file with this convention:

   ```
   YYYY-MM-DD_<vendor>_<amount><CURRENCY>_<description>.pdf
   ```

   For example:
   - `2026-05-11_rail-operator_232.80EUR_return-ticket.pdf`
   - `2026-03-15_ride-app_23.50EUR_airport-transfer.pdf`
   - `2026-02-01_notion_96.00EUR_annual-subscription.pdf`

   Rules for the filename:
   - Date is the **transaction** date when available, not the email date.
   - Vendor is lowercase, hyphenated, no spaces.
   - Amount keeps its decimals and is followed by the currency code.
   - Description is a short, lowercase, hyphenated summary of what was bought.

3. **Store** in `receipts/YYYY/MM/`, creating subfolders as needed.
4. When several PDFs belong to one transaction, group them in a subfolder named after the transaction rather than inventing four near-identical filenames.

Everything is then archived locally with searchable filenames, independent of continued access to the mail account.

### 7. Process chat

#### Daily digest — `digest/YYYY-MM-DD.md`

One cumulative file per day. Entry format:

```
### #channel-name — Sender Name (HH:MM)
One-line summary.
```

Prefix the summary with `[URGENT]` when it genuinely is.

**At the start of the chat step**, read what is already in today's file. Before appending, check you are not duplicating an entry for the same message. **After the loop finishes**, re-read the file and present the **complete digest**, grouped by channel, urgent first, flagging anything that still looks actionable.

Never present a digest assembled from your own memory of the conversation. The file is the source of truth — that is the whole reason it exists.

#### Inbox loop

1. **Fetch** unread chat messages.
2. **If empty** → present the digest from the file, then move on.
3. **For each item in the batch**, classify into one of three tiers:

   **Tier 1 — Noise** (archive, no digest line):
   - The user's own messages, messages they already reacted to, bot traffic (CI, issue trackers, deploys), empty or emoji-only messages, chatter with no informational value.

   **Tier 2 — Informational** (append one line to the digest, then archive):
   - Channel messages where the user is not mentioned, carrying real content: team wins, product and technical updates, articles, hiring news, resolved incidents, customer news.
   - Every Tier-2 item gets its digest line **before** it is archived. No exceptions — this is the tier where information quietly disappears.

   **Tier 3 — Needs attention** (leave in the inbox until the user acts, or acknowledge then archive):
   - Direct messages, private channels, group conversations, and anything that mentions the user by name or handle.
   - Prioritise: direct messages first, then direct mentions, then private channels and groups.
   - Enrich with knowledge base context (step 5).
   - **Auto-acknowledge** FYI items that need no input, with a reaction rather than a message.
   - For everything else: present it and ask — mark as read, answer, acknowledge, or next.
   - When answering, reply in the language and the register of the original message.

   When you cannot tell which tier something belongs to, it goes in Tier 3. Being wrong in that direction costs the user ten seconds.

4. **Log** each action to `history/chat.md`.
5. **Go back to step 1** — fetch again to catch what arrived while you were working.

The loop exits when the fetch returns empty. Then **always** re-read the digest file and present the full cumulative version, not only in the case where the inbox was already empty at the first fetch.

### 8. Process the remaining sources

Personal messaging, and any low-priority informational feed, are processed last and in the same shape: fetch, present, decide, archive. Draft replies in the user's usual language for that channel, and ask for validation before anything is sent.

Read-only feeds — news, article aggregators — get one grouped summary by relevance, then archive. There is nothing to reply to.

### 9. Archive and verify

Archive in bulk rather than one call per item. Then re-fetch every source and confirm it is empty. If items remain anywhere, continue processing. The routine is complete when every source returns nothing.

### 10. Summary report

After reaching Inbox Zero, report in this order:

1. **What needs the user today** — five lines maximum, hardest first.
2. **Action items** — the consolidated list from step 3, plus anything new from today's triage.
3. **Calendar** — key meetings today, responses sent.
4. **Drafts** — what you wrote, and where to find it.
5. **Per source** — replies drafted, items archived, items skipped, as counts, not lists.
6. **Digest** — the full cumulative digest file for today.
7. **Receipts** — invoices archived and files saved to `receipts/`.
8. **Pending** — anything skipped with "next" that needs follow-up later.
9. **Unsure** — anything you could not classify confidently.

Then propose the one line you would add to this skill file to make tomorrow's pass cleaner, and wait for approval before editing it.

## Source-specific notes

### Mail
- **Never send. Drafts only, every time, no exceptions.**
- Apply every auto-archive rule and every exception from step 6.
- When scheduling, offer a booking link rather than proposing slots in prose.
- When someone forwards an FYI with no comment, summarise it properly and archive it.
- Default to the work account unless the user says otherwise.

### Chat
- Use a reaction for acknowledgement — it avoids a message nobody needed.
- Prefer editing a sent message over sending a correction.
- Use scheduled sending when the reply is ready but the hour is not, for example a message written at 23:00 that should land at 09:00.
- Follow the platform's formatting conventions; chat is not email and threads are not documents.
- Log actions to `history/chat.md`.
- **Never send without explicit confirmation.**

### Personal messaging
- Resolve the recipient before drafting — sending the right message to the wrong person is worse than sending nothing.
- Match the user's usual language and register for that channel, which is rarely the work one.
- **Never send without explicit confirmation.**

### Calendar
- Check for conflicts before creating anything.
- Respect the working hours and the meeting preferences declared in `me/preferences.md`. If that file does not exist, ask once and write it.
- **Morning first**: prioritise morning slots so the afternoon stays open.
- Preparation blocks do not need to sit next to the meeting they prepare.

## Message composition rules

1. Write in the voice described in `me/tone-of-voice.md`. If that file does not exist yet: short, direct, no hedging, no "I hope this finds you well".
2. **Ask for confirmation** before sending any message or creating any draft.
3. Match the language of the original message.
4. When writing in a language that is not the user's first, re-read the sentence and check it actually says what it means.
5. Use the right formatting for each platform.
6. If you cannot answer without something the user has not told you, say what is missing instead of guessing.

## Not negotiable

- **Never send anything.** Drafts only.
- **Never delete.** Archive is the strongest action available, and only after approval.
- **Never archive anything starred or flagged.** If the user marked it, they want to see it.
- **Never decide something important on the user's behalf.** Bring them the decision, with a recommendation.
