---
title: Use Compound Components
impact: HIGH
impactDescription: enables flexible composition without prop drilling
tags: composition, swiftui, architecture
---

## Use Compound Components

Structure complex views as compound components with shared environment. Each
subview reads shared state via `@Environment` (or `@EnvironmentObject` for
legacy code), not prop chains. Consumers compose the pieces they need.

**Incorrect (monolithic view with render closures and flags):**

```swift
struct ComposerView: View {
  let showAttachments: Bool
  let showFormatting: Bool
  let header: (() -> AnyView)?
  let footer: (() -> AnyView)?

  var body: some View {
    VStack {
      header?()
      ComposerInput()
      if showAttachments { ComposerAttachments() }
      if let footer {
        footer()
      } else {
        ComposerFooter {
          if showFormatting { ComposerFormatting() }
        }
      }
    }
  }
}
```

**Correct (compound components with shared environment):**

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
    meta: .init()
  )
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

struct ComposerProvider<Content: View>: View {
  let context: ComposerContext
  @ViewBuilder let content: Content

  init(context: ComposerContext, @ViewBuilder content: () -> Content) {
    self.context = context
    self.content = content()
  }

  var body: some View {
    content.environment(\.composerContext, context)
  }
}

struct ComposerFrame<Content: View>: View {
  @ViewBuilder let content: Content

  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  var body: some View {
    VStack { content }
  }
}

struct ComposerFooter<Content: View>: View {
  @ViewBuilder let content: Content

  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  var body: some View {
    HStack { content }
  }
}
```

Consumers compose slots instead of toggling flags. Shared state lives in the
environment and is available wherever needed.
