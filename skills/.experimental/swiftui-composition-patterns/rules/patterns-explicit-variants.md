---
title: Create Explicit View Variants
impact: MEDIUM
impactDescription: improves readability and avoids mode branching
tags: patterns, swiftui, composition
---

## Create Explicit View Variants

Avoid `isX` boolean mode flags. For finite flows, both explicit variants and
enum-driven routing can be valid. Prefer explicit variant types when you want a
clearer public API and reusable composition slots.

**Incorrect (boolean mode flags):**

```swift
struct ComposerView: View {
  let isThread: Bool
  let isEditing: Bool

  var body: some View {
    if isThread { ThreadLayout() }
    else if isEditing { EditLayout() }
    else { ChannelLayout() }
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

**Also acceptable (finite internal flow):**

```swift
enum ComposerMode { case channel, thread, edit }

struct ComposerRootView: View {
  let mode: ComposerMode

  var body: some View {
    switch mode {
    case .channel: ChannelLayout()
    case .thread: ThreadLayout()
    case .edit: EditLayout()
    }
  }
}
```
