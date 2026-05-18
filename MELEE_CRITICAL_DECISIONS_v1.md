# MELEE — Critical Decisions Locked

**Status:** May 17, 2026  
**Owner:** Eric  
**Format:** Decisions Locked | Open Questions | Architecture Implications

---

## 1. SCORING LOGIC — LOCKED ✅

**Decision:** 1 point per correct pick. **Universal across all groups, subgroups, and stages.**

**Rationale:** 
- Simple. Understandable. No edge cases.
- Scales to cross-group competition (Melee groups battling other Melee groups)
- Future-proofs the product

**Architecture implication:**
- All Stages worth equal scoring weight (no weighting by round/category)
- Prop questions do NOT add to score; they are tiebreakers only
- Scoring formula is: `correct_picks_count / total_stages`

**Applied to:**
- Single Melee ranking
- Cross-Melee Group leaderboard (all-time)
- Cross-Group ranking (future)

---

## 2. LEADERBOARD RANKING — LOCKED ✅

**Decision:** Two-tier leaderboard system.

### Tier 1: Single Melee (Primary)
- Players ranked **within a single Melee** by number of correct picks
- Scope: Per-Group only
- Visibility: Accessible to all Group members during and after event

### Tier 2: Cross-Melee Group Leaderboard (All-Time)
- Players ranked **across all Melees within the same friend Group**
- Calculation: Total correct picks / Total stages played across all Group Melees
- Scope: Per-Group only
- Visibility: Accessible to all Group members
- **This is Group identity.** "The Infallible Ones are 47-52 across Melees" becomes part of group history.
- **Stickiness driver:** Players care about their record with THIS group, not global ranking (yet)

### Tier 3: Cross-Group Global Ranking (Future, Design Required)
- Players ranked across all Groups they belong to
- **Problem:** How do you express this in terms that matter to others?
  - Win %? (wins = Melees where you placed 1st?)
  - Total correct picks across all Melees? (unfair if some groups play 2 Melees/year, others play 20)
  - Elo-style rating? (based on difficulty of competition in each group?)
- **Parking for Phase 4+.** Needs more thinking. Not MVP.

**Rationale for two-tier structure:**
- Phase 1 & 2 focus: Group loyalty. Your record with YOUR people.
- Phase 3+: Opt-in global leaderboard (if players want bragging rights across groups).
- Avoids "casual browser finds Melee, sees they're ranked 50,000th globally" demoralization.

---

## 3. GROUP MEMBERSHIP & INVITE CHANNEL — OPEN 🔴

**The Problem You Identified:**

You have a core 7-person horse racing group that wants to compete across 6 events in a year. By event 4, someone's friend invites a rando who "doesn't ruin the vibe but throws off the odds." Now:
- Group composition is contaminated
- Historical leaderboard is meaningless (different people in different events)
- Social accountability is diluted

**Why "anyone can join with the code" breaks here:**
- The code is meant to be private (shared in a text thread, Discord, etc.)
- But one person can blurt it out to anyone
- You can't uninvite without conflict
- You can't retroactively remove them from past Melees

**Current architecture assumption:** Flat hierarchy. Anyone in the Group can create a Melee. No "owner" with special powers.

---

### Option A: Hard Closure (Strict)
**Description:** Once a Group is created, **no new members can join after N Melees or after a deadline.**

**Mechanism:**
- Group has `locked_at` timestamp
- Before lock: Group is "open" — anyone with code can join
- After lock: Group is "closed" — no new members, period
- Maker can still invite people to the next Melee (creates a new Group)

**Pros:**
- Preserves historical leaderboard purity
- Keeps core group intact for all-time record
- Clear rules

**Cons:**
- Inflexible. What if you want to add your partner mid-season?
- Fragmentation: 7 people + 1 rando = need a new Group (messy)
- Not social. Feels punitive to exclude people.

---

### Option B: Versioned Groups (Flexible + Accountable)
**Description:** Groups have **versions/seasons**. New members start a new season; past seasons locked forever.

**Mechanism:**
- Group `v1` runs 4 Melees with 7 people
- Person invites a rando to Melee 5
- System creates `Group v2` automatically (or Maker chooses to version)
- Rando and whoever invited them are in `v2`
- Original 7 can stay in `v2` or not (optional carry-forward)
- All-time leaderboard calculated per version
- **Version history is preserved** — "The Infallible Ones v1 (7 people, 4 Melees): 47-52"

**Pros:**
- Doesn't punish groups for growing
- Historical data is clean per version
- Maker can control who carries forward
- Stickiness: "we're trying to beat our v1 record"

