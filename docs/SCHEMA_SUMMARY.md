# Melee Core Schema — Implementation Summary

**Status:** Ready for review and Supabase deployment  
**Version:** 1.0 | May 2026  
**Terminology:** Updated to use "Maker" instead of "Host"

---

## What You Have

Three files ready to go into your Melee repo:

1. **`melee_core_schema.sql`** — Complete PostgreSQL schema with all tables, constraints, and indexes
2. **`SCHEMA_TERMINOLOGY.md`** — Unified language guide (Maker, Melee, Group, Picks, Stages, Contenders, etc.)
3. **`melee_constitution.md`** — Updated to reflect "Maker" terminology throughout

---

## Key Changes from Your Clarifications

### 1. Automated Outcomes (Not Host Manual Entry)

**Decision:** Results are auto-fetched from authoritative sources (ESPN, Academy Awards, etc.). Maker only manually enters **prop question answers**, not main event outcomes.

**Why:** Removes operational burden from Maker. Automates scoring. Reduces error.

**Schema impact:**
- `outcomes` table has a `source` field: "auto_fetched", "manual", or "system"
- Phase 1 still allows manual entry as fallback
- Phase 2 implements auto-fetch from official APIs

### 2. "Maker" Not "Host"

**All terminology updated:**
- `melees.created_by` = the Maker
- Maker has no special powers except scoring prop questions
- Maker is transient — anyone can create a Melee
- Flat hierarchy — anyone in a Group can create a Melee

### 3. Multiple Prop Questions Per Melee

**Schema supports:**
- One or more `prop_questions` per Melee
- Each prop question has multiple answer options
- Users make `prop_picks` (answers) per prop question, group-scoped
- Maker manually scores prop questions after the event

### 4. Group-Scoped Everything

**Core principle enforced at DB level:**
```sql
picks: (user_id, group_id, stage_id, contender_id)
prop_picks: (prop_question_id, user_id, group_id)
comments: (melee_id, group_id, user_id, body)
activity_feed: (melee_id, group_id, user_id, activity_type)
```

All group-scoped data is queryable only by group members (via Supabase RLS).

### 5. Soft Deletes (Non-Negotiable)

**Soft delete on:**
- `users`, `groups`, `melees`, `group_members`

**Hard delete on:**
- Everything else (stages, contenders, outcomes, picks, comments, etc.)

**Why:** Preserve historical pick data. Never lose the record of a past Melee.

---

## Tables at a Glance

| Table | Purpose | Scope |
|-------|---------|-------|
| `users` | User accounts | Global (Supabase Auth) |
| `groups` | Persistent friend circles | User creates, invites others |
| `group_members` | Membership join table | Group + user pairing |
| `melees` | Competitions/events | Per-group |
| `stages` | Units of competition | Recursive hierarchy (max 3 levels) |
| `contenders` | Options within a Stage | Per-stage |
| `contender_assets` | Images, metadata for contenders | Per-contender |
| `picks` | User selections | **Group-scoped** — one pick per user per stage per group |
| `pick_history` | Change log for picks | **Group-scoped** — visible after deadline |
| `outcomes` | Results of Stages | Melee-level |
| `prop_questions` | Side quest questions | Per-Melee (multiple) |
| `prop_picks` | User answers to prop questions | **Group-scoped** |
| `comments` (Chatter) | Social feed | **Group-scoped** |
| `reactions` | Thumbs up/down | Per-comment |
| `activity_feed` | Real-time log of actions | **Group-scoped** |
| `spectators` | Read-only observers | Per-Melee, invite-only |

---

## Group-Scoped Queries (Examples)

These are the queries that will run constantly. The schema is optimized for them:

```sql
-- Get all picks in a Melee for members of a Group
SELECT p.* FROM picks p
WHERE p.melee_id = $1 AND p.group_id = $2;

-- Get a user's picks across all Stages in a Melee
SELECT p.* FROM picks p
WHERE p.user_id = $1 AND p.melee_id = $2 AND p.group_id = $3;

-- Get Chatter for a Melee visible to Group members
SELECT c.* FROM comments c
WHERE c.melee_id = $1 AND c.group_id = $2
ORDER BY c.created_at DESC;

-- Get Activity Feed for a Group (pick submissions and changes)
SELECT af.* FROM activity_feed af
WHERE af.group_id = $1 AND af.melee_id = $2
ORDER BY af.created_at DESC;

-- Get a user's prop picks for a Melee
SELECT pp.* FROM prop_picks pp
WHERE pp.user_id = $1 AND pp.melee_id = $2 AND pp.group_id = $3;
```

All of these hit indexed columns for fast query performance.

---

## How to Deploy

1. **Copy schema file to your repo:**
   ```bash
   cp ~/melee_core_schema.sql ~/Documents/Melee/schema.sql
   ```

2. **Review in Supabase SQL editor:**
   - Open your Supabase project
   - Paste the entire schema file into the SQL editor
   - Click "Run" to create all tables and indexes

3. **Set up RLS policies in Supabase:**
   - For `picks`: Users can only query picks from Groups they belong to
   - For `comments`: Users can only query comments from Groups they belong to
   - For `prop_picks`: Users can only query from Groups they belong to
   - For `activity_feed`: Users can only query from Groups they belong to
   - (See schema comments for example RLS policy for `picks`)

4. **Test locally (optional, before deployment):**
   ```bash
   psql -U postgres -d melee_dev < schema.sql
   ```

---

## What's NOT in Phase 1 Schema

These tables will be added in Phase 2+:

- `event_sources` — Mapping of event types to authoritative data sources
- `api_integrations` — Configuration for auto-fetching results
- `audit_log` — Who did what, when (compliance)
- `error_log` — Failed API calls, malformed data
- `user_preferences` — Communication settings, notification preferences
- `feature_flags` — Gradual rollout of features

---

## Non-Negotiable Constraints (Enforced)

1. ✅ **Group-scoped picks at DB level** — `UNIQUE(user_id, group_id, stage_id)`
2. ✅ **pick_history exists from day one** — Every pick change recorded
3. ✅ **Recursive stages via parent_id** — Max 3 nesting levels
4. ✅ **Soft deletes on groups, events, users** — Preserve history
5. ✅ **Timestamps on all tables** — created_at, updated_at
6. ✅ **Contender assets separate** — Scalable asset management
7. ✅ **Multiple prop questions per Melee** — Side quests baked in
8. ✅ **Outcomes auto-fetch ready** — Source field supports automated results

---

## Next Steps

1. **Review this schema** with Jeff's team
2. **Deploy to Supabase** (can be done in 10 minutes)
3. **Write Phase 1 feature specs** — Groups, AI event creation, Bracket, Ballot
4. **Create `/speckit.plan`** — Turns specs into technical blueprint with detailed schema per feature

This schema is the foundation. Everything else gets built on top of it.

