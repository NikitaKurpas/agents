---
title: Define Generic Context Interfaces
impact: MEDIUM
impactDescription: enables dependency injection and testability
tags: state, swiftui, composition
---

## Define Generic Context Interfaces

Define a context interface with `state`, `actions`, and optional `meta` so
subviews only depend on a stable contract. This enables dependency injection,
previewing, and easy replacement of state sources.

**Incorrect (implicit, ad-hoc environment values):**

```swift
extension EnvironmentValues {
  var composerText: String { ... }
  var composerIsSending: Bool { ... }
  var composerSend: () -> Void { ... }
}
```

**Correct (single structured context):**

```swift
struct ComposerContext {
  var state: ComposerState
  var actions: ComposerActions
  var meta: ComposerMeta
}

struct ComposerMeta {
  var channelId: String?
  var isThread: Bool
}

private struct ComposerContextKey: EnvironmentKey {
  static let defaultValue: ComposerContext? = nil
}

extension EnvironmentValues {
  var composerContext: ComposerContext? {
    get { self[ComposerContextKey.self] }
    set { self[ComposerContextKey.self] = newValue }
  }
}
```

One object for the entire contract keeps usage consistent and reviewable.
