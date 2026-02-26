# How to: Create a Daemon

Declare a supervised daemon entity. Daemons are long-lived background processes
managed by the daemon runner.

Daemons are **declarative** — you define them as entities in genesis YAML,
and the daemon runner discovers and manages them at bootstrap.

---

## When to Use

Use this pattern when:
- You need to run a long-lived process
- You want automatic restart on failure
- You're setting up supervised infrastructure

---

## Step 1: Define the Daemon Entity

Daemons are declared in a `daemons/` directory within a topos:

```yaml
# genesis/my-topos/daemons/daemons.yaml
entities:
  - eidos: daemon
    id: daemon/my-topos/my-service
    data:
      name: my-service
      description: What this daemon does
      command: "cargo run --release -p my-service"
      working_dir: "/path/to/project"
      restart_policy: on-failure
      max_restarts: 3
      status: stopped
      env:
        MY_VAR: "value"
```

### Daemon Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | yes | Unique daemon identifier |
| `command` | string | yes | Shell command to execute |
| `working_dir` | string | no | Working directory for the process |
| `restart_policy` | string | no | `always`, `on-failure`, or `never` |
| `max_restarts` | number | no | Maximum restart attempts before giving up |
| `status` | string | no | Initial status (default: `stopped`) |
| `env` | object | no | Environment variables |

---

## Step 2: Add to Manifest

Declare the daemons directory in your manifest:

```yaml
content_paths:
  - path: daemons/
    content_types: [daemon]
```

---

## Step 3: Bootstrap

When you run `just dev`, bootstrap discovers all daemon entities via `gather(eidos: daemon)`.
After `exit_bootstrap_mode()` completes, the daemon runner:

1. **Gathers** all daemon entities
2. **Spawns** a background thread per daemon
3. **Monitors** process health
4. **Restarts** on failure according to `restart_policy`

---

## How It Works

Daemons are not created via praxis calls. They are **static entities** loaded at bootstrap time.
The daemon runner (see `crates/kosmos/src/daemon_loop.rs`) discovers them and manages their lifecycle.

```
Bootstrap → gather(eidos: daemon) → spawn threads → monitor → restart on failure
```

Reflexes are dormant during bootstrap and become active after `exit_bootstrap_mode()`.

---

## Example: Existing Daemons

See `genesis/dynamis/daemons/daemons.yaml` for real examples of daemon entity declarations.

---

## See Also

- [Reactive System Reference](../../reference/reactivity/reactive-system-reference.md) — How reflexes interact with daemon lifecycle
- [Create Your First Reflex](../../tutorial/reactivity/create-your-first-reflex.md) — Reflexes respond to entity changes

---

*Guide for declaring daemon entities in genesis.*
