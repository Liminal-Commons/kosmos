# Topos Design: chora-dev

*Full oikos validation — kosmos orchestrating its own substrate development.*

---

## Implementation Status

| Component | Status | Location |
|-----------|--------|----------|
| **Manifest** | ✅ Complete | `genesis/chora-dev/manifest.yaml` |
| **Eide** | ✅ Complete | `genesis/chora-dev/eide/chora-dev.yaml` |
| **Desmoi** | ✅ Complete | `genesis/chora-dev/desmoi/chora-dev.yaml` |
| **Typos** | ✅ Complete | `genesis/chora-dev/typos/chora-dev.yaml` |
| **Stoicheia specs** | ✅ Complete | `genesis/chora-dev/stoicheia/cargo.yaml` |
| **Command templates** | ✅ Complete | `genesis/chora-dev/entities/command-templates.yaml` |
| **Praxeis** | ✅ Complete | `genesis/chora-dev/praxeis/chora-dev.yaml` |
| **Panels** | ✅ Complete | `genesis/chora-dev/entities/panels.yaml` |
| **Render-specs** | ✅ Complete | `genesis/chora-dev/entities/render-specs.yaml` |
| **Reflexes** | ✅ Complete | `genesis/chora-dev/entities/reflexes.yaml` |
| **Commands** | ✅ Complete | `genesis/chora-dev/entities/commands.yaml` |
| **Ergon integration** | ✅ Complete | `genesis/chora-dev/entities/ergon-integration.yaml` |
| **Tier 3 Rust impl** | ⏳ Pending | 4 generic stoicheia — see [Handoff](#handoff-tier-3-stoicheia-implementation) |

**Journey:** `journey/chora-dev-topos-implementation` — completed with 15 waypoints reached.

---

## Purpose

**Gap addressed:** Chora development (Rust builds, tests, deployments) happens outside kosmos. Build state, test results, and deployment status are not graph-traversable. The system cannot reason about or manage its own implementation lifecycle.

**Solution:** `topos/chora-dev` makes substrate development homoiconic — build targets, test runs, and source crates become entities with bonds. Kosmos can then orchestrate cargo builds, track artifact freshness via content hashes, and reconcile deployments of itself.

**Scale:** topos (development tooling)

---

## Core Insight: Full Circle Validation

```
┌─────────────────────────────────────────────────────────────────────┐
│                           KOSMOS                                    │
│                                                                     │
│   source-crate/kosmos-mcp ──builds-into──► build-target/release    │
│          │                                        │                 │
│          │                                  tests-against           │
│          │                                        │                 │
│          │                               test-run/kosmos-mcp        │
│          │                                        │                 │
│          └──────────────► deployment/kosmos-mcp-local              │
│                                   │                                 │
│                            targets-node                             │
│                                   ↓                                 │
│                           node/personal-mac                         │
│                                   │                                 │
│                            hosts-service                            │
│                                   ↓                                 │
│                      service-instance/kosmos-mcp                    │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
                                   │
                                   │ actualizes in
                                   ↓
┌─────────────────────────────────────────────────────────────────────┐
│                            CHORA                                    │
│                                                                     │
│   cargo build ←── manifest (mode/cargo-build)                      │
│   cargo test  ←── manifest (mode/cargo-test)                       │
│   ./target/   ←── sense (check binary hash)                        │
│   process     ←── manifest (mode/process)                          │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

The circle closes: kosmos describes builds → chora executes them → kosmos deploys the result → chora runs kosmos → which orchestrates the next build.

---

## Dependencies (Reuse, Don't Reinvent)

| Topos | What It Provides | How chora-dev Uses It |
|-------|------------------|----------------------|
| **dynamis** | `deployment`, `reconciler`, actuality modes, `targets-node` desmos | Process lifecycle for built artifacts |
| **release** | `release`, `release-artifact`, `distribution-channel` | Version tracking, artifact distribution |
| **dokimasia** | `validation-result`, linting praxeis | Validate praxeis before deployment |
| **soma** | `node`, `service-instance`, `hosts-service` desmos | Infrastructure targets for deployment |
| **ergon** | `reconciler`, `daemon` | Automated reconciliation and file watching |
| **nous** | `theoria`, semantic indexing | Knowledge capture and surfacing |
| **thyra** | notifications, UI affordances | User-facing alerts and interactions |
| **opsis** | panels, render-specs | Visualization of build state |

**Principle:** chora-dev focuses on *build-time* concerns. Runtime deployment uses dynamis. Distribution uses release.

---

## Eide (Entity Types)

### source-crate

A Rust crate in the chora workspace. Represents source code that can be built.

```yaml
eidos: source-crate
description: |
  A Rust crate in the chora workspace. Source of truth for what can be built.
  Discovered via `cargo metadata` or registered manually.

fields:
  name:
    type: string
    required: true
    description: "Crate name (e.g., 'kosmos-mcp')"

  path:
    type: string
    required: true
    description: "Path relative to workspace root (e.g., 'crates/kosmos-mcp')"

  crate_type:
    type: enum
    values: [bin, lib, proc-macro]
    required: true
    description: "What kind of crate"

  workspace_dependencies:
    type: array
    required: false
    description: "Other source-crate IDs this depends on"

  source_hash:
    type: string
    required: false
    description: "BLAKE3 hash of source files (for staleness detection)"

  last_scanned_at:
    type: timestamp
    required: false
```

### build-target

A compiled artifact from a source crate. Has an actuality mode for cargo build.

```yaml
eidos: build-target
description: |
  A compiled artifact from cargo build. Tracks the relationship between
  source and binary, enabling staleness detection and rebuild orchestration.

fields:
  crate_name:
    type: string
    required: true
    description: "Source crate name"

  profile:
    type: enum
    values: [dev, release, test]
    default: dev
    required: true
    description: "Cargo build profile"

  target_triple:
    type: string
    default: "host"
    required: false
    description: "Target architecture (e.g., 'x86_64-apple-darwin')"

  artifact_path:
    type: string
    required: false
    description: "Path to built artifact relative to target/"

  content_hash:
    type: string
    required: false
    description: "BLAKE3 hash of built binary"

  source_hash:
    type: string
    required: false
    description: "Source hash at build time (for staleness)"

  built_at:
    type: timestamp
    required: false

  duration_ms:
    type: integer
    required: false
    description: "Build duration in milliseconds"

  build_status:
    type: enum
    values: [pending, building, succeeded, failed, stale]
    default: pending
    required: true

  error_message:
    type: string
    required: false
    description: "Compilation error if build_status is failed"

actuality:
  mode: cargo-build
  note: "Manifest runs cargo build; sense checks binary hash"
```

### test-run

A test execution against a build target.

```yaml
eidos: test-run
description: |
  A test execution record. Tracks test runs for CI/CD integration
  and historical analysis. Can be reconciled to re-run tests.

fields:
  test_filter:
    type: string
    required: false
    description: "Test filter pattern (empty = all tests)"

  status:
    type: enum
    values: [pending, running, passed, failed, skipped]
    default: pending
    required: true

  passed_count:
    type: integer
    required: false

  failed_count:
    type: integer
    required: false

  skipped_count:
    type: integer
    required: false

  duration_ms:
    type: integer
    required: false

  output:
    type: string
    required: false
    description: "Test output (truncated if large, preserves ANSI)"

  run_at:
    type: timestamp
    required: false

  source_hash:
    type: string
    required: false
    description: "Source hash at test time"

actuality:
  mode: cargo-test
  note: "Manifest runs cargo test; sense checks pass/fail status"
```

### lint-run

A linting/clippy execution.

```yaml
eidos: lint-run
description: |
  A clippy/lint execution record. Tracks code quality checks.

fields:
  lint_type:
    type: enum
    values: [clippy, fmt-check, doc-check]
    required: true

  status:
    type: enum
    values: [pending, running, clean, warnings, errors]
    default: pending
    required: true

  warning_count:
    type: integer
    required: false

  error_count:
    type: integer
    required: false

  output:
    type: string
    required: false

  run_at:
    type: timestamp
    required: false

  duration_ms:
    type: integer
    required: false

actuality:
  mode: cargo-clippy
```

---

## Desmoi (Bond Types)

```yaml
# source-crate → build-target
desmos: builds-into
from_eidos: source-crate
to_eidos: build-target
description: "Source crate builds into this target"
cardinality: one-to-many  # One crate can have multiple profiles/targets

# build-target → source-crate (inverse for traversal)
desmos: compiled-from
from_eidos: build-target
to_eidos: source-crate
description: "Build target was compiled from this source"
cardinality: many-to-one

# test-run → build-target
desmos: tests-against
from_eidos: test-run
to_eidos: build-target
description: "Test run executed against this build target"
cardinality: many-to-one

# lint-run → source-crate
desmos: lints
from_eidos: lint-run
to_eidos: source-crate
description: "Lint run checked this source crate"
cardinality: many-to-one
```

---

## Modes

### cargo-build

```yaml
mode: cargo-build
substrate: cargo
description: "Compile a Rust crate via cargo"

operations:
  manifest:
    stoicheion: cargo-build-run
    description: "Execute cargo build"

  sense:
    stoicheion: cargo-build-sense
    description: "Check if binary exists and hash matches source"

  unmanifest:
    stoicheion: cargo-clean
    description: "Remove build artifacts"

config_schema:
  crate_name:
    type: string
    required: true
  profile:
    type: enum
    values: [dev, release, test]
    default: dev
  target_triple:
    type: string
    required: false
  features:
    type: array
    required: false
```

### cargo-test

```yaml
mode: cargo-test
substrate: cargo
description: "Run tests for a Rust crate"

operations:
  manifest:
    stoicheion: cargo-test-run
    description: "Execute cargo test"

  sense:
    stoicheion: cargo-test-sense
    description: "Check test status from last run"

config_schema:
  crate_name:
    type: string
    required: true
  test_filter:
    type: string
    required: false
  nocapture:
    type: boolean
    default: false
```

### cargo-clippy

```yaml
mode: cargo-clippy
substrate: cargo
description: "Run clippy lints"

operations:
  manifest:
    stoicheion: cargo-clippy-run
    description: "Execute cargo clippy"

  sense:
    stoicheion: cargo-clippy-sense
    description: "Check lint status"

config_schema:
  crate_name:
    type: string
    required: true
  deny_warnings:
    type: boolean
    default: false
```

---

## Praxeis (Operations)

| Praxis | Description | Visible |
|--------|-------------|---------|
| `chora-dev/scan-workspace` | Discover crates via cargo metadata | Yes |
| `chora-dev/build` | Build crate, create build-target entity | Yes |
| `chora-dev/test` | Run tests, create test-run entity | Yes |
| `chora-dev/lint` | Run clippy, create lint-run entity | Yes |
| `chora-dev/reconcile-builds` | Check staleness and rebuild | Yes |
| `chora-dev/sense-build` | Check if artifact exists and is fresh | Yes |
| `chora-dev/mark-stale` | Mark build-targets as stale | No (reflex) |
| `chora-dev/register-for-release` | Link build-target to release-artifact | Yes |
| `chora-dev/deploy-build` | Deploy build-target to node | Yes |

See `genesis/chora-dev/praxeis/chora-dev.yaml` for full implementations.

---

## Attainments

```yaml
attainment: substrate-develop
description: |
  Capability to build, test, and manage chora substrate.
  Required for chora-dev operations.
grants:
  - chora-dev/scan-workspace
  - chora-dev/build
  - chora-dev/test
  - chora-dev/lint
  - chora-dev/reconcile-builds
  - chora-dev/sense-build
  - chora-dev/mark-stale
  - chora-dev/register-for-release
  - chora-dev/deploy-build

attainment: substrate-observe
description: |
  Read-only access to build state.
  For CI integration and dashboards.
grants:
  - chora-dev/sense-build
  # Implied: gather build-target, gather test-run
```

---

## Opsis Integration (Thyra Experience)

### Layout and Panels

| Panel | Region | Purpose |
|-------|--------|---------|
| `crate-list` | sidebar (300px) | Workspace crates with build status |
| `build-detail` | main | Selected crate's build info, actions |
| `test-timeline` | bottom (200px, collapsible) | Test history grouped by crate |

### Render Specs

| Eidos | Render Spec | Key Features |
|-------|-------------|--------------|
| source-crate | `source-crate-card` | Build status derived from bonds |
| build-target | `build-target-card` | Progress indicator when building |
| test-run | `test-run-card` | Expandable output with ANSI |
| lint-run | `lint-run-card` | Warning/error counts |

### Commands and Shortcuts

| Command | Shortcut | Description |
|---------|----------|-------------|
| `chora-dev.build` | `Cmd+B` | Build selected crate (debug) |
| `chora-dev.build` (release) | `Cmd+Shift+B` | Build selected crate (release) |
| `chora-dev.test` | `Cmd+T` | Run tests |
| `chora-dev.scan` | `Cmd+Shift+S` | Scan workspace |

---

## Reflexes (Automation)

| Reflex | Trigger | Action |
|--------|---------|--------|
| `notify-build-complete` | build-target status changes from building | thyra/notify |
| `notify-test-failure` | test-run status == failed | thyra/notify (high urgency) |
| `detect-staleness` | file_changed `crates/**/src/**/*.rs` | chora-dev/mark-stale |
| `detect-staleness-cargo` | file_changed `crates/**/Cargo.toml` | chora-dev/mark-stale |
| `auto-index-build-target` | entity_created build-target | nous/index-entity |
| `auto-index-test-run` | entity_created test-run | nous/index-entity |

---

## Ergon Integration

### Reconciler

```yaml
reconciler: chora-dev-builds
interval: "30m"  # Configurable: 5m for CI, 30m for dev, 1h for prod
praxis: chora-dev/reconcile-builds
scope: dwelling
```

### Daemons

| Daemon | Type | Purpose |
|--------|------|---------|
| `chora-dev-watcher` | file-watcher | Detect source changes, trigger staleness |
| `chora-dev-build-queue` | queue-processor | Manage concurrent builds (max 2) |

---

## Resolved Design Decisions

| Question | Decision |
|----------|----------|
| **Test caching** | Yes — test-run stores source_hash, sense checks cached results |
| **Workspace vs per-crate builds** | Per-crate — better granularity for staleness tracking |
| **File watching vs polling** | File watching via ergon daemon with 1s debounce |
| **Build output streaming** | WebSocket events (`build-progress`) for real-time updates |
| **Region placement** | Top-level "Development" navigation item |

---

## Integration with Deployment

The build-target connects to deployment via release:

```
source-crate/kosmos-mcp
       │
       │ builds-into
       ↓
build-target/kosmos-mcp-release
       │
       │ [chora-dev/register-for-release]
       ↓
release-artifact/kosmos-mcp-v0.9.0-darwin
       │
       │ contains-artifact (inverse)
       ↓
release/v0.9.0
       │
       │ deploys-release (inverse)
       ↓
deployment/kosmos-mcp-local ──targets-node──► node/personal-mac
```

**Workflow:**
1. `chora-dev/build` creates build-target with content hash
2. `chora-dev/register-for-release` links build-target to release
3. `chora-dev/deploy-build` creates deployment and manifests it

---

## Handoff: Tier 3 Stoicheia Implementation

The kosmos-side ontology is complete. Rather than implementing 8 cargo-specific stoicheia, we use **generic primitives + command templates** for maximum homoiconicity and reuse.

### Design Principle

Commands become **data in the graph**, not code in Rust:

| Approach | Stoicheia Count | New Tool | Customization |
|----------|-----------------|----------|---------------|
| Cargo-specific | 8 | New Rust code | Recompile |
| Generic + Templates | 4 | New YAML entity | Edit graph |

### Location

Implement in: `crates/kosmos/src/interpreter/steps/shell.rs` (new file)

Register in: `crates/kosmos/src/interpreter/steps.rs`

---

### Generic Stoicheia to Implement (4 total)

#### 1. shell-execute

Execute any shell command. The foundation for all tool integrations.

```rust
/// Execute a shell command
///
/// Params:
///   - command: String (required) - executable name
///   - args: Vec<String> (required) - command arguments
///   - working_dir: String (optional) - defaults to workspace root
///   - env: Object (optional) - environment variables
///   - timeout_ms: u64 (optional) - timeout in milliseconds
///
/// Returns:
///   - stdout: String
///   - stderr: String
///   - exit_code: i32
///   - duration_ms: u64
///   - success: bool
async fn execute_shell_execute(ctx: &StepContext, params: &Value) -> Result<Value> {
    let command = params["command"].as_str()
        .ok_or_else(|| anyhow!("command required"))?;

    let args: Vec<&str> = params["args"]
        .as_array()
        .map(|arr| arr.iter().filter_map(|v| v.as_str()).collect())
        .unwrap_or_default();

    let working_dir = params.get("working_dir")
        .and_then(|v| v.as_str())
        .unwrap_or(&ctx.workspace_root);

    let timeout = params.get("timeout_ms")
        .and_then(|v| v.as_u64())
        .unwrap_or(300_000); // 5 min default

    let mut cmd = Command::new(command);
    cmd.args(&args)
       .current_dir(working_dir)
       .stdout(Stdio::piped())
       .stderr(Stdio::piped());

    // Add custom env vars
    if let Some(env) = params.get("env").and_then(|v| v.as_object()) {
        for (k, v) in env {
            if let Some(val) = v.as_str() {
                cmd.env(k, val);
            }
        }
    }

    let start = Instant::now();
    let output = tokio::time::timeout(
        Duration::from_millis(timeout),
        cmd.output()
    ).await??;
    let duration_ms = start.elapsed().as_millis() as u64;

    Ok(json!({
        "stdout": String::from_utf8_lossy(&output.stdout),
        "stderr": String::from_utf8_lossy(&output.stderr),
        "exit_code": output.status.code().unwrap_or(-1),
        "duration_ms": duration_ms,
        "success": output.status.success()
    }))
}
```

#### 2. hash-path

Compute BLAKE3 hash of files matching a pattern. Used for staleness detection.

```rust
/// Hash files matching a glob pattern
///
/// Params:
///   - path: String (required) - base directory
///   - pattern: String (optional) - glob pattern, default "**/*"
///   - include_names: bool (optional) - include filenames in hash, default true
///
/// Returns:
///   - hash: String (hex-encoded BLAKE3)
///   - file_count: u32
async fn execute_hash_path(params: &Value) -> Result<Value> {
    let base_path = params["path"].as_str()
        .ok_or_else(|| anyhow!("path required"))?;

    let pattern = params.get("pattern")
        .and_then(|v| v.as_str())
        .unwrap_or("**/*");

    let include_names = params.get("include_names")
        .and_then(|v| v.as_bool())
        .unwrap_or(true);

    let mut hasher = blake3::Hasher::new();
    let mut file_count = 0u32;

    let glob_pattern = format!("{}/{}", base_path, pattern);
    for entry in glob::glob(&glob_pattern)?.filter_map(|e| e.ok()) {
        if entry.is_file() {
            if include_names {
                // Include relative path in hash for rename detection
                if let Ok(rel) = entry.strip_prefix(base_path) {
                    hasher.update(rel.to_string_lossy().as_bytes());
                }
            }
            hasher.update(&std::fs::read(&entry)?);
            file_count += 1;
        }
    }

    Ok(json!({
        "hash": hasher.finalize().to_hex().to_string(),
        "file_count": file_count
    }))
}
```

#### 3. parse-output

Parse structured output using format-specific handlers or regex.

```rust
/// Parse command output
///
/// Params:
///   - content: String (required) - content to parse
///   - format: String (required) - "json" | "regex" | "lines" | "cargo-test" | "cargo-clippy"
///   - schema: Object (optional) - extraction rules for regex/lines
///
/// Returns:
///   - parsed: Object - format-specific result
async fn execute_parse_output(params: &Value) -> Result<Value> {
    let content = params["content"].as_str()
        .ok_or_else(|| anyhow!("content required"))?;

    let format = params["format"].as_str()
        .ok_or_else(|| anyhow!("format required"))?;

    match format {
        "json" => {
            let parsed: Value = serde_json::from_str(content)?;
            Ok(json!({ "parsed": parsed }))
        }

        "lines" => {
            let lines: Vec<&str> = content.lines().collect();
            Ok(json!({ "parsed": { "lines": lines, "count": lines.len() } }))
        }

        "regex" => {
            let schema = params.get("schema")
                .ok_or_else(|| anyhow!("schema required for regex format"))?;
            let pattern = schema["pattern"].as_str()
                .ok_or_else(|| anyhow!("pattern required in schema"))?;

            let re = regex::Regex::new(pattern)?;
            let captures: Vec<Value> = re.captures_iter(content)
                .map(|cap| {
                    let groups: Vec<&str> = cap.iter()
                        .filter_map(|m| m.map(|m| m.as_str()))
                        .collect();
                    json!(groups)
                })
                .collect();

            Ok(json!({ "parsed": { "matches": captures } }))
        }

        // Built-in format handlers for common tools
        "cargo-test" => {
            let (passed, failed, skipped) = parse_cargo_test_output(content)?;
            let status = if failed > 0 { "failed" }
                        else if passed > 0 { "passed" }
                        else { "skipped" };
            Ok(json!({
                "parsed": {
                    "status": status,
                    "passed": passed,
                    "failed": failed,
                    "skipped": skipped
                }
            }))
        }

        "cargo-clippy" => {
            let (warnings, errors) = parse_cargo_clippy_json(content)?;
            let status = if errors > 0 { "errors" }
                        else if warnings > 0 { "warnings" }
                        else { "clean" };
            Ok(json!({
                "parsed": {
                    "status": status,
                    "warnings": warnings,
                    "errors": errors
                }
            }))
        }

        "cargo-metadata" => {
            let metadata: CargoMetadata = serde_json::from_str(content)?;
            let crates: Vec<Value> = metadata.packages.iter()
                .filter(|p| p.source.is_none())
                .map(|p| {
                    let crate_type = if p.targets.iter().any(|t| t.kind.contains(&"bin".into())) {
                        "bin"
                    } else if p.targets.iter().any(|t| t.kind.contains(&"proc-macro".into())) {
                        "proc-macro"
                    } else {
                        "lib"
                    };
                    json!({
                        "name": p.name,
                        "path": p.manifest_path.parent().map(|p| p.display().to_string()),
                        "crate_type": crate_type
                    })
                })
                .collect();
            Ok(json!({ "parsed": { "crates": crates } }))
        }

        _ => Err(anyhow!("unknown format: {}", format))
    }
}

// Helper functions for cargo output parsing
fn parse_cargo_test_output(content: &str) -> Result<(u32, u32, u32)> {
    // Parse "test result: ok. X passed; Y failed; Z ignored"
    let re = regex::Regex::new(r"(\d+) passed; (\d+) failed; (\d+) ignored")?;
    if let Some(cap) = re.captures(content) {
        Ok((
            cap[1].parse().unwrap_or(0),
            cap[2].parse().unwrap_or(0),
            cap[3].parse().unwrap_or(0),
        ))
    } else {
        Ok((0, 0, 0))
    }
}

fn parse_cargo_clippy_json(content: &str) -> Result<(u32, u32)> {
    let mut warnings = 0u32;
    let mut errors = 0u32;
    for line in content.lines() {
        if let Ok(msg) = serde_json::from_str::<Value>(line) {
            if let Some(level) = msg.get("level").and_then(|l| l.as_str()) {
                match level {
                    "warning" => warnings += 1,
                    "error" => errors += 1,
                    _ => {}
                }
            }
        }
    }
    Ok((warnings, errors))
}
```

#### 4. file-exists

Check if a file or directory exists. Simple but essential for sense operations.

```rust
/// Check if path exists
///
/// Params:
///   - path: String (required)
///
/// Returns:
///   - exists: bool
///   - is_file: bool
///   - is_dir: bool
///   - size: Option<u64>
///   - modified_at: Option<String>
async fn execute_file_exists(params: &Value) -> Result<Value> {
    let path = params["path"].as_str()
        .ok_or_else(|| anyhow!("path required"))?;

    let path = Path::new(path);

    if !path.exists() {
        return Ok(json!({
            "exists": false,
            "is_file": false,
            "is_dir": false
        }));
    }

    let metadata = std::fs::metadata(path)?;
    let modified = metadata.modified().ok()
        .and_then(|t| t.duration_since(std::time::UNIX_EPOCH).ok())
        .map(|d| d.as_secs());

    Ok(json!({
        "exists": true,
        "is_file": metadata.is_file(),
        "is_dir": metadata.is_dir(),
        "size": metadata.len(),
        "modified_at": modified
    }))
}
```

---

### Command Templates (Kosmos Entities)

Commands are defined as entities in kosmos, not code in Rust. The praxeis compose these templates with the generic stoicheia.

**Location:** `genesis/chora-dev/entities/command-templates.yaml`

```yaml
# Cargo build command template
command-template/cargo-build:
  eidos: command-template
  data:
    name: cargo-build
    command: cargo
    args_template: |
      build
      --package
      {{ $crate_name }}
      {{ $profile == 'release' ? '--release' : '' }}
      {{ $features ? '--features ' + $features | join(',') : '' }}
    success_check: "$exit_code == 0"
    artifact_path_template: "target/{{ $profile == 'release' ? 'release' : 'debug' }}/{{ $crate_name }}"

command-template/cargo-test:
  eidos: command-template
  data:
    name: cargo-test
    command: cargo
    args_template: |
      test
      --package
      {{ $crate_name }}
      {{ $test_filter ? '-- ' + $test_filter : '' }}
      {{ $nocapture ? '-- --nocapture' : '' }}
    output_format: cargo-test
    success_check: "$parsed.failed == 0"

command-template/cargo-clippy:
  eidos: command-template
  data:
    name: cargo-clippy
    command: cargo
    args_template: |
      clippy
      --package
      {{ $crate_name }}
      --message-format=json
      {{ $deny_warnings ? '-- -D warnings' : '' }}
    output_format: cargo-clippy

command-template/cargo-metadata:
  eidos: command-template
  data:
    name: cargo-metadata
    command: cargo
    args_template: "metadata --format-version=1 --no-deps"
    output_format: cargo-metadata

command-template/cargo-clean:
  eidos: command-template
  data:
    name: cargo-clean
    command: cargo
    args_template: "clean --package {{ $crate_name }}"
```

---

### How Praxeis Use Templates

The `chora-dev/build` praxis composes the generic stoicheia with templates:

```yaml
praxis: chora-dev/build
steps:
  # 1. Get the command template
  - step: find
    id: "command-template/cargo-build"
    bind_to: template

  # 2. Hash source for staleness tracking
  - step: call_stoicheion
    stoicheion: hash-path
    params:
      path: "crates/{{ $crate_name }}"
      pattern: "**/*.rs"
    bind_to: source_hash

  # 3. Render args from template
  - step: set
    bindings:
      rendered_args: "{{ render($template.data.args_template) | split('\n') | filter }}"

  # 4. Execute the command
  - step: call_stoicheion
    stoicheion: shell-execute
    params:
      command: $template.data.command
      args: $rendered_args
      working_dir: $workspace_root
    bind_to: result

  # 5. Hash the artifact
  - step: switch
    cases:
      - when: $result.success
        then:
          - step: call_stoicheion
            stoicheion: hash-path
            params:
              path: "{{ render($template.data.artifact_path_template) }}"
            bind_to: artifact_hash

  # 6. Create/update build-target entity
  - step: compose
    typos_id: typos-def-build-target
    # ... rest of composition
```

---

### Dependencies to Add

```toml
# Cargo.toml
[dependencies]
blake3 = "1.5"
glob = "0.3"
regex = "1.10"
```

---

### Registration

In `crates/kosmos/src/interpreter/steps.rs`:

```rust
mod shell;

pub fn register_steps(registry: &mut StepRegistry) {
    // ... existing registrations ...

    // Generic shell operations (Tier 3)
    registry.register("shell-execute", shell::execute_shell_execute);
    registry.register("hash-path", shell::execute_hash_path);
    registry.register("parse-output", shell::execute_parse_output);
    registry.register("file-exists", shell::execute_file_exists);
}
```

---

### Why This Is Better

| Aspect | Before (8 specific) | After (4 generic) |
|--------|---------------------|-------------------|
| Add npm support | New `npm-*.rs` | New `command-template/npm-*` entity |
| Add go support | New `go-*.rs` | New `command-template/go-*` entity |
| Customize cargo | Recompile chora | Edit template entity |
| Parse new format | Add Rust parser | Add format to `parse-output` OR use regex |
| Maintenance | 8 functions | 4 functions |
| Homoiconicity | Commands in code | Commands in graph |

---

## Testing the Implementation

After implementing the generic stoicheia:

```bash
# Test shell-execute directly
curl -X POST http://localhost:3000/mcp -d '{
  "method": "tools/call",
  "params": {
    "name": "shell-execute",
    "arguments": {
      "command": "cargo",
      "args": ["--version"]
    }
  }
}'

