MELEE
You're watching anyway. Now watch together.

meleeme.com

Melee is a social prediction platform where private friend groups compete around any structured event — sports brackets, award show ballots, reality TV eliminations, and more. It was discovered, not designed: an accidental beta built for a single friend group proved that the social layer drives more engagement than the event itself.


What it does
A Host creates a Melee in minutes — describing the event in plain English, letting the AI scaffold the full structure, then sharing an invite code with their group. Everyone submits picks. Picks are visible to the group immediately. The leaderboard updates as results come in. A Chatter feed lets the group talk trash in real time.

The event is the excuse. The banter is the product.

Core features:

AI-assisted event creation — describe any event, get a fully structured Melee in seconds
Private Groups with invite codes and user-defined names
Real-time leaderboard, Chatter feed, and Activity Feed
Pick transparency — your picks are visible to the group the moment you submit
Pick change history — last-minute hedges are visible to everyone and live forever after the deadline
Zero-knowledge entry — random autofill means anyone can play, no expertise required
Spectator mode — invite-only read-only access for non-participants
Works for any event: brackets, ballots, pick'em, survival pools, and more


MVP event types
Format
Description
First Melee
Bracket
Single-elimination picks round by round
NCAA DI Men's Lacrosse Championship (migrated from beta)
Ballot
Pick a winner per category, one night of results
2027 Oscars



Tech stack
Layer
Technology
Cloud
AWS
Backend
Node.js
Primary DB
PostgreSQL
Feed / Chatter
NoSQL (high-frequency write surfaces)
Real-time
WebSockets (API Gateway or equivalent)
Auth
JWT-based (provider at team discretion)


Full schema documentation is in SCHEMA.md and the Schema Reference Document. Read the schema doc before writing application code. Stack choices are at team discretion. Schema decisions are not.


Project structure
/

├── README.md               — this file

├── SCHEMA.md               — full schema reference (see also the Schema Reference Document)

├── /src

│   ├── /api                — Node.js API layer

│   ├── /db                 — database migrations and seed data

│   ├── /realtime           — WebSocket handlers (Chatter, Activity Feed, leaderboard)

│   ├── /ai                 — event creation flow (plain English → structured Melee draft)

│   └── /client             — frontend (framework at team discretion)

└── /docs

    ├── melee_brief.docx    — full product brief

    └── melee_schema.docx   — schema reference document


Getting started
Prerequisites
Node.js 20+
PostgreSQL 15+
AWS account with appropriate IAM permissions
API keys: see .env.example
Setup
# Clone the repo

git clone https://github.com/meleeme/melee.git

cd melee

# Install dependencies

npm install

# Configure environment

cp .env.example .env

# Fill in your AWS credentials, DB connection string, and auth config

# Run database migrations

npm run db:migrate

# Seed the lacrosse bracket (migrated from beta)

npm run db:seed

# Start the development server

npm run dev
Environment variables
Variable
Description
DATABASE_URL
PostgreSQL connection string
AWS_REGION
AWS region
JWT_SECRET
Secret for JWT signing
AI_API_KEY
API key for event creation AI (Claude)
WEBSOCKET_ENDPOINT
WebSocket server endpoint


Full list in .env.example.


Non-negotiable schema rules
These apply regardless of stack choices. See SCHEMA.md for full details.

Picks are group-scoped at the DB level. A pick is user + group + stage + contender — not just user + stage + contender. Enforced in the query layer, not just the UI.
pick_history exists from day one. Pick change history is a core social feature. It cannot be added retroactively.
Stage hierarchy is recursive via parent_id. One table handles brackets, ballots, survival pools, and any future format.
No hard deletes. Use deleted_at soft deletes on users, groups, and events. Historical pick data must be preserved.
Real-time is not optional. Chatter, Activity Feed, and leaderboard updates must push to connected clients. No polling.


Roadmap
Phase
Focus
Status
Phase 0
Accidental beta — NCAA lacrosse bracket POC
✅ Complete
Phase 1 — MVP
Generalized platform, Groups, AI event creation, Oscars ballot
🔨 In progress
Phase 2 — Beta
Polymarket integration, second friend group, NFL Pick'em
Upcoming
Phase 3 — Open Beta
User-generated events, public launch, cross-event Group leaderboard
Upcoming
Phase 4 — Monetization
Host Pro, Member Expression, media partnerships
Future



Contributing
This is a private project in active development. If you're on the build team and don't have access, reach out to the project lead.



MELEE · meleeme.com · Private · May 2026

