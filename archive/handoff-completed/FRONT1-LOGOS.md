# Front 1: Wire Logos Into Every Topos

**Status:** COMPLETE — All topoi wired. See full listing below.

## Goal

Make the kosmos conversational. Every significant state change should emit a phasis through `logos/emit-phasis`, so the discourse layer comes alive when reflexes fire.

This is pure YAML authoring — adding `call` steps to existing praxeis. No chora changes needed.

## The Pattern

Logos DESIGN.md (genesis/logos/DESIGN.md) defines the integration pattern:

```yaml
# Add as a final step in praxeis that produce meaningful state changes:
- step: call
  praxis: logos/emit-phasis
  params:
    content: "Crystallized: $theoria.insight"
    stance: declaration
    source_kind: topos
    metadata:
      source_eidos: theoria
      source_id: "$theoria.id"
```

**Phasis fields:**
- `content` (string, required): Human-readable description of what happened
- `stance` (enum): declaration, inquiry, suggestion, invitation, request, proposal
- `source_kind`: Use `topos` for system-emitted phaseis
- `metadata` (object): Include `source_eidos` and `source_id` for traceability

**Stances by event type:**
- State changes (created, resolved, completed) → `declaration`
- Drift detected, health issues → `declaration` (with warning tone in content)
- Pending approvals, entry requests → `request`
- Pattern suggestions, clustering recommendations → `suggestion`

## Topoi to Wire

Work through each topos's praxeis file. For each, identify which praxeis produce meaningful state changes and add an emit-phasis call step. Read the praxeis file first to understand the step flow and available bindings.

### nous — `genesis/nous/praxeis/nous.yaml` ✅
- `crystallize-theoria` → "Crystallized theoria: {insight}" (declaration)
- `complete-inquiry` → "Inquiry resolved: {question}" (declaration)
- `complete-synthesis` → "Synthesis complete: {title}" (declaration)

### ergon — `genesis/ergon/praxeis/ergon.yaml` ✅
- `resolve-pragma` → "Pragma resolved: {title}" (declaration)
- `create-pragma` → "New pragma: {title}" (declaration)

### oikos — `genesis/oikos/praxeis/oikos.yaml` ✅
- `crystallize-insight` → "Insight crystallized: {content}" (declaration)
- `surface-insight` → "Insight surfaced: {content}" (declaration)

### propylon — `genesis/propylon/praxeis/propylon.yaml` ✅
- `request-entry` → "Entry requested via {link_id}" (request)
- `approve-entry` → "Entry approved for {prosopon}" (declaration)

### politeia — `genesis/politeia/praxeis/politeia.yaml` ✅
- `accept-invitation` → "Joined oikos: {oikos_name}" (declaration)
- `grant-attainment` → "Attainment granted: {attainment} to {prosopon}" (declaration)

### dynamis — `genesis/dynamis/praxeis/dynamis.yaml` ✅
- `reconcile-deployment` → "Deployment reconciled: {deployment_id}" (declaration)
- Drift detection results → "Drift detected: {description}" (declaration)

### release — `genesis/release/praxeis/release.yaml` ✅
- `build-release` → "Release built: {name} v{version}" (declaration)
- `distribute-release` → "Release distributed: {name} to {channel}" (declaration)

### ekdosis — `genesis/ekdosis/praxeis/ekdosis.yaml` ✅
- `publish-topos` → "Topos published: {topos_id}" (declaration)

### agora — `genesis/agora/praxeis/agora.yaml` ✅
- `begin-gathering` → "Gathering started in {territory}" (declaration)
- `end-gathering` → "Gathering ended in {territory}" (declaration)

### hodos — `genesis/hodos/praxeis/hodos.yaml` ✅
- `advance-waypoint` → "Advanced journey to waypoint {ordinal}" (declaration)
- `branch-waypoint` → "Branched journey via '{action}' to waypoint {ordinal}" (declaration)

### credentials — `genesis/credentials/praxeis/credentials.yaml` ✅
- `store-credential` → "Stored credential for {service}" (declaration)
- `unlock-credential` → "Unlocked credential {id}" (declaration)
- `delete-credential` → "Deleted credential {id}" (declaration)

