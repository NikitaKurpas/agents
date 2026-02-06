# SwiftUI Composition Patterns

A structured repository for SwiftUI composition patterns that scale. These
patterns help avoid flag proliferation by using compound views, lifting state,
and composing internals.

## Structure

- `rules/` - Individual rule files (one per rule)
  - `_sections.md` - Section metadata (titles, impacts, descriptions)
  - `_template.md` - Template for creating new rules
  - `area-description.md` - Individual rule files
- `metadata.json` - Document metadata (version, organization, abstract)
- **`AGENTS.md`** - Compiled output (generated)

## Rules

### Component Architecture (CRITICAL)

- `architecture-avoid-boolean-props.md` - Don't add boolean flags to customize
  behavior
- `architecture-compound-components.md` - Structure as compound views with
  shared environment

### State Management (HIGH)

- `state-lift-state.md` - Lift state into provider views
- `state-context-interface.md` - Define clear context interfaces
  (state/actions/meta)
- `state-decouple-implementation.md` - Decouple state management from UI

### Implementation Patterns (MEDIUM)

- `patterns-children-over-render-props.md` - Prefer ViewBuilder slots and child
  views over renderX closures or AnyView erasure
- `patterns-explicit-variants.md` - Create explicit view variants

## Core Principles

1. **Composition over configuration** — Instead of adding flags, let consumers
   compose
2. **Lift your state** — State in provider views, not trapped in leaves
3. **Compose your internals** — Subviews access environment, not prop chains
4. **Explicit variants** — Create `ThreadComposerView`, `EditComposerView`, not
   `ComposerView` with `isThread`

## Creating a New Rule

1. Copy `rules/_template.md` to `rules/area-description.md`
2. Choose the appropriate area prefix:
   - `architecture-` for Component Architecture
   - `state-` for State Management
   - `patterns-` for Implementation Patterns
3. Fill in the frontmatter and content
4. Ensure you have clear examples with explanations

## Impact Levels

- `CRITICAL` - Foundational patterns, prevents unmaintainable code
- `HIGH` - Significant maintainability improvements
- `MEDIUM` - Good practices for cleaner code
