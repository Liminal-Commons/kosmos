# Command Template Execution

*Reference for the template-driven stoicheion pattern that reads command templates from the graph, interpolates arguments, and shell-executes.*

---

## Overview

Command templates are entities (`eidos: command-template`) that describe shell commands as data in the graph. The `execute_command_template()` function in `host.rs` reads these templates, interpolates arguments using entity data, executes via `std::process::Command`, parses output, and optionally hashes artifacts.

This pattern enables homoiconic tool integration: adding new tools (npm, go, make) requires only new YAML template entities and a one-line mapping — no new Rust code for the execution path.

Command templates are one implementation strategy within a substrate module. For the standard module contract that all substrates follow, see [substrate-integration.md](substrate-integration.md).

---

## Architecture

```
Entity (build-target/kosmos-release)
  data: { crate_name: "kosmos", profile: "release", mode: "cargo-build" }
    │
    ▼
manifest(entity_id)
    │
    ├─ resolve_mode(data) → ("cargo-build", "local")
    ├─ stoicheion_for_mode("cargo-build", "local", Manifest) → "cargo-build-run"
    │
    └─ manifest_by_stoicheion(entity_id, "cargo-build-run", data)
       │
       ├─ template_for_stoicheion("cargo-build-run") → "command-template/cargo-build"
       ├─ find_entity("command-template/cargo-build") → template data
       ├─ interpolate_template_args(template.args, entity.data) → ["build", "--package", "kosmos", "--release"]
       ├─ Command::new("cargo").args(resolved_args).wait_with_output()
       ├─ parse_command_output(stdout, "cargo-test") [if output_format specified]
       ├─ compute_artifact_path(segments, data) → "target/release/kosmos"
       ├─ blake3::hash(artifact) → content_hash
       │
       └─ { success, stdout, stderr, exit_code, duration_ms, parsed, artifact_path, content_hash, error }
```

---

## Stoicheion-to-Template Mapping

Static function `template_for_stoicheion()` maps stoicheion names to command-template entity IDs:

| Stoicheion | Template Entity |
|------------|----------------|
| `cargo-build-run` | `command-template/cargo-build` |
| `cargo-test-run` | `command-template/cargo-test` |
| `cargo-clippy-run` | `command-template/cargo-clippy` |
| `cargo-clean` | `command-template/cargo-clean` |
| `cargo-metadata` | `command-template/cargo-metadata` |

---

## Argument Interpolation

Template args are an array of mixed types:

### String args (always included)

```yaml
args:
  - "build"
  - "--package"
  - "{{ $crate_name }}"
```

Evaluated via `eval_string()`. Template expressions `{{ }}` and `$var` references are interpolated using entity data as the scope.

### Conditional args (included when condition is truthy)

```yaml
args:
  - value: "--release"
    when: "$profile == 'release'"
  - value: "--features"
    when: "$features"
  - value: "{{ $features | join(',') }}"
    when: "$features"
```

The `when:` expression is evaluated via `evaluate_expression()`. If `is_truthy()`, the `value:` is interpolated and included. Otherwise the arg is skipped.

Supported condition patterns:
- Equality: `$profile == 'release'`
- Inequality: `$profile != 'release'`
- Truthiness: `$features` (truthy if non-null, non-empty)
- Negation: `!$dry_run`
- Logical: `$a && $b`, `$a || $b`

---

## Output Parsing

When a template specifies `output_format`, the command's stdout is parsed:

| Format | Parser | Output |
|--------|--------|--------|
| `cargo-test` | Regex on summary line | `{ result, passed, failed, ignored, success }` |
| `cargo-clippy` | JSON line parsing | `{ warnings, errors, success }` |
| `cargo-metadata` | JSON parse | Full metadata object |
| `json` | JSON parse | Parsed value |

---

## Artifact Path Computation

Templates with `artifact_path_segments` compute the expected output path:

```yaml
artifact_path_segments:
  - "target"
  - value: "release"
    when: "$profile == 'release'"
  - value: "debug"
    when: "$profile != 'release'"
  - "{{ $crate_name }}"
```

Same conditional pattern as args. Segments are joined with `/`.

---

## Sense Pattern

Build artifact sensing does NOT re-run the command. It checks:

1. **File existence**: Does the artifact exist at the computed path?
2. **Content hash freshness**: Does the artifact's current BLAKE3 hash match the stored `content_hash`?

Source staleness (has the source changed since the last build?) is handled at the praxis level by `reconcile-builds`, not at the stoicheion level.

Test/lint sensing returns last run info from entity data (`status`, `run_at`, counts).

---

## Return Contract

`execute_command_template()` returns:

```json
{
  "status": "manifested" | "failed",
  "entity_id": "<entity-id>",
  "stoicheion": "<stoicheion-name>",
  "success": true | false,
  "stdout": "<raw-stdout>",
  "stderr": "<raw-stderr>",
  "exit_code": 0,
  "duration_ms": 12345,
  "parsed": { ... } | null,
  "artifact_path": "target/release/kosmos" | null,
  "content_hash": "<blake3-hex>" | null,
  "error": "<stderr>" | null
}
```

---

*Traces to: KOSMOGONIA §Homoiconic, T5 (code is artifact), T11 (reconciliation is substrate-universal)*

*This describes one execution pattern within the actualization cycle. For the full pattern including all substrates and modes, see [actualization-pattern.md](../reactivity/actualization-pattern.md).*
