# Nous Design

νοῦς (nous) — mind, the faculty of understanding.

## Ontological Purpose

What gap in being does nous address?

**The gap between experience and understanding.** Without nous, events occur but nothing is learned. Data accumulates but insights never crystallize. The kosmos would be an amnesia machine — perceiving but never comprehending.

Nous provides:
- **Theoria** — crystallized understanding that persists and compounds
- **Inquiry** — open questions that drive exploration forward
- **Synthesis** — the bringing-together of multiple insights into higher understanding
- **Journeys** — teleological movement toward desired outcomes
- **Semantic search** — finding by meaning, not just structure

**What becomes possible:**
- Understanding compounds across sessions
- Questions drive discovery, answers create knowledge
- Multiple insights combine into deeper wisdom
- Goals become navigable paths with waypoints
- Knowledge is discoverable by meaning

## Oikos Context

### Sole Oikos

A solitary dweller uses nous to:
- Crystallize insights from their work into theoria
- Open inquiries when encountering the unknown
- Begin journeys toward personal goals
- Surface relevant knowledge by semantic proximity
- Navigate complex tasks through iterative reasoning

The sole oikos is where nous is most personal — your understanding, your questions, your journeys.

### Collective Oikos

Collaborators use nous to:
- Share crystallized theoria across the oikos
- Collaboratively answer inquiries with diverse perspectives
- Embark on shared journeys toward collective goals
- Synthesize individual insights into group understanding
- Surface knowledge relevant to the group's work

Understanding becomes shared — one person's insight becomes everyone's theoria.

### Commons Oikos

A community uses nous to:
- Build canonical knowledge bases (community theoria)
- Curate inquiries that the community cares about
- Define and track community-wide journeys
- Synthesize theoria from across contributors
- Enable semantic discovery of collective knowledge

The commons oikos is where nous becomes institutional memory — knowledge that outlives any individual contributor.

## Core Entities (Eide)

### theoria (defined in spora)

Crystallized understanding that persists.

**Fields:**
- `insight` — the understanding itself
- `domain` — area of knowledge
- `source` — where the understanding came from
- `status` — provisional, crystallized, superseded

**Lifecycle:**
1. **Crystallize** — insight captured as provisional theoria
2. **Confirm** — provisional becomes crystallized
3. **Supersede** — newer understanding replaces older

**Note:** Theoria is foundational, defined in spora.yaml. Nous provides operations on theoria.

### journey

A teleological container — movement toward a desire.

**Fields:**
- `desire` — what we're moving toward (the telos)
- `description` — extended explanation
- `status` — potential, active, paused, arrived, abandoned
- `current_waypoint` — where we are now
- `leverage_type` — how completion affects future work

**Lifecycle:**
1. **Begin** — journey created as potential
2. **Embark** — becomes active
3. **Progress** — waypoints reached
4. **Complete** — arrive at desire, or abandon

### waypoint

A consolidation point on a journey.

**Fields:**
- `journey_id` — parent journey
- `ordinal` — position (0-indexed)
- `description` — what this waypoint represents
- `status` — pending, reached
- `artifact_id` — optional artifact this waypoint yields

**Nature:** Waypoints mark progress. Reaching a waypoint may yield an artifact. Journeys complete when all waypoints are reached.

### inquiry

An open question driving understanding.

**Fields:**
- `question` — the question itself
- `domain` — area of inquiry
- `status` — open, exploring, answered, dissolved

**Lifecycle:**
1. **Open** — question posed
2. **Explore** — actively investigating
3. **Answer** — theoria satisfies the question
4. **Dissolve** — question becomes irrelevant

### synthesis

A bringing-together of multiple theoria.

**Fields:**
- `insight` — the synthesized understanding
- `sources` — theoria IDs that were combined
- `domain` — area of the synthesis

**Nature:** Synthesis creates new theoria from existing theoria, with explicit provenance to its sources.

## The Knowledge Ladder

Knowledge in kosmos forms a ladder of increasing stability and scope:

```
axiom (foundational truth — rarely changes, guides everything)
   ↑ rises to / ↓ grounds
principle (normative guidance — what should be done)
   ↑ rises to / ↓ guides
pattern (recurring structure — "when X, do Y")
   ↑ rises to / ↓ exemplifies
theoria (crystallized insight — from experience)
```

