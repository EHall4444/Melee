# MELEE
### Where talk meets results.

Melee is a social prediction platform where friend groups compete around any structured event — sports brackets, award show ballots, reality TV eliminations, and more. It was discovered, not designed: **BracketBattle**, a lacrosse bracket app built for a single friend group, proved that the social layer is more engaging than the event itself.

---

## What is Melee?

Make your picks. Back them up. Watch your friends suffer.

Melee is not ESPN. It's not fantasy sports. It's the place your specific friend group goes to settle arguments — with receipts.

- **Any event** — sports, Oscars, Survivor, NFL Draft, anything with a winner
- **Any group** — invite your crew with a code, name yourselves whatever you want
- **Real stakes** — picks are hidden until the reveal, then everyone sees everything
- **Trash Talk built in** — not an afterthought, the whole point

---

## Status

| Phase | Status |
|---|---|
| Phase 0 — BracketBattle POC | ✅ Complete |
| Phase 1 — MVP (Generalized platform + Groups + AI event creation) | 🔨 In Progress |
| Phase 2 — Beta (Polymarket integration, second group, Pick'em) | 📋 Planned |
| Phase 3 — Open Beta (User-generated events, public launch) | 📋 Planned |
| Phase 4 — Monetization (Host Pro, advertising) | 📋 Planned |

---

## Tech Stack

- **Frontend** — Next.js (React), Tailwind CSS, hosted on Vercel
- **Backend** — Supabase (Postgres, Auth, Realtime)
- **AI** — Event creation via plain English input + web search + source domain pull

---

## Core Concepts

| Term | Definition |
|---|---|
| **Melee** | The competition |
| **Group** | Your friend group (you name it) |
| **Host** | The person who creates the Melee |
| **Picks** | Your selections |
| **Stage** | A unit of competition (Round, Episode, Category, etc.) |
| **Contenders** | The options you pick from |
| **Outcome** | The result, entered by the Host |
| **Trash Talk** | The group social feed |

---

## MVP Scope

The MVP proves Melee works as a general platform across two meaningfully different event types:

1. **BracketBattle lacrosse bracket** — migrated from the original POC
2. **2027 Oscars ballot** — proves the platform works beyond sports

Everything else is post-MVP.

---

## Docs

- [`melee_brief_v1.2.docx`](./melee_brief_v1.2.docx) — Full product brief and strategy document

---

*Melee is a social competition engine. The event is interchangeable. The group is everything.*
