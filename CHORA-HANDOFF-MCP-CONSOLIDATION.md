# Chora Handoff: MCP Consolidation

**Date:** 2026-01-30
**From:** kosmos development session
**To:** chora implementation

---

## Summary

Consolidate `kosmos-mcp` into the main chora binary. MCP should be a core capability of chora, not a separate tool.

---

## Current State

```
chora/
├── src/bin/
│   ├── kosmos-cli       # CLI tool
│   └── kosmos-mcp       # Separate MCP server binary
```

- Each Claude Code window spawns its own `kosmos-mcp` process
- Each process opens the same SQLite database
- SQLite single-writer lock causes conflicts
- Second window gets read-only access, fails on mutations

---

## Desired State

```
chora/
├── src/bin/
│   └── chora            # Single binary, multiple modes
```

```bash
chora --mode genesis              # Bootstrap only
chora --mode serve                # MCP server (stdio)
chora --mode serve --transport http --port 3000  # HTTP/SSE
chora --mode cli                  # Interactive REPL
```

---

## Rationale

### Ontological Alignment

- **Thyra** is the portal — how kosmos becomes accessible to agents
- **MCP** is one projection mechanism of thyra
- Transport (stdio, HTTP) is a runtime concern, not a separate binary

The separation was historical, not architectural. MCP is *the* interface for agents — it should be core.

### Multi-Channel Support

The ontology already supports:
- Same **animus** (authenticated user)
- Multiple **channels** (communication pathways)
- Coordinated access through **thyra**

Implementation should honor this:
- One process = one database connection
- Multiple clients connect to that process
- Channels coordinate within the process

### Simpler Architecture

Before:
```
Claude Code Window 1 → kosmos-mcp process 1 → SQLite (writer)
Claude Code Window 2 → kosmos-mcp process 2 → SQLite (read-only, fails)
```

After:
```
Claude Code Window 1 ─┐
                      ├→ chora serve → SQLite
Claude Code Window 2 ─┘
```

---

## Implementation Notes

### Phase 1: Consolidate Binaries

1. Move MCP server code into main binary
2. Add `--mode serve` flag
3. Default to stdio transport (current behavior)
4. Deprecate `kosmos-mcp` binary

### Phase 2: HTTP Transport

1. Add `--transport http` option
2. Implement SSE endpoint for MCP over HTTP
3. Single process serves multiple clients
4. Proper request serialization

### Phase 3: Multi-Channel Coordination

1. Track active channels per animus
2. Coordinate concurrent requests
3. Proper write serialization (already handled by single process)

---

## Configuration Change

### Before (.mcp.json)
```json
{
  "mcpServers": {
    "kosmos": {
      "type": "stdio",
      "command": "/path/to/kosmos-mcp",
      "args": []
    }
  }
}
```

### After (.mcp.json)
```json
{
  "mcpServers": {
    "kosmos": {
      "type": "sse",
      "url": "http://localhost:3000/mcp"
    }
  }
}
```

Or for stdio mode (backwards compatible):
```json
{
  "mcpServers": {
    "kosmos": {
      "type": "stdio",
      "command": "/path/to/chora",
      "args": ["--mode", "serve"]
    }
  }
}
```

---

## Success Criteria

1. Single `chora` binary replaces both `kosmos-cli` and `kosmos-mcp`
2. Multiple Claude Code windows can connect to same kosmos
3. No database lock conflicts
4. Authentication flows through propylon as before
5. All existing praxeis work unchanged

---

## Related Ontology

This change doesn't require ontology changes. The ontology already expresses:

- **thyra**: Portal, projection of praxeis
- **soma/channel**: Communication pathway
- **propylon**: Authentication gateway
- **animus**: Authenticated agent

The implementation now honors what the ontology already describes.

---

*Composed in service of the kosmogonia.*