The ladder is bidirectional:
- **Rising:** Theoria that prove universally applicable may rise to pattern, then principle, rarely to axiom
- **Grounding:** Axioms ground principles, which guide patterns, which inform theoria creation

### axiom

Foundational truth — the bedrock upon which other knowledge stands.

**Fields:**
- `name` — short name (e.g., "Actuation = Emission")
- `statement` — the foundational truth as a clear, complete statement
- `rationale` — why this is foundational (not derived, but ground)
- `domain` — what domain this axiom grounds (constitution, development, methodology)
- `status` — provisional, established (changes require ceremony)

**Lifecycle:**
1. **Crystallize from theoria** — theoria proves so fundamental it rises
2. **Establish** — community confirms axiom status
3. **Supersede** — rarely, new axiom replaces (constitutional change)

**Nature:** Axioms are what agents surface when facing decisions. "Options indicate missing theoria" but when an axiom applies, there is one right way.

### principle

Normative guidance — what should be done.

**Fields:**
- `name` — short name
- `guidance` — the normative statement
- `rationale` — why this is the right approach
- `domain` — area of application
- `status` — provisional, established
- `grounded_in` — axiom IDs this principle realizes

**Lifecycle:**
1. **Crystallize from pattern** — pattern becomes prescriptive
2. **Establish** — confirmed through repeated application
3. **Supersede** — better principle emerges

**Nature:** Principles are normative — they say what SHOULD be done, not just what IS.

### pattern

Recurring structure — "when you see X, do Y".

**Fields:**
- `name` — short name (e.g., "Phylax Pattern")
- `description` — what this pattern is
- `structure` — the essential form (often a sequence)
- `when` — recognition trigger
- `example` — concrete instance
- `status` — provisional, established
- `grounded_in` — principle or axiom IDs this pattern realizes

**Lifecycle:**
1. **Crystallize from theoria** — multiple theoria reveal same shape
2. **Establish** — pattern proves reliable
3. **Supersede** — better pattern emerges

**Nature:** Patterns are enacted — they describe structure that works. Theoria instantiate patterns.

## Bonds (Desmoi)

### crystallized-in
- **From:** theoria
- **To:** oikos
- **Cardinality:** many-to-one
- **Traversal:** Where was this theoria crystallized?

### inquires
- **From:** prosopon
- **To:** inquiry
- **Cardinality:** one-to-many
- **Traversal:** Who asked this? What has this prosopon asked?

### answers
- **From:** theoria
- **To:** inquiry
- **Cardinality:** many-to-one
- **Traversal:** What theoria answers this inquiry?

### synthesizes
- **From:** synthesis
- **To:** theoria
- **Cardinality:** many-to-many
- **Traversal:** What theoria fed this synthesis?

### supersedes
- **From:** theoria
- **To:** theoria
- **Cardinality:** many-to-one
- **Traversal:** What newer understanding replaced this?

### supports / contradicts
- **From:** theoria
- **To:** theoria
- **Cardinality:** many-to-many
- **Traversal:** How do theoria relate to each other?

### evidences
- **From:** any entity
- **To:** theoria
- **Cardinality:** many-to-many
- **Traversal:** What evidence supports this understanding?

### Knowledge Ladder Bonds

### grounds
- **From:** axiom, principle
- **To:** principle, pattern
- **Cardinality:** one-to-many
- **Traversal:** What does this axiom/principle ground? What grounds this pattern/principle?

### rises-to
- **From:** theoria, pattern, principle
- **To:** pattern, principle, axiom
- **Cardinality:** many-to-one
- **Traversal:** What did this knowledge rise from? What rose from this?

### exemplifies
- **From:** theoria
- **To:** pattern
- **Cardinality:** many-to-many
- **Traversal:** What pattern does this theoria exemplify? What theoria exemplify this pattern?

### contains-waypoint
- **From:** journey
- **To:** waypoint
- **Cardinality:** one-to-many
- **Traversal:** What waypoints does this journey have?

### journeys-toward
- **From:** journey
- **To:** intention
- **Cardinality:** many-to-one
- **Traversal:** What intention does this journey serve?

## Operations (Praxeis)

### Theoria Operations

