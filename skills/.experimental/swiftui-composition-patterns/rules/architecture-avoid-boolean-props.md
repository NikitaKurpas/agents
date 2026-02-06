---
title: Avoid Boolean Prop Proliferation
impact: CRITICAL
impactDescription: prevents unmaintainable view variants
tags: composition, swiftui, architecture
---

## Avoid Boolean Prop Proliferation

Don't add boolean flags like `isThread`, `isEditing`, `isDMThread` to customize
view behavior. Each flag multiplies states and creates conditional sprawl. Use
composition instead.

**Incorrect (flags create exponential complexity):**

```swift
struct ComposerView: View {
  let isThread: Bool
  let channelId: String?
  let isDMThread: Bool
  let dmId: String?
  let isEditing: Bool
  let isForwarding: Bool

  var body: some View {
    VStack {
      ComposerHeader()
      ComposerInput()
      if isDMThread, let dmId {
        AlsoSendToDMField(id: dmId)
      } else if isThread, let channelId {
        AlsoSendToChannelField(id: channelId)
      }

      if isEditing {
        EditActions()
      } else if isForwarding {
        ForwardActions()
      } else {
        DefaultActions()
      }
    }
  }
}
```

**Correct (composition eliminates conditionals):**

```swift
struct ChannelComposerView: View {
  var body: some View {
    ComposerFrame {
      ComposerHeader()
      ComposerInput()
      ComposerFooter {
        ComposerAttachments()
        ComposerFormatting()
        ComposerEmojis()
        ComposerSubmit()
      }
    }
  }
}

struct ThreadComposerView: View {
  let channelId: String

  var body: some View {
    ComposerFrame {
      ComposerHeader()
      ComposerInput()
      AlsoSendToChannelField(id: channelId)
      ComposerFooter {
        ComposerFormatting()
        ComposerEmojis()
        ComposerSubmit()
      }
    }
  }
}

struct EditComposerView: View {
  var body: some View {
    ComposerFrame {
      ComposerInput()
      ComposerFooter {
        ComposerFormatting()
        ComposerEmojis()
        ComposerCancelEdit()
        ComposerSaveEdit()
      }
    }
  }
}
```

Each variant is explicit about what it renders. We can share internals without
a single monolithic parent view.
