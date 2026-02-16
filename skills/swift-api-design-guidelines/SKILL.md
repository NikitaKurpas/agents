---
name: swift-api-design-guidelines
description: 'Expert guidance on Swift API design and naming using the Swift API Design Guidelines. Use when developers ask to design or refactor Swift APIs, choose method/property/type names, pick argument labels, write API documentation comments, review protocol naming, or enforce consistent call-site readability in Swift code.'
---

# Swift API Design Guidelines

## Overview

This skill provides practical guidance for designing Swift APIs that are clear at the call site, consistent with Swift ecosystem conventions, and easy to evolve. Use it to review API surfaces, rename declarations, choose argument labels, and align docs/comments with behavior.

## Agent Behavior Contract (Follow These Rules)

1. Prioritize "clarity at the point of use" over declaration aesthetics or minimal character count.
2. Evaluate APIs from call sites first, then declaration forms.
3. Do not suggest sweeping renames without a migration plan; prefer low-blast-radius edits.
4. Keep semantic distinctions explicit: avoid overload sets that differ only by return type or ambiguous unconstrained generics.
5. Treat argument labels as part of the API sentence; explain label choices at use sites.
6. Name according to role and side effects, not only static type information.
7. Use references for source-of-truth wording and examples; avoid inventing terminology that conflicts with established Swift precedent.

## Recommended Tools for Analysis

When reviewing Swift APIs:

1. **API Surface Discovery**
   - Use `rg` on protocol, type, and extension declarations.
   - Search for likely naming hotspots: `init(`, `func`, `subscript`, and `typealias`.
   - Search for call sites in tests/examples to validate call-site readability.

2. **Risk Discovery**
   - Find overload groups by base name.
   - Find APIs with weakly typed parameters (`Any`, `AnyObject`, `NSObject`, raw `String`/`Int`) and validate role clarity.
   - Find ambiguous boolean/property naming (`is`, `has`, `can`) for assertion-style readability.

## API Design Intake (Evaluate Before Advising)

Before proposing naming/design changes, determine:

- Public API scope vs internal-only API
- Source compatibility constraints (semver, binary stability, external clients)
- Existing naming precedent in module and Apple frameworks
- Whether call sites are expression-like (nonmutating) or command-like (mutating/side-effecting)

If compatibility constraints are unknown, ask before recommending disruptive renames.

## Quick Decision Tree

When a developer needs API-design help, follow this tree:

1. **Call site unclear or ambiguous?**
   - Start with `references/swift-api-design-guidelines.md` sections:
     - "Fundamentals"
     - "Naming -> Promote Clear Usage"

2. **Mutating vs nonmutating naming confusion?**
   - Use "Naming -> Strive for Fluent Usage" (side-effect naming pairs)

3. **Initializer/factory argument labels unclear?**
   - Use "Argument Labels" and "Parameters"

4. **Protocol/type/property naming inconsistent?**
   - Use "Naming -> Strive for Fluent Usage" and "Use Terminology Well"

5. **Large API review or style audit?**
   - Run a checklist pass using:
     - "General Conventions"
     - "Special Instructions"
     - "Best Practices Summary" in this file

## Triage-First Playbook (Common Issues -> Next Best Move)

- "Name is short but unclear"
  - Add disambiguating words. Remove only words that do not add meaning at call site.
- "Parameter meaning unclear because type is weak (`Any`/`String`/`Int`/`NSObject`)"
  - Add role noun to base name or argument label.
- "Mutating and nonmutating pair named inconsistently"
  - Apply verb + `ed`/`ing` pair, or noun + `form` mutating variant.
- "Overloads read the same but do different things"
  - Split semantic families; avoid overload-on-return-type.
- "Initializer reads like sentence fragment with awkward first label"
  - Recheck value-preserving conversion rule and first-argument labeling conventions.
- "Boolean API reads like command"
  - Rename to assertion-style (`is...`, `has...`) for nonmutating checks.

## Core Patterns Reference

### Naming by Side Effects

```swift
// Nonmutating: noun phrase
func distance(to other: Point) -> Double

// Mutating: imperative verb phrase
mutating func sort()
```

### Mutating/Nonmutating Pairing

```swift
// Verb-based
mutating func reverse()
func reversed() -> Self

mutating func stripNewlines()
func strippingNewlines() -> String

// Noun-based
func union(_ other: Set<Element>) -> Set<Element>
mutating func formUnion(_ other: Set<Element>)
```

### Argument Labeling

```swift
// Conversion: omit first label
let i = Int64(someUInt32)

// Prepositional phrase: keep label
shape.removeBoxes(havingLength: 12)

// Grammar at call site
view.dismiss(animated: false)
```

### Weak-Type Compensation

```swift
// Weakly typed; role is unclear
func add(_ observer: NSObject, for keyPath: String)

// Role-explicit and clearer
func addObserver(_ observer: NSObject, forKeyPath path: String)
```

## Reference Files

Load these files as needed:

- **`swift-api-design-guidelines.md`** - Swift API Design Guidelines reference (intro, naming, conventions, argument labels, and special instructions)

## Best Practices Summary

1. Prefer clarity at use site over brevity.
2. Use role-driven names, not type-repetition names.
3. Keep mutating and nonmutating naming pairs systematic.
4. Use argument labels to form readable call-site phrases.
5. Avoid ambiguous overload sets (especially return-type-only differences).
6. Use established terminology and avoid unnecessary abbreviations.
7. Document declaration intent and complexity where non-obvious.

## Verification Checklist (When You Change API Names/Labels)

- Validate call-site readability in real use examples/tests.
- Check for source-breaking rename impact (public API consumers).
- Check docs/comments for stale names after refactor.
- Check overload groups for new ambiguities.
- Run formatter/lint/build/test after changes.
