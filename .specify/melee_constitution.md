# Melee Constitution

**Project:** Social prediction platform for friend groups  
**Version:** 1.0  
**Last Updated:** May 2026  
**Status:** Governing principles — applies to all development phases

---

## Overview

This constitution defines the non-negotiable principles, architectural constraints, and brand pillars that guide all Melee development. Every feature, every code decision, and every design choice must survive evaluation against these principles. When in doubt, refer back here.

---

## I. The Core Mission

**Melee is game night, not a betting app.**

Melee is a social prediction platform where friend groups compete around any structured event — sports brackets, award show ballots, reality TV eliminations — with chatter and accountability built in. The social layer drives more engagement than the event itself. The stakes are social (bragging rights, group history), never financial.

**What we're building for:** The moment when everyone is in it — the chaos of friends arguing about who had the right pick, whose bold take aged well, whose confident prediction aged terribly.

---

## II. Non-Negotiable Architecture

These are schema and database decisions. They are not negotiable and must survive the build intact. Do not defer, do not work around, do not compromise.

### 2.1 Group-Scoped Picks at the Database Level

**Decision:** Picks are group-scoped from day one. A pick is not `user + stage + contender`. It is `user + group + stage + contender`.

**Why:** Privacy. A user in two different Groups makes independent picks for each. Group-scoped picks must be enforced at the database layer (row-level security in Supabase), not just the UI.

**Implementation:** The `picks` table has a foreign key to `groups`. Supabase RLS policies enforce that a user can only query picks from groups they belong to. This cannot be retrofitted later.

**Risk if violated:** Privacy breach. Users see each other's picks across groups. Catastrophic and painful to fix retroactively.

### 2.2 Pick History Exists from Day One

**Decision:** `pick_history` table is created and populated from the first pick ever made. Pick changes are not added retroactively later.

**Why:** Pick change history ('the receipts') is a core social mechanic, not a nice-to-have. The group sees when and what a member changed before the deadline. This drives Chatter and accountability. You cannot reconstruct this history retroactively.

**Implementation:** Every `UPDATE` to `picks.contender_id` writes a row to `pick_history` with timestamps, user, old/new values.

**Risk if violated:** Feature simply doesn't exist for early users. Cannot be added later.

### 2.3 Stage Hierarchy is Recursive via parent_id

**Decision:** One `stages` table with `parent_id` foreign key to itself. Infinitely nestable. No format-specific schema migrations.

**Why:** Brackets have rounds containing matchups. Oscars have category groups containing categories. Survivor has episodes containing tribal councils. One table handles all without schema changes per event type.

**Examples:**
- Bracket: Stage (Round 1) → SubStage (Matchup: Team A vs Team B)
- Ballot: Stage (Best Picture category) → no substages
- Survival Pool: Stage (Episode 7) → SubStage (Tribal Council) → SubStage (Individual Immunity)

**Risk if violated:** New event format requires migration. Each new format becomes expensive. Platform does not scale.

### 2.4 Domain-Neutral Naming Throughout

**Decision:** Use `stages`, `contenders`, `outcomes` everywhere. Not `categories`, `options`, `results`. Not `rounds`, `matchups`, `winners`.

**Why:** Works across sports, entertainment, reality TV, any future event type. Format-specific labels (Round 1, Best Picture, Episode 7) are *user-facing UI strings* defined by the Host, not schema field names.

**Implementation:** Schema and code use neutral terms. UI renders Host-defined labels. Teams stay aligned.

**Risk if violated:** Inconsistent naming creates confusion. Codebase becomes harder to extend. New developers don't understand the domain model.

### 2.5 Cross-Event Group Leaderboard Supported from Day One

**Decision:** The schema supports a Group's all-time record across every Melee they've played. This is a Phase 3 feature, but the schema must support it from day one.

**Why:** Cannot be retrofitted without migrating all historical picks. The all-time leaderboard is a Phase 3 feature, but schema decisions cannot wait until Phase 3.

**Implementation:** Group-scoped pick schema already supports this. No breaking changes needed.

**Risk if violated:** Phase 3 requires expensive data migration.

---

## III. Brand Pillars (Not Negotiable)

These are brand and positioning principles. Every feature and every message must pass the test: does this reinforce or undermine the brand?

### 3.1 Melee is the Anti-Bet

**Core Principle:** Melee occupies a fundamentally different space from betting platforms. This is a brand pillar, not a footnote.

| Betting | Melee |
|---------|-------|
| Transactional. You vs. the house, alone. | Communal. You vs. your friends, together. |
| Material gain. Too much skin in the game. | Bragging rights. Social stakes. |
| The worse your friends do, the better. | You want your friends there — to be wrong, to answer for it. |
| Stressful. | Fun. It's game night. |

