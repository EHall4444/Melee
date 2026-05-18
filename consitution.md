WHAT WORKS — Validated Decisions
	

What Works captures decisions that have been made and assumptions that have been validated — through the accidental beta or deliberate product reasoning. Each decision includes the rationale and the risk if the assumption is wrong.


Validated by the beta
Decision
	Validated assumption
	Risk if wrong
	Supabase as backend
	Production-ready at friend-group scale. Free tier covers MVP. Proven in beta.
	Schema migration is painful if not done right the first time.
	Chatter as core feature
	Most-used feature after picks in beta. Social layer drives more engagement than the event.
	Moderation becomes a problem at scale. Not an MVP concern.
	AI-assisted development
	Full beta built in days with no traditional coding. Viable for MVP build.
	Complex architectural decisions (schema, RLS) still require careful human judgment.
	

Decided by design reasoning — documented in Brief v1.2
Decision
	Rationale
	Risk if wrong
	Group-scoped picks at DB level from day one
	Privacy enforced at DB level via Supabase RLS. Retrofitting later is costly and risky.
	Slightly more complex schema upfront. Worth it.
	Confidence staking removed
	Conflicts with Melee’s ethos: certainty, stubbornness, blind allegiance. No one says “I’m 87% confident.”
	Removes a potential engagement signal. Revisitable in Phase 3.
	Open beta: public launch, no waitlist
	Maximum user data is more valuable than controlled rollout. Network effects require scale.
	Harder to manage quality without controlled rollout. Acceptable trade-off.
	Host Pro as Phase 4 monetization lead
	Directly monetizes the person who gets the most value. Everyone else plays free.
	Willingness to pay unvalidated until meaningful user base exists.
	Staggered pick reveal (not simultaneous)
	Progressive revelation creates drama. Each reveal is a social moment, not a data dump.
	More complex to build. Requires careful UX design.
	Host customization as Phase 2
	Phase 1 ships with opinionated defaults. Customization is an option, never a requirement.
	Defaults must be good enough to carry Phase 1 without customization.
	Platform nomenclature: domain-neutral throughout
	Stage/Contender/Outcome works across sports, Oscars, Survivor. Format-specific labels defined by Host per-Melee.
	Unfamiliar terms may confuse early users. Mitigated by clear UI labels.
	AI event creation uses user-provided source domain
	Asking ‘who hosts this event?’ is natural and gives AI a clean starting point. Host reviews draft before anything goes live.
	AI may produce incorrect structures for niche events. Review step is the guardrail.
	Polymarket integration deferred to Phase 2
	Too complex for MVP. Phase 1 AI creation must be architected with Polymarket data model in mind.
	Missing event discovery in Phase 1. Acceptable given MVP constraints.
	Aggregate data as Phase 5 revenue hypothesis
	Prediction data at scale is valuable to media, brands, and betting markets. Requires clean data hygiene from day one.
	Speculative until meaningful scale. Long-term play only.
	Groups use user-defined names
	The identity of the group is theirs. ‘The Infallible Ones’ carries more personality than any system label.
	No risk. Pure upside.
	Multi-group mental model: Host is the unit of loyalty
	Each person has multiple friend groups with different interests. Group composition is event-dependent. The Host running multiple Melees across different groups is multiple acquisition events per year, each reaching new people.
	If Hosts burn out from setup burden, multi-group model fails. AI event creation must be genuinely fast — under 5 minutes.
	Chatter must be persistent and accessible from every screen
	Host found Chatter buried at the bottom of the tab. The impulse to trash talk fires in a moment and dies if Chatter requires navigation. Design mandate, not a preference.
	Increases mobile layout complexity. Solve with floating action button or persistent bottom nav. Do not defer.
	Spectator mode: invite-only read-only access
	Formalizes observed ‘app shown to outsider’ viral behavior. Spectators see leaderboard, bracket, and Chatter. Cannot submit picks or post Chatter. Converts observers into future Hosts or participants.
	Spectator scope must be strictly read-only at MVP. Any write access creates a two-tier participation problem.
	

Open questions — to be resolved in Phase 1
Question
	Status
	Notes
	Pick reveal timing: staggered or immediate?
	✅ Resolved
	Picks visible immediately on submission. Pre-event transparency drives Chatter. The deadline is the lock, not a reveal. Last-minute pick changes are the mind game.
	Result entry UX: Host-only or group suggestion + Host confirm?
	✅ Resolved
	Host-only at MVP. Group suggestion + Host confirm is Phase 2. AI auto-results is also Phase 2.
	Host customization: per-Melee or per-Group standing preference?
	✅ Resolved
	Per-Melee. The tone of an Oscars ballot differs from an NFL bracket. Host sets the culture of each specific Melee.
	Comment edit function?
	✅ Resolved
	No edit. By design. Your words stand. Confirmation step before posting is the UX solution.
	Tie-break method?
	✅ Resolved
	Host selects at event creation: Prop Question (default), Submission Timestamp, or Closest to the Pin. All fully automatic. Watch closely in Phase 1 beta.
	Melee vs betting positioning?
	✅ Resolved
	Melee is the anti-bet. Brand pillar: communal, social stakes, game night. Polymarket referenced only as event structure data source — no betting association.
	AI event creation fallback: niche events the AI can’t scaffold?
	📋 Open
	Host fills in the blanks after AI scaffolds what it can. Fallback UX needs design in Phase 1.
	Cross-event leaderboard: when does it launch?
	📋 Open
	Requires at least two completed Melees in the same Group. Phase 3 target. Schema must support it from day one.
	Chatter vs. text: is persistent Chatter enough to activate in the moment?
	Bet placed
	Melee bets on context and permanence over feature parity. Validate in MVP beta — watch whether Chatter engagement rises when surfaced persistently everywhere.
	Spectator mode: scope and rollout timing?
	Open
	Invite-only, read-only at MVP. No picks, no Chatter posting. Rollout with Groups feature. Watch whether spectators convert to participants in next Melees.
	B2B/media partnership: when is consumer traction strong enough?
	Open
	Phase 4+ opportunity. Need a behavior story: users who played one Melee averaged X more within six months. Start with mid-tier media partner. Major network is the inbound goal, not the cold pitch.
	
