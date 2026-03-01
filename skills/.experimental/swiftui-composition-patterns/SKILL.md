---
name: swiftui-composition-patterns
description:
  SwiftUI composition patterns that scale. Use when refactoring views with
  flag proliferation, building reusable view APIs, or designing flexible view
  architecture. Triggers on tasks involving compound views, environment-based
  state sharing, or ViewBuilder slot design.
license: MIT
metadata:
  author: vercel (adapted)
  version: '1.0.0'
---

# SwiftUI Composition Patterns

Composition patterns for building flexible, maintainable SwiftUI views. Avoid
flag/boolean parameter proliferation by using compound views, lifting state,
and composing internals. These patterns make codebases easier for both humans
and AI agents to work with as they scale.

## When to Apply

Reference these guidelines when:

- Refactoring views with many boolean flags or mode enums
- Building reusable view libraries
- Designing flexible view APIs
- Reviewing SwiftUI view architecture
- Working with compound views or environment-based state sharing

## Rule Categories by Priority

| Priority | Category                | Impact | Prefix          |
| -------- | ----------------------- | ------ | --------------- |
| 1        | Component Architecture  | HIGH   | `architecture-` |
| 2        | State Management        | MEDIUM | `state-`        |
| 3        | Implementation Patterns | MEDIUM | `patterns-`     |

## Quick Reference

### 1. Component Architecture (HIGH)

- `architecture-avoid-boolean-props` - Don't add boolean flags to customize
  behavior; use composition
- `architecture-compound-components` - Structure complex views as compound
  components with shared environment

### 2. State Management (MEDIUM)

- `state-decouple-implementation` - Provider is the only place that knows how
  state is managed
- `state-context-interface` - Define generic interfaces with state, actions,
  meta for dependency injection
- `state-lift-state` - Move state into provider views for sibling access

### 3. Implementation Patterns (MEDIUM)

- `patterns-explicit-variants` - Avoid boolean mode flags; use explicit
  variants when API clarity matters (enum routing is also valid for finite
  internal flows)
- `patterns-children-over-render-props` - Prefer ViewBuilder slots and child
  views over renderX-style closures or AnyView erasure

## How to Use

Read individual rule files for detailed explanations and code examples:

```
rules/architecture-avoid-boolean-props.md
rules/state-context-interface.md
```

Each rule file contains:

- Brief explanation of why it matters
- Incorrect code example with explanation
- Correct code example with explanation
- Additional context and references

## Full Compiled Document

For the complete guide with all rules expanded: `AGENTS.md`