**What this means:**
- No money involved. No payments, subscriptions, or stakes at MVP.
- No odds or probability data shown during pick selection — this pulls toward betting aesthetics.
- Polymarket and prediction markets are referenced only as *event structure data sources*, never as betting partners.
- When someone asks "is this gambling?", the answer is: "No. It's game night with your friends."

**What this does NOT mean:**
- You can't show odds during spectating (after picks lock). That's ammunition for Chatter, not a decision tool.
- You can't reference prediction markets for event discovery in Phase 2. You can — just frame it as "finding events to compete on," not "finding markets to bet on."

### 3.2 Picks are Vibes, Not Math

**Core Principle:** A pick made on conviction and personality is a stronger product than a pick made by optimizing against odds.

**What this means:**
- No odds, consensus percentages, or probability data visible during pick selection — ever. This is a platform decision, not a Host toggle.
- Players pick blind. They commit. Their picks become their accountability.
- Pick diversity (players making different choices) is a product feature because it drives leaderboard drama and Chatter.

**Why:** When players see that a team is favored 78%, picks converge. The leaderboard flattens. The casual friend who autofilled and won is only a wow moment if the expert who "knew better" lost. Consensus kills the story.

**What this does NOT mean:**
- You can't show group-scoped probability during spectating. You should. ("You're the only one who picked Maryland — here's what that means for your standing.")
- You can't build features that help players make informed picks. You can — just don't show odds.

### 3.3 Your Words Stand. Your Picks Stand. Own It.

**Core Principle:** Melee has no comment edit function. No take-backs. This is a brand statement.

**What this means:**
- Comments cannot be edited after posting. If you trash talk, it lives forever.
- Comments require a confirmation step before posting. This is the UX guardrail — not to prevent posting, but to make the moment intentional.
- Pick change history is visible to the group after the deadline. You can see when and what someone changed. No hiding.

**Why:** This reinforces the whole Melee ethos. Your words matter. Your picks matter. There's accountability. The group remembers.

**What this does NOT mean:**
- You can't delete comments entirely (moderation still needed at scale).
- You can't have a "drafts" feature for composing comments before submission.

### 3.4 The Host is the DJ, Not the Referee

**Core Principle:** The Host sets the *experience* of the Melee. The Host does not set the *competitive conditions*.

**What this means:**
- Host customization is appropriate for: elimination style, pick reveal mechanics, leaderboard taunts, group names, event descriptions.
- Host customization is NOT appropriate for: whether odds are shown, what information is available to players, which tie-break method is used.
- Odds visibility during picks is a *platform decision*, not a Host toggle. Same for comment editing, pick scoping, etc.

**Why:** Competitive conditions must be consistent across all groups playing the same event. A player discovering that another group had access to odds during selection will reasonably question fairness. That conversation should never happen.

**What this does NOT mean:**
- Hosts can't customize the feel of their Melee. They can — via elimination style, reveal mechanics, leaderboard personality.
- Hosts can't choose tie-break methods. They can — those are fully automatic (Prop Question default, Submission Timestamp, or Closest to the Pin).

---

## IV. Mobile-First Design Mandate

**Core Principle:** Every emotionally significant moment in Melee happens on a phone on a couch.

### 4.1 Mobile-First, Not Mobile-Responsive

**Decision:** Design and QA mobile first. Desktop is secondary. Native iOS/Android are post-MVP.

**Screens that must be mobile-perfect:**
- Chatter feed and post composition
- Pick submission and confirmation
- Leaderboard
- Activity Feed (pick changes)

**Standard:** If it feels awkward on a phone, it's not done. One-thumb interaction. No horizontal scrolling. Tap targets large enough.

### 4.2 Chatter Must be Persistent and Accessible

**Decision:** Chatter is accessible from every screen — not buried at the bottom of a tab, not a separate view to navigate to.

**Why:** The impulse to trash talk fires in a moment. If Chatter requires navigation, that moment dies. The feature doesn't work if it's not immediate.

**Implementation:** Floating action button, persistent bottom nav, or always-visible sidebar — pick one. The method doesn't matter. The accessibility does.

### 4.3 Invite Links Must Work in One Tap

**Decision:** Invite links resolve cleanly in iMessage, WhatsApp, Twitter, or any messaging surface. Group join requires no account creation to preview.

**Implementation:** OG cards on invite links (event name, group name, pick deadline). Rich preview that sells the moment before the recipient taps.

---

## V. The Host Experience Must Be Fast

**Core Principle:** A Host can create a live Melee in under 5 minutes. AI-assisted event creation is the unlock.

### 5.1 Phase 1: Fast (AI-Assisted)

**Decision:** Host describes event in plain English. AI scaffolds full structure. Host reviews draft and confirms. Melee is live.

