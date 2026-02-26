# Hodos Design

ὁδός (hodós) — the way, the path

## Ontological Purpose

Hodos addresses **the gap between knowing the destination and arriving there** — the mechanics of movement through structured experiences.

Without hodos:
- Journeys exist but navigation is ad-hoc
- Waypoint progression requires manual tracking
- Branching paths have no formal semantics
- Form validation is disconnected from journey flow

With hodos:
- **Navigation**: Get current position, advance, branch
- **State tracking**: Waypoint status, form data, branch history
- **Validation**: Form data checked against typos slots
- **Initialization**: Start onboarding and guided experiences

The central concept is **the way** — not the destination (nous defines that), but the mechanics of getting there.

## Oikos Context

### Self Oikos

A solitary dweller uses hodos to:
- Navigate through onboarding journey
- Progress through personal learning paths
- Track position in self-guided experiences
- Submit forms at waypoints

Personal navigation shapes the journey.

### Peer Oikos

Collaborators use hodos to:
- Coordinate shared journey progression
- Synchronize waypoint states across members
- Handle branching for different roles
- Validate collaborative form submissions

Peer navigation is synchronized movement.

### Commons Oikos

A commons uses hodos to:
- Define standard onboarding for new members
- Create multi-step workflows as journeys
- Monitor journey completion across community
- Analyze common paths and drop-off points

Commons navigation is patterned experience.

## Core Entities (Eide)

Hodos does not define its own eide. It operates on entities defined in nous:

### journey (from nous)

A teleological container — movement toward a desire.

**Fields used by hodos:**
- `current_waypoint` — ordinal of current position
- `status` — traveling, arrived, abandoned

### waypoint (from nous)

A consolidation point on a journey.

**Fields used by hodos:**
- `ordinal` — position in sequence
- `panel_id` — what to render at this waypoint
- `form_typos_id` — form definition if waypoint collects input
- `branches` — conditional next waypoints
- `status` — pending, active, reached, skipped

## Bonds (Desmoi)

Hodos uses bonds defined in nous:

### contains-waypoint (from nous)

Journey contains waypoints.

- **From:** journey
- **To:** waypoint
- **Traversal:** Get all waypoints for position lookup

## Operations (Praxeis)

### get-current-waypoint

Get the current waypoint for a journey.

- **When:** Rendering current journey state
- **Requires:** navigate attainment
- **Provides:** Waypoint entity, panel, form definition

Returns the waypoint at `journey.current_waypoint` ordinal along with associated panel and form data.

### advance-waypoint

Move to the next waypoint.

- **When:** User completes current waypoint
- **Requires:** navigate attainment
- **Provides:** New position, completion status

Marks current waypoint as reached, follows explicit `next` or increments ordinal.

### branch-waypoint

Take a conditional branch from current waypoint.

- **When:** Waypoint has branches and user selects one
- **Requires:** navigate attainment
- **Provides:** Branch target, new position

Evaluates branch conditions against action, navigates to matching target.

### validate-form

Validate form data against typos slots.

- **When:** Before advancing past form waypoint
- **Requires:** navigate attainment
- **Provides:** Validation result with errors

### start-onboarding

Initialize the onboarding journey.

- **When:** New user or explicit restart
- **Requires:** navigate attainment
- **Provides:** Current state (existing or newly embarked)

## Attainments

### attainment/navigate

Journey navigation capability — moving through waypoints.

- **Grants:** All hodos praxeis
- **Scope:** parousia
- **Rationale:** Navigation is per-parousia; each has their own position

## Embodiment

### Completeness Status

| Level | Status |
|-------|--------|
| Defined | 0 eide (uses nous), 6 praxeis, 1 attainment |
| Loaded | Bootstrap loads all definitions |
| Projected | All praxeis visible as MCP tools |
| Embodied | Partial — position sensing |
| Surfaced | Future — "You're on step 3 of 5" |
| Afforded | Future — next/back buttons |

### Body-Schema Contribution

When sense-body gathers hodos state:

```yaml
navigation:
  active_journeys: 1
  current_waypoint: 3
  total_waypoints: 7
  branches_available: 2
```

This reveals journey progress and available paths.

### Reconciler

A hodos reconciler would surface:

- **Progress blocked** — "Form validation failed at waypoint 3"
- **Journey stale** — "Onboarding started 7 days ago, not completed"
- **Branch point** — "Choose: create new or restore existing"

## Compound Leverage

### amplifies nous

Nous defines journeys and waypoints; hodos animates them. Without hodos, journeys are static structures.

### amplifies thyra

Thyra renders panels; hodos determines which panel to render at each waypoint. Navigation drives rendering.

### amplifies demiurge

Form data collected at waypoints feeds composition. Validated inputs become entity fields.

### amplifies politeia

Onboarding journeys create oikoi and assign attainments. Navigation is governance ceremony.

## Theoria

### T70: The way is distinct from the destination

Knowing where you're going (nous) and moving there (hodos) are separate concerns. Hodos provides the kinetics while nous provides the teleology. This separation enables reusable navigation over diverse journey types.

### T71: Navigation is personal

Each parousia has their own position on each journey. Scope: parousia reflects this — your progress is yours. Shared journeys with synchronized positions require explicit coordination.

### T72: Form validation belongs to navigation

Forms at waypoints are gates. Validation before advancement ensures data quality at the moment of movement. The path itself has structure.

---

*Composed in service of the kosmogonia.*
*The way opens. Position is known. Movement continues.*