#### crystallize-theoria
Capture understanding as provisional theoria.
- **When:** Insight emerges worth preserving
- **Effect:** Theoria created, indexed for semantic search
- **Gated by:** `attainment/crystallize`

#### confirm-theoria
Mark provisional theoria as crystallized.
- **When:** Understanding validated through use
- **Gated by:** `attainment/crystallize`

#### supersede-theoria
Replace older understanding with newer.
- **When:** Better understanding emerges
- **Effect:** New theoria created, old marked superseded
- **Gated by:** `attainment/crystallize`

#### list-theoria
List theoria by domain or status.
- **When:** Reviewing knowledge

### Inquiry Operations

#### open-inquiry
Pose a new question.
- **When:** Encountering the unknown
- **Gated by:** `attainment/inquire`

#### answer-inquiry
Answer an inquiry with theoria.
- **When:** Understanding satisfies a question
- **Gated by:** `attainment/inquire`

#### synthesize
Combine multiple theoria into higher understanding.
- **When:** Patterns emerge across insights
- **Gated by:** `attainment/inquire`

### Journey Operations

#### begin-journey
Start a new journey toward a desire.
- **When:** Goal identified
- **Gated by:** `attainment/journey`

#### embark-journey
Transition journey from potential to active.
- **Gated by:** `attainment/journey`

#### add-waypoint
Add consolidation point to a journey.
- **Gated by:** `attainment/journey`

#### reach-waypoint
Mark a waypoint as reached.
- **Gated by:** `attainment/journey`

#### complete-journey / abandon-journey
End a journey (successfully or not).
- **Gated by:** `attainment/journey`

#### list-journeys / get-journey-waypoints
Query journey state.

### Knowledge Ladder Operations

#### crystallize-axiom
Create a foundational truth from elevated principle/theoria.
- **When:** Understanding proves so fundamental it becomes ground truth
- **Effect:** Axiom created, indexed for surfacing during decisions
- **Gated by:** `attainment/constitute` (rare capability)

#### crystallize-principle
Create normative guidance from elevated pattern/theoria.
- **When:** Pattern becomes prescriptive ("you should do this")
- **Effect:** Principle created, bonded to grounding axiom
- **Gated by:** `attainment/crystallize`

#### crystallize-pattern
Create recurring structure from multiple related theoria.
- **When:** Same shape appears across different theoria
- **Effect:** Pattern created, existing theoria bonded as instantiating it
- **Gated by:** `attainment/crystallize`

#### elevate-to-pattern / elevate-to-principle / elevate-to-axiom
Move knowledge up the ladder.
- **When:** Knowledge proves more fundamental than initially thought
- **Effect:** New entity created at higher level, `rises-to` bond created
- **Gated by:** `attainment/crystallize` (or `constitute` for axiom)

#### surface-guidance
Surface axioms, principles, patterns relevant to a decision.
- **When:** Agent faces a choice and wants "one right way"
- **Returns:** Ordered list of applicable guidance from the ladder

#### list-axioms / list-principles / list-patterns
Query knowledge ladder entities by domain or status.

### Discovery Operations

#### surface
Find entities by semantic proximity to a query.
- **When:** Searching by meaning

#### surface-journeys
Find relevant journeys for a query.

#### find / gather / traverse
Structural discovery and navigation.

#### index / index-functions
Add entities to semantic index.
- **Requires:** use-embedding-api credential

### Activation Operations

#### invoke
Activate chora-nous via composed invocation.
- **When:** Need LLM reasoning integrated with kosmos
- **Gated by:** `attainment/invoke`

#### navigate
Multi-step reasoning via iterative invocation.
- **When:** Complex goal requires multiple steps
- **Gated by:** `attainment/invoke`

#### call-praxis
Invoke any praxis by ID.
- **When:** Meta-operations needed
- **Gated by:** `attainment/invoke`

## Attainments

### attainment/crystallize
**Capability:** Create and manage theoria, patterns, and principles — the lifecycle of understanding.
**Gates:** `crystallize-theoria`, `confirm-theoria`, `supersede-theoria`, `crystallize-pattern`, `crystallize-principle`, `elevate-to-pattern`, `elevate-to-principle`
**Scope:** oikos

### attainment/constitute
**Capability:** Create and manage axioms — foundational truths. Rare capability, typically only in kosmos-dev oikoi.
**Gates:** `crystallize-axiom`, `elevate-to-axiom`
**Scope:** oikos (restricted to constitutional oikoi)

