---
title: Use Compound Components
impact: HIGH
impactDescription: enables flexible composition without prop drilling
tags: composition, swiftui, architecture
---

## Use Compound Components

Structure complex views as compound components with shared environment. Each
subview reads shared state via `@Environment` or `@EnvironmentObject`, not
prop chains. Consumers compose the pieces they need.

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
struct ComposerContext {
  var state: ComposerState
  var actions: ComposerActions
  var meta: ComposerMeta
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

struct ComposerProvider<Content: View>: View {
  let context: ComposerContext
  @ViewBuilder let content: () -> Content

  var body: some View {
    content().environment(\.composerContext, context)
  }
}

struct ComposerFrame<Content: View>: View {
  @ViewBuilder let content: () -> Content

  var body: some View {
    VStack { content() }
  }
}

struct ComposerFooter<Content: View>: View {
  @ViewBuilder let content: () -> Content

  var body: some View {
    HStack { content() }
  }
}
```

Consumers compose slots instead of toggling flags. Shared state lives in the
environment and is available wherever needed.
