# Feature Specification: Core Data Schema

**Feature Branch**: `002-core-db-schema`

**Created**: 2026-05-18

**Status**: Draft

**Input**: User description: "--file DATABASE_FEATURE_BRIEF.md --context schema/melee_core_schema.sql --decisions docs/MELEE_CRITICAL_DECISIONS_v1.md --constitution .specify/melee_constitution.md"

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Data Privacy Across Groups (Priority: P1)

A user belongs to two Groups: "The Infallible Ones" (Oscars) and "Lacrosse Crew" (NCAA bracket). Each group makes independent picks. No member of either group can see the other group's picks, scores, or activity — even if a single user is in both.

**Why this priority**: Privacy is the foundational guarantee of Melee. If a user's picks in one Group leak to another, the product is broken. This cannot be retrofitted.

**Independent Test**: Create two groups with one shared user. Make picks in Group A. Verify that a member of Group B (who is not in Group A) cannot see those picks. Delivers core privacy guarantee.

**Acceptance Scenarios**:

1. **Given** a user belongs to two Groups, **When** they submit picks in Group A, **Then** those picks are visible only to Group A members and invisible to Group B members
2. **Given** a user queries the picks for a Melee, **When** they are not a member of the relevant Group, **Then** the query returns no results
3. **Given** two Groups are playing the same Melee event, **When** members view the leaderboard, **Then** each group sees only their own members' picks and scores

---

### User Story 2 — Pick Change Accountability (Priority: P1)

A user submits their Oscar picks on Sunday morning, then changes Best Picture from "Conclave" to "Anora" two hours before the deadline. After the deadline, all Group members can see that the user changed their pick — what they changed from, what they changed to, and when.

**Why this priority**: "The receipts" is a core social mechanic that drives Chatter and accountability. Pick history cannot be reconstructed retroactively. It must exist from the first pick ever made.

**Independent Test**: Submit a pick, change it once, then verify the change log shows old/new values with timestamps. Directly validates the accountability mechanic.

**Acceptance Scenarios**:

1. **Given** a user submits a pick, **When** they change that pick before the deadline, **Then** the system records the old pick, new pick, and exact time of the change
2. **Given** a pick has been changed, **When** the deadline passes, **Then** all Group members can see the full change history for that pick
3. **Given** a user changes a pick multiple times, **When** the deadline passes, **Then** each individual change appears in history with correct before/after values and timestamps

---

### User Story 3 — Data Durability and Soft Deletes (Priority: P2)

A Group has played six Melees together over two years. One member leaves the Group and later deletes their account. All historical pick data, scores, and Chatter from those six Melees remains intact and queryable. The departed member's picks still count in historical results.

**Why this priority**: Historical data is Melee's long-term strategic asset. Losing it on user/group deletion undermines both the product (group history) and the future data licensing opportunity.

**Independent Test**: Delete a group member and verify all historical Melee data, picks, and scores remain intact. Validates data preservation guarantee.

**Acceptance Scenarios**:

1. **Given** a user is removed from a Group, **When** historical Melee results are queried, **Then** that user's historical picks and scores remain in the record
2. **Given** a user deletes their account, **When** past Melee results are queried, **Then** their historical picks and outcomes are preserved (account appears as deleted/anonymous)
3. **Given** a Group is soft-deleted, **When** historical data is queried by an admin, **Then** all Melees, picks, and outcomes for that Group remain accessible

---

### User Story 4 — Cross-Event Group Leaderboard Readiness (Priority: P3)

After 10 Melees across two years, a Group can view an all-time leaderboard showing each member's total wins, losses, and correct picks across all events — Oscars, NCAA brackets, Survivor seasons — without any data migration.

**Why this priority**: The all-time Group leaderboard is a Phase 3 feature, but the schema must support it from day one. It cannot be retrofitted without migrating all historical picks.

**Independent Test**: Query picks across multiple Melees for a single Group and compute a total correct-pick count per user. Verifies the query is possible without schema changes.

**Acceptance Scenarios**:

1. **Given** a Group has completed multiple Melees of different formats, **When** an all-time leaderboard query is run, **Then** it returns correct aggregated scores per member without schema changes
2. **Given** picks are group-scoped from creation, **When** cross-event queries are run, **Then** picks from different groups never contaminate each other's results

---

### Edge Cases

