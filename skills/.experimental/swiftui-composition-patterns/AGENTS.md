# SwiftUI Composition Patterns

**Version 1.0.0**  
Engineering  
January 2026

> **Note:**  
> For agents and LLMs maintaining, generating, or refactoring SwiftUI codebases
> using composition. Optimized for automation and consistency.

---

## Abstract

Composition patterns for building flexible, maintainable SwiftUI views. Avoid
flag proliferation by using compound views, lifting state, and composing
internals. These patterns make codebases easier for both humans and AI agents
to work with as they scale.

---

## Table of Contents

1. [Component Architecture](#1-component-architecture) — **HIGH**
   - 1.1 [Avoid Boolean Flag Proliferation](#11-avoid-boolean-flag-proliferation)
   - 1.2 [Use Compound Components](#12-use-compound-components)
2. [State Management](#2-state-management) — **MEDIUM**
   - 2.1 [Decouple State Management from UI](#21-decouple-state-management-from-ui)
   - 2.2 [Define Generic Context Interfaces](#22-define-generic-context-interfaces)
   - 2.3 [Lift State into Provider Views](#23-lift-state-into-provider-views)
3. [Implementation Patterns](#3-implementation-patterns) — **MEDIUM**
   - 3.1 [Create Explicit View Variants](#31-create-explicit-view-variants)
   - 3.2 [Prefer ViewBuilder Slots Over Render Closures](#32-prefer-viewbuilder-slots-over-render-closures)

---

## 1. Component Architecture

**Impact: HIGH**

Fundamental patterns for structuring views to avoid flag proliferation and
enable flexible composition.

### 1.1 Avoid Boolean Flag Proliferation

**Impact: CRITICAL (prevents unmaintainable view variants)**

Don't add boolean flags to customize behavior. Each flag multiplies state and
creates conditional sprawl. Use composition instead.

**Incorrect: flag-driven view**

```swift
struct ComposerView: View {
  let isThread: Bool
  let isEditing: Bool

  var body: some View {
    VStack {
      ComposerHeader()
      if isThread { ThreadInfo() }
      if isEditing { EditActions() } else { DefaultActions() }
    }
  }
}
```

**Correct: explicit variants**

```swift
struct ThreadComposerView: View {
  var body: some View {
    ComposerFrame {
      ComposerHeader()
      ThreadInfo()
      DefaultActions()
    }
  }
}

struct EditComposerView: View {
  var body: some View {
    ComposerFrame {
      ComposerHeader()
      EditActions()
    }
  }
}
```

### 1.2 Use Compound Components

**Impact: HIGH (enables flexible composition without prop drilling)**

Structure complex views as compound components with shared environment. Each
subview reads shared state via `@Environment` (or `@EnvironmentObject` for
legacy code).

**Incorrect: monolithic view with flags and render closures**

```swift
struct ComposerView: View {
  let showAttachments: Bool
  let renderFooter: (() -> AnyView)?

  var body: some View {
    VStack {
      ComposerInput()
      if showAttachments { ComposerAttachments() }
      renderFooter?()
    }
  }
}
```

**Correct: compound components with context**

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
```

Consumers compose slots instead of toggling flags.

---

## 2. State Management

**Impact: MEDIUM**

Patterns for lifting state and managing shared environment across composed
views.

### 2.1 Decouple State Management from UI

**Impact: MEDIUM (keeps views stable while state strategy evolves)**

Views should depend on a stable context interface, not a concrete store type.

**Incorrect: view owns store**

```swift
struct ComposerView: View {
  @State private var store = ComposerStore()

  var body: some View {
    TextField("Message", text: $store.text)
  }
}
```

**Correct: view depends on context**

```swift
protocol ComposerState { var text: String { get } }
protocol ComposerActions { func updateText(_ value: String) }

struct ComposerInput: View {
  @Environment(\.composerContext) var context

  var body: some View {
    TextField(
      "Message",
      text: Binding(
        get: { context.state.text },
        set: { context.actions.updateText($0) }
      )
    )
  }
}
```

### 2.2 Define Generic Context Interfaces

**Impact: MEDIUM (enables dependency injection and previews)**

Define a context interface with `state`, `actions`, and `meta` so subviews rely
on a stable contract.

```swift
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
```

### 2.3 Lift State into Provider Views

**Impact: MEDIUM (enables sibling coordination)**

Lift shared state into a provider view and inject via environment.

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

---

## 3. Implementation Patterns

**Impact: MEDIUM**

Specific techniques for implementing compound views and ViewBuilder slots.

### 3.1 Create Explicit View Variants

**Impact: MEDIUM (reduces mode branching)**

Avoid `isX` boolean mode flags. For finite flows, both explicit variants and
enum-driven routing can be valid. Prefer explicit variant types when you want a
clearer public API.

```swift
struct ChannelComposerView: View { var body: some View { ChannelLayout() } }
struct ThreadComposerView: View { var body: some View { ThreadLayout() } }
```

Enum-driven routing is also acceptable for finite internal flows.

### 3.2 Prefer ViewBuilder Slots Over Render Closures

**Impact: MEDIUM (avoids AnyView erasure)**

Use typed `@ViewBuilder` slots instead of `renderX` closures returning
`AnyView`.

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
    VStack { header; content; footer }
  }
}
```