**Host tasks:**
1. Describe the event
2. Confirm the AI draft (or edit it)
3. Share the invite code
4. Enter Outcomes after the event

**Metric:** Median setup time under 5 minutes for any supported event type.

### 5.2 Phase 2: Fun (Customization)

**Decision:** Host gets visual setup screen. They pick their Melee's personality in a few taps. Customization is optional, never required.

**Customization options:**
- Elimination style (Ghost, Skeleton, LOSER stamp)
- Pick reveal mechanic (slow drip, worst-to-best, all at once)
- Streak break penalty (visual consequence)
- Leaderboard taunts (message under last place)
- Winner celebration (what a correct pick looks like)

---

## VI. Data Hygiene: The Long-Term Asset

**Core Principle:** Melee's aggregate prediction data is a strategic asset. Build clean data hygiene from day one so it's sellable in Phase 5.

### 6.1 All Picks Must be Timestamped

**Decision:** Every pick has `submitted_at` and `updated_at` timestamps. Never null.

**Why:** Required for submission timestamp tie-breaks, Activity Feed ordering, and data licensing later.

### 6.2 All Pick Changes Must be Recorded

**Decision:** `pick_history` table is the system of record for every change. Populated on every UPDATE to picks.

**Why:** Required for the "receipt" feature. Required for licensing prediction patterns to media/brands later.

### 6.3 Events Have Explicit Format Labels

**Decision:** `events.format` is a controlled vocabulary: `bracket`, `ballot`, `pickem`, `survival_pool`, `ranking`. Not free text.

**Why:** Data licensing requires consistent event categorization.

### 6.4 No Hard Deletes

**Decision:** Use soft deletes (`deleted_at` timestamp) on users, groups, events. Preserve historical pick data even if a user leaves.

**Why:** Historical data is the asset. Deleting it loses the record.

---

## VII. What Success Looks Like

### Phase 1 MVP (Two Event Types, One Friend Group)
- Two event formats working (Bracket + Ballot)
- Groups feature shipping (persistent friend circles, invite codes, group-scoped Chatter)
- AI event creation working (Host describes, AI scaffolds, Host confirms)
- Melee (the lacrosse tournament) migrated and working
- Oscars 2027 created as second event type, proving generalization
- All schema non-negotiables in place and tested
- Mobile-first on all critical screens
- Zero odds shown during pick selection
- Pick history visible after deadline
- Chatter persistent and accessible

### Phase 2 Beta (Two Friend Groups, Three Event Types)
- Second independent friend group using Melee
- Third event type shipped (Pick'em or Survival Pool)
- Polymarket integration for event discovery
- Host customization options shipped (elimination style, reveal mechanics)
- Group-scoped probability surfaced during spectating
- Phase 1 data validated: Chatter engagement rates, casual friend wins, pick diversity

### Phase 3 Open Beta (10+ Groups, 3+ Event Types)
- User-generated events launched
- Cross-event Group leaderboard live (all-time records)
- Public launch
- 10+ active groups across 3+ event types minimum

---

## VIII. Implementation Guardrails

**These apply to every Claude Code session:**

1. **Read this constitution at the start of every session.** If you're building a feature and you're unsure whether it's appropriate, check here first.

2. **Schema decisions first, always.** No application code before the schema is reviewed and signed off. The schema is the blueprint.

3. **Validate constantly.** After each phase, does the code match the constitution? Does it compile? Does it follow the schema? Does it reinforce or undermine the brand?

4. **Mobile first.** Every UI screen designed and QA'd on phone first. If it's awkward on mobile, it's not done.

5. **Group-scoped by default.** Any feature that involves user data defaults to being group-scoped. Picks are always `user + group + stage + contender`. Chatter is always `user + group + body`. No global leaderboards.

6. **No odds during picks.** This is the line. Full stop. Before you implement any feature that touches probability or odds, check the context. If it's during pick selection, it doesn't ship.

7. **Specs before code.** Use `/speckit.specify` before asking Claude Code to build. Clarity pays dividends.

---

## IX. When in Doubt

If you're building something and you're not sure whether it aligns with the constitution, ask these questions:

1. **Does this reinforce that Melee is game night, not gambling?** If not, reconsider.
2. **Does this work on a phone with one thumb?** If not, redesign.
3. **Does this keep picks as vibes, not math?** If not, defer or reframe.
4. **Does this enforce group-scoped data at the database level?** If not, rearchitect.
5. **Does the Host still feel like the DJ, not the referee?** If not, pull back the customization.
6. **Can this be tested against the schema rules and brand pillars?** If not, it's not clear enough to build.

---

**Constitution approved for development:** May 2026  
**Next review:** Phase 1 MVP completion  
**Maintainer:** Eric Hall (EHall4444)