**Cons:**
- More complex schema (`group_version_id` on Melees)
- UI complexity (showing version history)
- Requires Maker decision-making

---

### Option C: Member Tenure + Eligibility (Hybrid)
**Description:** Players are ranked within a Melee based on **how long they've been in the Group.**

**Mechanism:**
- Track `member_joined_at` on `group_members`
- Rando joins on Melee 4
- Rando's picks count for the Melee leaderboard (they participated)
- But on the **Group all-time leaderboard**, rando only counts for Melees 4, 5, 6 (not 1-3)
- Original 7 have a separate "core member" all-time record if desired

**Pros:**
- Doesn't require closing or versioning
- Core group can see their "founders" record
- Rando doesn't feel excluded; they're ranked within their tenure

**Cons:**
- Complex leaderboard logic
- Confusing UX (multiple rankings per person per group)
- Doesn't solve the "vibe" problem

---

### Option D: Explicit Group Settings (Maker Control)
**Description:** When creating a Group, Maker sets the **invite policy**.

**Policies:**
1. **Open:** Anyone can join anytime (current behavior)
2. **Closed after X Melees:** After 4 events, no new members
3. **Closed after date:** After June 1, no new members
4. **Owner-only:** Only Maker can add people (defeats flat hierarchy, but clear)
5. **Invite-list:** Maker provides a list of allowed emails; only those people can join

**Pros:**
- Maker has agency without creating new entities
- Scales: some groups want growth, others don't
- Clear expectations

**Cons:**
- More options = more complexity
- "Owner-only" breaks flat hierarchy ethos
- Enforce mechanism is unclear

---

## WHAT NEEDS TO HAPPEN NOW

### 🔴 **Before MVP Build**

You need to decide: **Which invite channel model fits Melee's philosophy?**

The core tension:
- **Flat hierarchy + trust model** (current Melee ethos) assumes friends won't sabotage each other
- **But reality:** One person WILL invite their annoying friend; groups WILL fragment
- **Design question:** Do you enforce rules (closure, versioning, policies) or trust social pressure (Maker/group can kick people out)?

**My recommendation:** Start with **Option B (Versioned Groups)** for Phase 1.

**Why:**
- Preserves historical data integrity (groups stay pure per version)
- Doesn't require closing/locking (flexible for growing groups)
- Stickiness comes from "beat our v1 record"
- Schema change is minimal (`group_version_id` on melees table)
- Maker decides when to version (when vibe breaks, new member joins, etc.)

**Schema implication:**
```sql
ALTER TABLE groups ADD COLUMN version INTEGER DEFAULT 1;
ALTER TABLE melees ADD COLUMN group_version_id UUID;
-- Unique constraint: (group_id, version, melee_id)
```

---

## 4. CROSS-GROUP BATTLE (Future, Design Deferred)

**Locked:** Melee groups will be able to battle other Melee groups using the same 1-point-per-correct-pick scoring.

**Open for Phase 4+:**
- How are "Melee group vs Melee group" matches structured? (Head-to-head on same event? Separate events? Aggregate scores?)
- How are cross-group rankings expressed? (Win %, Elo rating, total points?)
- Is it opt-in or automatic?
- Privacy: Can a group see other groups' picks?

**Not blocking MVP.** Just keep the 1-point system clean so it scales.

---

## SUMMARY: What's Locked for Build

| Question | Answer | Impact |
|----------|--------|--------|
| Scoring | 1 point per correct pick, universal | All rankings, all tiers |
| Single Melee ranking | Ranked within Melee per Group | Primary leaderboard |
| Cross-Melee ranking | All-time record per Group | Group identity / stickiness |
| Cross-Group ranking | Deferred to Phase 4+ | Global leaderboard future |
| Invite channel | **Versioned Groups (recommendation)** | Schema change: add version to groups/melees |
| Group closure | **Maker decides when to version** | No hard locks; trust soft boundaries |

---

## NEXT STEP: Validate Versioned Groups

Before locking this in your constitution and schema:

1. **Does versioned groups feel right to you?** Or does one of the other options fit better?
2. **When does a Group get versioned?** 
   - Maker manually decides? ("Start a new season")
   - Automatic when someone new joins? (heavy-handed)
   - Explicit threshold? ("Version when group size > N" or "after M Melees")
3. **Can a Group reverse-merge versions?** (If the rando leaves, go back to v1?)

Once you're locked, I'll update:
- Schema with `group_version_id`
- Constitution with "Versioned Groups" policy
- Ontology with leaderboard calculation rules

