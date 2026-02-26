# Tutorial: Your First Phasis

*A hands-on walkthrough of the phasis lifecycle — from draft to durable contribution.*

---

## What You'll Learn

By the end of this tutorial, you will:
1. Understand the accumulation → commit → phasis lifecycle
2. Create a phasis via the `logos/emit-phasis` praxis
3. Reply to a phasis and navigate threads
4. List phaseis in an oikos with filtering

---

## Prerequisites

- Development environment running (`just dev`)
- MCP server running or Claude Code connected
- Familiarity with [Your First Praxis](first-praxis.md)

---

## Step 1: Understand the Lifecycle

Phaseis are the durable unit of discourse in kosmos. They follow a three-stage lifecycle:

```
draft content → accumulation buffer → COMMIT → durable phasis
                     ↑                   ↑
               reversible          commitment boundary
                                   (the send moment)
```

**Before commit:** Content lives in the `accumulation/default` entity — ephemeral, editable, clearable.

**After commit:** Content becomes a `phasis` entity — durable, bonded to an oikos, threaded.

In Thyra (the UI), the commitment boundary is the "send" button. Via MCP, you skip the accumulation buffer and create phaseis directly.

---

## Step 2: Create Your First Phasis

Call the `logos/emit-phasis` praxis:

```
Tool: mcp__kosmos__nous_call-praxis
praxis_id: logos/emit-phasis
params:
  content: "Hello, kosmos. This is my first phasis."
  stance: declaration
```

You should receive a response with:
- `phasis_id` — a unique ID like `phasis/1738...`
- `authored_by` — your prosopon ID
- `oikos_id` — the current oikos
- `stance` — `declaration`

The phasis is now a durable entity in the graph, bonded to your oikos via `phasis-in`.

---

## Step 3: Verify the Phasis Exists

Find your phasis by ID:

```
Tool: mcp__kosmos__nous_find
id: <your phasis_id from Step 2>
```

You'll see the full entity:

```yaml
id: phasis/1738...
eidos: phasis
data:
  content: "Hello, kosmos. This is my first phasis."
  authored_by: prosopon/victor
  oikos_id: oikos/kosmos
  expressed_at: 1738...
  source_kind: direct
  stance: declaration
  content_type: text/plain
```

---

## Step 4: List Phaseis in Your Oikos

```
Tool: mcp__kosmos__nous_call-praxis
praxis_id: logos/list-phaseis
params:
  limit: 10
```

This lists all phaseis in your current oikos, sorted by `expressed_at` descending. You should see your phasis in the results.

---

## Step 5: Reply to Your Phasis

Create a reply:

```
Tool: mcp__kosmos__nous_call-praxis
praxis_id: logos/reply-to
params:
  phasis_id: <your phasis_id from Step 2>
  content: "And this is my first reply."
  stance: declaration
```

This creates a new phasis bonded to your first phasis via `in-reply-to`.

---

## Step 6: Navigate the Thread

Get the conversation thread:

```
Tool: mcp__kosmos__nous_call-praxis
praxis_id: logos/get-thread
params:
  phasis_id: <your reply phasis_id from Step 5>
  direction: ancestors
```

With `direction: ancestors`, you'll get the parent chain from your reply up to the root phasis. Try `direction: both` to see ancestors and descendants together.

---

## Step 7: Try Different Stances

Phaseis carry intentionality through stances. Create an inquiry:

```
Tool: mcp__kosmos__nous_call-praxis
praxis_id: logos/emit-phasis
params:
  content: "What are the five archai?"
  stance: inquiry
```

Now filter by stance:

```
Tool: mcp__kosmos__nous_call-praxis
praxis_id: logos/list-phaseis
params:
  stance: inquiry
  limit: 5
```

Only inquiries appear. Stances available: `declaration`, `inquiry`, `suggestion`, `invitation`, `request`, `proposal`.

---

## Step 8: Topos-Sourced Phaseis

Topoi can speak too. When a topos emits a phasis, it uses `source_kind: topos`:

```
Tool: mcp__kosmos__nous_call-praxis
praxis_id: logos/emit-phasis
params:
  content: "Bootstrap completed successfully."
  source_kind: topos
  source_topos_id: ergon
  stance: declaration
```

This creates a phasis attributed to the ergon topos rather than a prosopon. The `source_topos_id` field provides provenance.

---

## What You've Learned

1. **Lifecycle** — Phaseis are durable entities created through the commitment boundary
2. **emit-phasis** — Creates phaseis with content, stance, and provenance
3. **reply-to** — Creates threaded conversations via `in-reply-to` bonds
4. **get-thread** — Navigates conversation threads by following bond chains
5. **list-phaseis** — Filters by oikos, speaker, stance
6. **Stances** — Phaseis carry intentionality that enables appropriate responses
7. **Topos expressions** — Any topos can speak into an oikos

---

## Next Steps

- Read [Phasis Entity Reference](../../reference/domain/phasis-entity.md) for the complete schema
- Read [Commitment Boundary](../../explanation/architecture/commitment-boundary.md) for the conceptual framing
- Read [Phasis Workspace](../../reference/domain/phasis-workspace.md) for the accumulation buffer
- Try [Voice Authoring](../../how-to/presentation/voice-authoring.md) for the voice-to-phasis pipeline
