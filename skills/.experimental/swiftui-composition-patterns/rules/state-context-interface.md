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
protocol ComposerState {
  var text: String { get }
}

protocol ComposerActions {
  func updateText(_ value: String)
  func send()
}

struct ComposerContext {
  var state: any ComposerState
  var actions: any ComposerActions
  var meta: ComposerMeta

  static let unimplemented = ComposerContext(
    state: ComposerStatePlaceholder(),
    actions: ComposerActionsPlaceholder(),
    meta: .init(channelId: nil, isThread: false)
  )
}

struct ComposerMeta {
  var channelId: String?
  var isThread: Bool
}

private struct ComposerStatePlaceholder: ComposerState {
  var text: String {
    assertionFailure("Missing composerContext in environment")
    return ""
  }
}

private struct ComposerActionsPlaceholder: ComposerActions {
  func updateText(_ value: String) {
    assertionFailure("Missing composerContext in environment")
  }

  func send() {
    assertionFailure("Missing composerContext in environment")
  }
}

private struct ComposerContextKey: EnvironmentKey {
  static let defaultValue = ComposerContext.unimplemented
}

extension EnvironmentValues {
  var composerContext: ComposerContext {
    get { self[ComposerContextKey.self] }
    set { self[ComposerContextKey.self] = newValue }
  }
}
```

One object for the entire contract keeps usage consistent and reviewable.