### attainment/inquire
**Capability:** Open inquiries and create syntheses — questioning and combining.
**Gates:** `open-inquiry`, `answer-inquiry`, `synthesize`
**Scope:** oikos

### attainment/journey
**Capability:** Create and manage journeys — teleological navigation.
**Gates:** `begin-journey`, `embark-journey`, `add-waypoint`, `reach-waypoint`, `complete-journey`, `abandon-journey`
**Scope:** oikos

### attainment/invoke
**Capability:** Activate nous via invocation — LLM integration.
**Gates:** `invoke`, `navigate`, `call-praxis`
**Scope:** oikos

## Embodiment

### Completeness Status

| Level | Status |
|-------|--------|
| Defined | eide, desmoi, praxeis exist in YAML |
| Loaded | Bootstrap loads into kosmos.db |
| Projected | MCP projects praxeis as tools |
| Embodied | Body-schema reflects capabilities |
| Surfaced | Reconciler notices when actions are relevant |
| Afforded | Thyra UI presents contextual actions |

### Body-Schema Contribution

When `sense-body` runs, nous contributes:

```yaml
body-schema:
  understanding:
    theoria_count: 42
    recent_domains: ["kosmos", "chora", "ontology"]
    active_journeys: 3
    pending_inquiries: 5
  capabilities:
    - name: crystallize
      available: "$has_attainment(crystallize)"
      topos: nous
    - name: surface
      available: "$has_credential(use-embedding-api)"
      topos: nous
  pending_actions:
    - action: answer_inquiry
      reason: "3 inquiries open in current domain"
      when: "$pending_inquiries > 0"
    - action: reach_waypoint
      reason: "Active journey at waypoint 2"
      when: "$active_journeys > 0"
```

### Reconciler

```yaml
reconciler/nous-understanding:
  trigger: on-dwell
  sense: |
    - Check for open inquiries in dwelling oikos
    - Check for active journeys needing progress
    - Check for provisional theoria awaiting confirmation
    - Check for related theoria to surface
  surface: |
    - If inquiries open: suggest answering
    - If journey active: suggest next waypoint
    - If theoria provisional for long: suggest confirm/supersede
```

## Compound Leverage

### Amplifies Other Topoi

| Topos | How Nous Amplifies |
|-------|-------------------|
| **soma** | Perception feeds understanding. Body-schema includes understanding state. |
| **psyche** | Intentions connect to journeys. Mood influences what surfaces. |
| **politeia** | Attainments gate understanding operations. Governance informed by theoria. |
| **manteia** | Generation guided by theoria context. Yields crystallize into understanding. |
| **demiurge** | Composition informed by relevant theoria. Design decisions become theoria. |

### Cross-Topos Patterns

1. **Perceive → Crystallize → Surface**
   Experience becomes understanding becomes discoverable knowledge.
   Example: Debug session → insight about bug → theoria → surfaces when similar bug encountered.

2. **Intention → Journey → Theoria**
   What we want becomes a path becomes captured understanding.
   Example: Form intention to learn X → journey with waypoints → theoria from each waypoint.

3. **Generate → Validate → Crystallize**
   LLM generates → human validates → understanding persists.
   Example: Manteia generates proposal → user refines → confirmed theoria.

## Theoria

New theoria crystallized during this design:

### T30: Understanding compounds through explicit capture

Knowledge that isn't crystallized is lost. Theoria makes understanding persistent and discoverable. The act of crystallization itself deepens understanding.

### T31: Questions are first-class entities

Inquiries aren't just queries — they're entities that persist, drive exploration, and eventually connect to answers. A good question is as valuable as a good answer.

### T32: Journeys make goals navigable

A desire without waypoints is just a wish. Journeys decompose goals into achievable steps. Each waypoint is both a checkpoint and a celebration.

### T33: Semantic proximity enables serendipitous discovery

Finding by meaning, not just structure, enables finding what you didn't know you were looking for. The embedding space is a landscape of related understanding.

---

*Nous is the mind that remembers, questions, synthesizes, and navigates. Without nous, the kosmos experiences but never understands. With nous, understanding compounds and wisdom emerges from the accumulation of crystallized insight.*
