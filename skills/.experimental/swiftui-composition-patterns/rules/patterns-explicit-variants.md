---
title: Create Explicit View Variants
impact: MEDIUM
impactDescription: improves readability and avoids mode branching
tags: patterns, swiftui, composition
---

## Create Explicit View Variants

Prefer explicit variants over `mode` enums or `isX` flags inside one view. Each
variant should clearly express its layout and slots.

**Incorrect (mode enum with branching):**

```swift
enum ComposerMode { case channel, thread, edit }

struct ComposerView: View {
  let mode: ComposerMode

  var body: some View {
    switch mode {
    case .channel:
      ChannelLayout()
    case .thread:
      ThreadLayout()
    case .edit:
      EditLayout()
    }
  }
}
```

**Correct (explicit view types):**

```swift
struct ChannelComposerView: View { var body: some View { ChannelLayout() } }
struct ThreadComposerView: View { var body: some View { ThreadLayout() } }
struct EditComposerView: View { var body: some View { EditLayout() } }
```

Explicit variants improve API clarity and reduce internal branching.
