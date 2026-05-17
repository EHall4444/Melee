-- MELEE CORE SCHEMA
-- PostgreSQL / Supabase
-- Version 1.0 | May 2026
-- 
-- Non-negotiable architectural decisions:
-- 1. Picks are group-scoped at DB level: (user_id, group_id, stage_id, contender_id)
-- 2. pick_history exists from day one — every pick change is recorded
-- 3. Stage hierarchy is recursive via parent_id — supports all event formats
-- 4. Domain-neutral naming throughout (stages, contenders, outcomes)
-- 5. Cross-event Group leaderboard supported from schema day one
-- 6. Soft deletes on users, groups, events, group_members; hard deletes elsewhere
-- 7. Timestamps on all tables (created_at, updated_at)

-- ============================================================================
-- USERS
-- ============================================================================
-- Managed by Supabase Auth; this table provides supplemental data
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email VARCHAR(255) NOT NULL UNIQUE,
  display_name VARCHAR(255),
  avatar_url VARCHAR(500),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP WITH TIME ZONE DEFAULT NULL
);

-- ============================================================================
-- GROUPS
-- ============================================================================
-- Persistent friend circles. Users belong to multiple Groups.
-- Group composition is event-dependent (Maker invites different people per Melee).
CREATE TABLE IF NOT EXISTS groups (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  invite_code VARCHAR(20) NOT NULL UNIQUE,
  created_by UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  streak_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP WITH TIME ZONE DEFAULT NULL
);

CREATE INDEX idx_groups_invite_code ON groups(invite_code);
CREATE INDEX idx_groups_created_by ON groups(created_by);

-- ============================================================================
-- GROUP MEMBERS
-- ============================================================================
CREATE TABLE IF NOT EXISTS group_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id UUID NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP WITH TIME ZONE DEFAULT NULL,
  UNIQUE(group_id, user_id)
);

CREATE INDEX idx_group_members_user_id ON group_members(user_id);
CREATE INDEX idx_group_members_group_id ON group_members(group_id);

-- ============================================================================
-- MELEES
-- ============================================================================
CREATE TABLE IF NOT EXISTS melees (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title VARCHAR(255) NOT NULL,
  format VARCHAR(50) NOT NULL,
  group_id UUID NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
  created_by UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  pick_deadline TIMESTAMP WITH TIME ZONE NOT NULL,
  event_start TIMESTAMP WITH TIME ZONE,
  status VARCHAR(50) DEFAULT 'draft',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP WITH TIME ZONE DEFAULT NULL
);

CREATE INDEX idx_melees_group_id ON melees(group_id);
CREATE INDEX idx_melees_created_by ON melees(created_by);
CREATE INDEX idx_melees_status ON melees(status);
CREATE INDEX idx_melees_pick_deadline ON melees(pick_deadline);

-- ============================================================================
-- STAGES
-- ============================================================================
CREATE TABLE IF NOT EXISTS stages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  melee_id UUID NOT NULL REFERENCES melees(id) ON DELETE CASCADE,
  parent_id UUID REFERENCES stages(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  stage_order INTEGER NOT NULL DEFAULT 0,
  scoring_weight DECIMAL(5,2) DEFAULT 1.0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_stages_melee_id ON stages(melee_id);
CREATE INDEX idx_stages_parent_id ON stages(parent_id);
CREATE INDEX idx_stages_melee_order ON stages(melee_id, stage_order);

-- ============================================================================
-- CONTENDERS
-- ============================================================================
CREATE TABLE IF NOT EXISTS contenders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  stage_id UUID NOT NULL REFERENCES stages(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  seed INTEGER,
  metadata JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_contenders_stage_id ON contenders(stage_id);

-- ============================================================================
-- CONTENDER ASSETS
-- ============================================================================
CREATE TABLE IF NOT EXISTS contender_assets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  contender_id UUID NOT NULL REFERENCES contenders(id) ON DELETE CASCADE,
  asset_type VARCHAR(50) NOT NULL,
  asset_url VARCHAR(500),
  asset_data JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_contender_assets_contender_id ON contender_assets(contender_id);

-- ============================================================================
-- PICKS
-- ============================================================================
CREATE TABLE IF NOT EXISTS picks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  group_id UUID NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
  melee_id UUID NOT NULL REFERENCES melees(id) ON DELETE CASCADE,
  stage_id UUID NOT NULL REFERENCES stages(id) ON DELETE CASCADE,
  contender_id UUID NOT NULL REFERENCES contenders(id) ON DELETE CASCADE,
  submitted_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, group_id, stage_id)
);

CREATE INDEX idx_picks_user_group ON picks(user_id, group_id);
CREATE INDEX idx_picks_stage ON picks(stage_id);
CREATE INDEX idx_picks_melee ON picks(melee_id);
CREATE INDEX idx_picks_submitted_at ON picks(submitted_at);

