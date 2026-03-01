---
title: Lift State Into Provider Views
impact: MEDIUM
impactDescription: enables sibling coordination and reusable slots
tags: state, swiftui, composition
---

## Lift State Into Provider Views

State should live in a provider view so sibling subviews can coordinate through
shared context. Avoid `@State` scattered across leaf views when the data is
shared.

**Incorrect (state trapped in leaf views):**

```swift
struct ComposerInput: View {
  @State private var text = ""

  var body: some View {
    TextField("Message", text: $text)
  }
}

struct ComposerSubmit: View {
  var body: some View {
    Button("Send") {
      // No access to input state
    }
  }
}
```

**Correct (state in provider, shared via environment):**

```swift
@Observable
@MainActor
final class ComposerStore: ComposerState, ComposerActions {
  var text: String = ""
  var isSending: Bool = false

  func updateText(_ value: String) { text = value }
  func send() { /* send */ }
}

struct ComposerProvider<Content: View>: View {
  @State private var store = ComposerStore()
  @ViewBuilder let content: Content

  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  var body: some View {
    let context = ComposerContext(state: store, actions: store, meta: .init())
    content.environment(\.composerContext, context)
  }
}
```

Lift once, share everywhere. Keeps UI components dumb and reusable.