- What happens when a user submits a pick and then the Melee is cancelled? (Picks and history are preserved under the soft-deleted Melee)
- How does the system handle a user who is in 10+ Groups simultaneously? (Each Group's data is fully independent; no cross-contamination)
- What happens if a pick is changed back to the original value? (Both changes are recorded in pick_history regardless)
- How are tie-breaking scenarios handled when two users have identical pick scores? (Submission timestamp from picks.submitted_at is the tiebreaker)
- What happens if the same stage exists in two different Melees? (Stages are Melee-scoped; no collision possible)

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST store every pick with both a user reference and a group reference, enforced at the data layer — not just the application layer
- **FR-002**: System MUST enforce that each user can have only one active pick per stage per group (no duplicate picks)
- **FR-003**: System MUST record every pick change in a separate history log with the previous value, new value, and exact timestamp — populated on every change from the first pick ever made
- **FR-004**: System MUST restrict access to group-scoped data (picks, comments, activity, prop picks) so only members of that group can query it
- **FR-005**: System MUST support stage hierarchies with at least three levels of nesting (stage → sub-stage → matchup) for event formats such as brackets and survival pools
- **FR-006**: System MUST use soft deletes for users, groups, melees, and group memberships — preserving all historical pick data even after deletion
- **FR-007**: System MUST timestamp every pick at creation and update — these timestamps must never be null
- **FR-008**: System MUST support multiple Melees per group and multiple groups per user, each fully independent
- **FR-009**: System MUST support multiple prop questions per Melee, each with group-scoped answers
- **FR-010**: System MUST support a contender asset model (images, metadata) that is separate from the contender record itself
- **FR-011**: System MUST support spectator access to a Melee via a unique invitation token, without granting group membership
- **FR-012**: System MUST support outcome recording for each stage, with a source field that distinguishes manual entry from automated fetch

### Key Entities

- **User**: A registered platform participant. Has a profile (display name, avatar). Belongs to one or more Groups.
- **Group**: A persistent friend circle. Has a name, invite code, creator, and streak count. The primary unit of social competition.
- **Group Member**: The relationship between a User and a Group. Records when the user joined. Supports soft delete.
- **Melee**: A competition event tied to a Group. Has a title, format, pick deadline, and status. Created by a Maker (any Group member).
- **Stage**: A unit of competition within a Melee. Supports recursive parent/child nesting. Has ordering and scoring weight.
- **Contender**: An option within a Stage that users pick from. Has a title, optional seed, and optional metadata.
- **Contender Asset**: Media (images) or structured metadata attached to a Contender. Stored separately for scalability.
- **Pick**: A user's selection of a Contender for a Stage, scoped to a Group. Unique per user + group + stage.
- **Pick History**: An immutable log of every pick change. Records old and new Contender, timestamp, and all scoping keys.
- **Outcome**: The recorded result for a Stage — which Contender won. Has a source field.
- **Prop Question**: A side-quest question attached to a Melee, with multiple-choice options.
- **Prop Pick**: A user's answer to a Prop Question, group-scoped.
- **Comment (Chatter)**: A group-scoped social message tied to a Melee. No editing after posting.
- **Reaction**: A thumbs-up or thumbs-down on a Comment.
- **Activity Feed**: A real-time log of actions (pick submissions, changes) within a Group's Melee.
- **Spectator**: A read-only observer invited to a specific Melee via email and token, without Group membership.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A user's picks in one Group are completely inaccessible to members of a different Group — verifiable by attempting a cross-group pick query that returns zero results
- **SC-002**: Every pick change is recorded in full (who, from what, to what, when) — no pick change is ever untracked from the first pick made in the system
- **SC-003**: Deleting a user or group does not remove any historical pick, score, or outcome data — all historical queries return identical results before and after deletion
- **SC-004**: All four Phase 1 event formats (Bracket, Ballot, Pick'em, Survival Pool) can be represented using the existing stage/contender model without schema changes
- **SC-005**: A cross-event all-time Group leaderboard can be computed by querying existing data — no migration required when this feature is built in Phase 3
- **SC-006**: All pick queries return results in under 2 seconds for Groups with up to 20 members playing a Melee with up to 64 stages

## Assumptions

- The Melee core schema (melee_core_schema.sql) is the authoritative definition of all data entities — this spec validates the schema satisfies functional requirements
- Row-level security is enforced at the data layer (not just application code), using Supabase's built-in access control mechanisms
- Phase 1 event formats are Bracket and Ballot; Pick'em and Survival Pool are Phase 2 but the schema must support them without changes
- Auto-fetching of outcomes from external sources (ESPN, Academy Awards) is a Phase 2 capability; Phase 1 uses manual entry as fallback
- The `spectators` table provides read-only Melee access without Group membership — spectators cannot make picks or post Chatter
- All tables receive `created_at` and `updated_at` timestamps; soft-deleted tables additionally receive `deleted_at`
- The initial Melee event (lacrosse tournament) is the migration target that will validate the schema in production