### psyche — `genesis/psyche/praxeis/psyche.yaml` ✅
- `form-intention` → "Formed intention: {description}" (declaration)
- `activate-intention` → "Activated intention {id}" (declaration)
- `fulfill-intention` → "Fulfilled intention {id}" (declaration)
- `abandon-intention` → "Abandoned intention {id}" (declaration)
- `disclose-mood` → "Mood disclosed: {quality}" (declaration)
- `foresee` → "Foreseen: {description}" (declaration)
- `recognize-kairos` → "Kairos recognized: {description}" (declaration)

### soma — `genesis/soma/praxeis/soma.yaml` + `membership.yaml` ✅
- `arise-parousia` → "Parousia {id} has arisen" (declaration)
- `depart-parousia` → "Parousia {id} has departed" (declaration)
- `register-node` → "Registered node {name} ({kind})" (declaration)
- `register-service` → "Registered service {name} on node {id}" (declaration)
- `join-oikos` → "Joined oikos {id}" (declaration)
- `leave-oikos` → "Left oikos {id}" (declaration)

### aither — `genesis/aither/praxeis/aither.yaml` ✅
- `connect-signaling` → "Connected to signaling relay for room {id} as {role}" (declaration)
- `ensure-connection` (when created) → "Established syndesmos connection for room {id}" (declaration)

### hypostasis — `genesis/hypostasis/praxeis/hypostasis.yaml` ✅
- `export-phoreta` → "Exported phoreta bundle ({count} entities)" (declaration)
- `import-phoreta` → "Imported phoreta bundle ({count} entities)" (declaration)
- `create-snapshot` → "Created snapshot of oikos ({count} entities)" (declaration)
- `begin-genesis-ceremony` → "Genesis ceremony begun for {id} (threshold: {n})" (declaration)
- `add-genesis-signature` → "Signature added to genesis {id} ({n} of {threshold})" (declaration)
- `finalize-genesis` → "Genesis {id} finalized with {n} signatures" (declaration)
- `add-credential` → "Added credential for {service}" (declaration)
- `remove-credential` → "Removed credential for {service}" (declaration)

### dokimasia — `genesis/dokimasia/praxeis/dokimasia.yaml` ✅
- `validate-generation` → "Validated generation {id}: {passed}" (declaration)

### demiurge — `genesis/demiurge/praxeis/demiurge.yaml` ✅
- `compose-topos-dev` → "Composed topos-dev {id} v{version}" (declaration)
- `bake-topos` → "Baked topos {id} ({n} generations)" (declaration)
- `publish-topos` → "Published topos {id}" (declaration)
- `actualize-eidos` → "Actualized eidos {id} from artifact" (declaration)
- `actualize-praxis` → "Actualized praxis {id} from artifact" (declaration)
- `actualize-desmos` → "Actualized desmos {id} from artifact" (declaration)

### thyra — `genesis/thyra/praxeis/thyra.yaml` ✅
- `open-stream` → "Opened {kind} stream ({direction})" (declaration)
- `close-stream` → "Closed stream {id}" (declaration)
- `switch-mode` → "Switched mode from {from} to {to}" (declaration)
- `switch-config` → "Switched to thyra config {id}" (declaration)

### genesis — `genesis/genesis/praxeis/genesis.yaml` ✅
- `emit-genesis` (when !dry_run) → "Emitted genesis to {path}" (declaration)
- `emit-topos` → "Emitted topos '{name}' to genesis" (declaration)

### Skipped (no state-changing praxeis)
- **manteia** — all praxeis are generation/query focused, no meaningful state changes
- **stoicheia-portable** — has no praxeis directory

## How to Do It

For each topos:

1. **Read** the praxeis file to understand the step flow and variable bindings
2. **Identify** which praxeis produce meaningful state changes (not reads/queries)
3. **Add** a `call` step near the end (after the entity is created/updated, before the return)
4. **Use** the correct variable bindings from the praxis scope (check what `bind_to` names are used)
5. **Include metadata** with `source_eidos` and `source_id` for every phasis

## Important

- Don't add emit-phasis to read-only praxeis (list-*, get-*, find-*)
- Don't add emit-phasis to internal/helper praxeis
- The call step should be AFTER the main operation succeeds (so we don't announce failures)
- Use switch/when to gate phasis emission on success conditions if needed
- Content should be human-readable, not technical
- Keep content concise — one sentence describing what happened

## Verification

After adding, check that:
- Every `call` step references `logos/emit-phasis` (correct praxis ID)
- Params include `content`, `stance`, `source_kind: topos`
- Variable references (`$variable`) match actual bindings in the praxis scope
- No emit-phasis calls on read-only praxeis
