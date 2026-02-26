# Constituent Element Types

*The atoms of kosmos — the building blocks from which all composite patterns are composed.*

---

## Overview

Every topos is built from a vocabulary of nine element types. Each element type is an eidos introduced by a specific foundational topos. Instances of these eide are defined in genesis YAML files and loaded during bootstrap.

---

## Element Catalog

| Element | Eidos | Introduced By | What It Is |
|---------|-------|--------------|------------|
| **Eidos** | `eidos` | arche | Entity type definition — the schema for what CAN exist |
| **Desmos** | `desmos` | arche | Bond type definition — how entities RELATE |
| **Praxis** | `praxis` | arche | Executable procedure — what entities DO |
| **Typos** | `typos` | demiurge | Composition mold — template for composing artifacts |
| **Render-Spec** | `render-spec` | thyra | Declarative widget tree — how an entity becomes visible |
| **Mode** | `mode` | thyra | How existence becomes actuality. Two kinds: **thyra modes** open the door to perception (spatial position + render-spec, no substrate), **dynamis modes** extend kosmos into capabilities (substrate + stoicheion-dispatched operations) |
| **Surface** | `surface` | dynamis | Capability contract — named set of guarantees a topos provides to others |
| **Seed** | (varies) | (per topos) | Initial entity instance loaded at genesis |
| **Theoria** | `theoria` | nous | Crystallized understanding — accumulated insight |

---

## What About Triggers, Reflexes, Reconcilers, Daemons?

These are **eide that configure autonomic surfaces**, not distinct element types. They follow the same pattern as render-specs (which configure the rendering surface):

| Eidos | Configures Surface | Introduced By |
|-------|-------------------|---------------|
| `trigger` | `surface/reactivity` | ergon |
| `reflex` | `surface/reactivity` | ergon |
| `daemon` | `surface/sensing` | ergon |
| `reconciler` | `surface/reconciliation` | dynamis |

A topos that declares reflex entities consumes `surface/reactivity`. A topos that declares daemon entities consumes `surface/sensing`. A topos that declares reconciler entities consumes `surface/reconciliation`. The directory conventions remain (`reflexes/`, `daemons/`, `reconcilers/`), but ontologically these are entities configuring surfaces, not a distinct category.

Similarly, **stoicheia** (step types defined by `stoicheia-portable`) and **widgets** (UI primitives defined by thyra) are interpreter internals — not topos-level constituent elements.

---

## Where Instances Live

Element instances are defined in genesis YAML files following directory conventions:

| Element | Genesis Location | Example |
|---------|-----------------|---------|
| Eidos | `genesis/{topos}/eide/{topos}.yaml` | `genesis/logos/eide/logos.yaml` |
| Desmos | `genesis/{topos}/desmoi/{topos}.yaml` | `genesis/thyra/desmoi/thyra.yaml` |
| Praxis | `genesis/{topos}/praxeis/{topos}.yaml` | `genesis/demiurge/praxeis/demiurge.yaml` |
| Typos | `genesis/demiurge/typos/*.yaml` | `genesis/demiurge/typos/composition.yaml` |
| Render-Spec | `genesis/thyra/render-specs/*.yaml` | `genesis/thyra/render-specs/phasis.yaml` |
| Mode | `genesis/{topos}/modes/*.yaml` | `genesis/thyra/modes/voice.yaml` |
| Surface | `genesis/{topos}/surfaces/*.yaml` | `genesis/dynamis/surfaces/surfaces.yaml` |
| Seed | `genesis/{topos}/seeds/*.yaml` | `genesis/dynamis/seeds/substrates.yaml` |
| Theoria | Created via `nous/crystallize-theoria` praxis | (runtime entities) |

---

## Generation Support

Some element types can be generated via governed inference rather than hand-authored:

| Element | Generation Praxis | Inference Context |
|---------|------------------|-------------------|
| Render-Spec | `demiurge/generate-render-spec` | `typos-inference-render-spec` |
| Eidos | `demiurge/generate-eidos` | `typos-inference-eidos` |
| Praxis | `demiurge/generate-praxis` | `typos-inference-praxis` |
| Desmos | `demiurge/generate-desmos` | `typos-inference-desmos` |

Elements without generation support must be hand-authored in genesis YAML.

---

## Cross-References

- [Composite Patterns](composite-patterns.md) — How elements compose into higher-order patterns
- [Bootstrap Genesis](../genesis/bootstrap-genesis.md) — How element instances are loaded
- [Stoicheia WASM](stoicheia-wasm.md) — WASM execution model for stoicheia
- [Surface Contracts](../authorization/surface-contracts.md) — How surfaces declare topos interoperability