# Test hash-path
curl -X POST http://localhost:3000/mcp -d '{
  "method": "tools/call",
  "params": {
    "name": "hash-path",
    "arguments": {
      "path": "crates/kosmos",
      "pattern": "**/*.rs"
    }
  }
}'

# Test full build via praxis
mcp call chora-dev_build crate_name=kosmos-mcp profile=dev
```

---

## Summary

`topos/chora-dev` makes substrate development homoiconic:

| Concern | Before | After |
|---------|--------|-------|
| Build state | Implicit in filesystem | `build-target` entities with content hashes |
| Test results | Lost after run | `test-run` entities with history |
| Source tracking | Not tracked | `source-crate` entities with dependency graph |
| Staleness | Manual `cargo build` | Reconciliation via `chora-dev/reconcile-builds` |
| Deployment | Separate concern | Connected via `release` → `dynamis` chain |
| Visibility | Terminal output | Thyra panels with real-time status |
| Actions | CLI commands | Afforded actions in context menus |
| **Tool commands** | **Hard-coded in Rust** | **Command templates as entities** |

**Thyra experience includes:**
- Workspace dashboard with crate list and status
- Build detail panel with progress and logs
- Test timeline with history and output
- Real-time notifications for build/test completion
- Command palette and keyboard shortcuts

**Implementation approach:**
- 4 generic stoicheia (`shell-execute`, `hash-path`, `parse-output`, `file-exists`)
- Command templates as graph entities (cargo-build, cargo-test, etc.)
- New tools (npm, go, make) require only new YAML, not new Rust

The circle closes: **kosmos orchestrates chora development, which runs kosmos, which renders the development state in Thyra.**

---

## Theoria Crystallized

The following insights were captured during implementation:

1. **Full-circle validation** (`theoria/full-circle-validation`)
   - The substrate becomes self-describing when it orchestrates its own build

2. **Mode pattern** (`theoria/mode-pattern`)
   - manifest/sense/unmanifest triad for tool integration

3. **Staleness via content hashing** (`theoria/staleness-via-content-hashing`)
   - BLAKE3 + phylax pattern enables incremental builds

4. **Cross-topos integration chains** (`theoria/cross-topos-integration-chains`)
   - Bond chains respect separation of concerns

5. **Topos as comprehensive unit** (`theoria/topos-as-comprehensive-unit`)
   - Complete capability package from eide to UI

6. **Generic primitives over specific implementations** (`theoria/generic-primitives`)
   - 4 generic stoicheia + command templates > 8 cargo-specific stoicheia
   - Commands as data enables homoiconic tool integration
   - New tools require YAML, not Rust

---

*Kosmos-side implementation complete. See [Handoff](#handoff-tier-3-stoicheia-implementation) for chora-side work.*
