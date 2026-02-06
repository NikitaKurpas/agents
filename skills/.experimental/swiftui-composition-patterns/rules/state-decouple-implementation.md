---
title: Decouple State Management From UI
impact: MEDIUM
impactDescription: keeps views stable while state strategy evolves
tags: state, swiftui, composition
---

## Decouple State Management From UI

The provider is the only place that knows how state is managed. Views consume a
stable context interface (state/actions/meta). This keeps UI stable even if you
swap `@StateObject`, `@Observable`, or external stores.

**Incorrect (views bind to a concrete store type):**

```swift
struct ComposerView: View {
  @StateObject var store: ComposerStore

  var body: some View {
    VStack {
      TextField("Message", text: $store.text)
      Button("Send") { store.send() }
    }
  }
}
```

**Correct (views depend on an abstract context):**

```swift
protocol ComposerState {
  var text: String { get }
  var isSending: Bool { get }
}

protocol ComposerActions {
  func updateText(_ value: String)
  func send()
}

struct ComposerContext {
  var state: ComposerState
  var actions: ComposerActions
}

struct ComposerInput: View {
  @Environment(\.composerContext) var context

  var body: some View {
    TextField(
      "Message",
      text: Binding(
        get: { context?.state.text ?? "" },
        set: { context?.actions.updateText($0) }
      )
    )
  }
}
```

The store is created and owned by a provider view; leaf views depend only on
interfaces.
