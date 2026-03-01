---
title: Prefer ViewBuilder Slots Over Render Closures
impact: MEDIUM
impactDescription: avoids AnyView erasure and keeps layouts composable
tags: patterns, swiftui, composition
---

## Prefer ViewBuilder Slots Over Render Closures

Avoid `renderX` closures that return `AnyView`.
Prefer `@ViewBuilder` slots and generic content parameters so composition stays
type-safe, flexible, and easier for SwiftUI to diff.

**Incorrect (render closures with AnyView):**

```swift
struct CardView: View {
  let renderHeader: (() -> AnyView)?
  let renderFooter: (() -> AnyView)?

  var body: some View {
    VStack {
      renderHeader?()
      CardBody()
      renderFooter?()
    }
  }
}
```

**Correct (typed slots with ViewBuilder):**

```swift
struct CardView<Header: View, Footer: View, Content: View>: View {
  @ViewBuilder let header: Header
  @ViewBuilder let footer: Footer
  @ViewBuilder let content: Content

  init(
    @ViewBuilder header: () -> Header,
    @ViewBuilder footer: () -> Footer,
    @ViewBuilder content: () -> Content
  ) {
    self.header = header()
    self.footer = footer()
    self.content = content()
  }

  var body: some View {
    VStack {
      header
      content
      footer
    }
  }
}
```

Typed slots keep composition expressive and avoid `AnyView` performance costs.