-- ============================================================================
-- PICK HISTORY
-- ============================================================================
CREATE TABLE IF NOT EXISTS pick_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pick_id UUID NOT NULL REFERENCES picks(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  group_id UUID NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
  melee_id UUID NOT NULL REFERENCES melees(id) ON DELETE CASCADE,
  stage_id UUID NOT NULL REFERENCES stages(id) ON DELETE CASCADE,
  old_contender_id UUID REFERENCES contenders(id) ON DELETE SET NULL,
  new_contender_id UUID NOT NULL REFERENCES contenders(id) ON DELETE CASCADE,
  changed_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_pick_history_pick_id ON pick_history(pick_id);
CREATE INDEX idx_pick_history_user_id ON pick_history(user_id);
CREATE INDEX idx_pick_history_group_id ON pick_history(group_id);
CREATE INDEX idx_pick_history_changed_at ON pick_history(changed_at);
CREATE INDEX idx_pick_history_melee ON pick_history(melee_id);

-- ============================================================================
-- OUTCOMES
-- ============================================================================
CREATE TABLE IF NOT EXISTS outcomes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  stage_id UUID NOT NULL UNIQUE REFERENCES stages(id) ON DELETE CASCADE,
  melee_id UUID NOT NULL REFERENCES melees(id) ON DELETE CASCADE,
  winner_contender_id UUID NOT NULL REFERENCES contenders(id) ON DELETE CASCADE,
  entered_by UUID NOT NULL REFERENCES users(id) ON DELETE SET NULL,
  entered_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  source VARCHAR(100),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_outcomes_stage_id ON outcomes(stage_id);
CREATE INDEX idx_outcomes_melee_id ON outcomes(melee_id);
CREATE INDEX idx_outcomes_entered_at ON outcomes(entered_at);

-- ============================================================================
-- PROP QUESTIONS
-- ============================================================================
CREATE TABLE IF NOT EXISTS prop_questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  melee_id UUID NOT NULL REFERENCES melees(id) ON DELETE CASCADE,
  question_text VARCHAR(500) NOT NULL,
  options JSONB NOT NULL,
  correct_option VARCHAR(255),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_prop_questions_melee_id ON prop_questions(melee_id);

-- ============================================================================
-- PROP PICKS
-- ============================================================================
CREATE TABLE IF NOT EXISTS prop_picks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  prop_question_id UUID NOT NULL REFERENCES prop_questions(id) ON DELETE CASCADE,
  melee_id UUID NOT NULL REFERENCES melees(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  group_id UUID NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
  answer VARCHAR(255) NOT NULL,
  submitted_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(prop_question_id, user_id, group_id)
);

CREATE INDEX idx_prop_picks_user_group ON prop_picks(user_id, group_id);
CREATE INDEX idx_prop_picks_question ON prop_picks(prop_question_id);
CREATE INDEX idx_prop_picks_melee ON prop_picks(melee_id);

-- ============================================================================
-- CHATTER (COMMENTS)
-- ============================================================================
CREATE TABLE IF NOT EXISTS comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  melee_id UUID NOT NULL REFERENCES melees(id) ON DELETE CASCADE,
  group_id UUID NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  body TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_comments_group_id ON comments(group_id);
CREATE INDEX idx_comments_melee_id ON comments(melee_id);
CREATE INDEX idx_comments_user_id ON comments(user_id);
CREATE INDEX idx_comments_created_at ON comments(created_at);

-- ============================================================================
-- REACTIONS
-- ============================================================================
CREATE TABLE IF NOT EXISTS reactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  comment_id UUID NOT NULL REFERENCES comments(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  vote INTEGER NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(comment_id, user_id)
);

CREATE INDEX idx_reactions_comment_id ON reactions(comment_id);
CREATE INDEX idx_reactions_user_id ON reactions(user_id);

-- ============================================================================
-- ACTIVITY FEED
-- ============================================================================
CREATE TABLE IF NOT EXISTS activity_feed (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  melee_id UUID NOT NULL REFERENCES melees(id) ON DELETE CASCADE,
  group_id UUID NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  activity_type VARCHAR(50) NOT NULL,
  payload JSONB,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_activity_feed_group_id ON activity_feed(group_id);
CREATE INDEX idx_activity_feed_melee_id ON activity_feed(melee_id);
CREATE INDEX idx_activity_feed_created_at ON activity_feed(created_at);

-- ============================================================================
-- SPECTATORS
-- ============================================================================
CREATE TABLE IF NOT EXISTS spectators (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  melee_id UUID NOT NULL REFERENCES melees(id) ON DELETE CASCADE,
  group_id UUID NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
  invited_by UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  spectator_email VARCHAR(255) NOT NULL,
  invite_token VARCHAR(255) NOT NULL UNIQUE,
  accessed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_spectators_melee_id ON spectators(melee_id);
CREATE INDEX idx_spectators_invite_token ON spectators(invite_token);

-- ============================================================================
-- INDEXES FOR PERFORMANCE
-- ============================================================================
CREATE INDEX idx_picks_group_melee ON picks(group_id, melee_id);
CREATE INDEX idx_comments_group_melee ON comments(group_id, melee_id);
CREATE INDEX idx_prop_picks_group_melee ON prop_picks(group_id, melee_id);
CREATE INDEX idx_picks_user_melee ON picks(user_id, melee_id);
CREATE INDEX idx_outcomes_winner ON outcomes(winner_contender_id);
