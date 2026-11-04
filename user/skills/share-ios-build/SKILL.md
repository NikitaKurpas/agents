---
name: share-ios-build
description: Share an iOS app build as an over-the-air install link with AppShare. Use when the user asks for a link to install the app, an install link, or to share, send, or distribute a build, or mentions AppShare. Not for running or debugging the app on a connected device or simulator; use Xcode for that.
---

# Share an iOS build with AppShare

Run the helper by its full path, `<skill-dir>/bin/appshare`, where `<skill-dir>` is this file's
directory. It needs network access to the AppShare server and its storage, Keychain access, and read
access to the IPA. If your sandbox blocks any of these, request them.

## When

- Use it for install links and sharing: "give me a link to install the app", "share the build".
- Don't use it to run the app on a connected device or simulator; use Xcode. If unclear, such as
  "put it on my phone", ask: install link or direct run?
- Inspecting or validating an IPA doesn't authorize uploading it.

## Share

1. Build an Ad Hoc IPA with the project's own build, such as a script or fastlane lane. Without one:

   ```sh
   xcodebuild archive -allowProvisioningUpdates -scheme "$SCHEME" -configuration Release \
     -destination generic/platform=iOS -archivePath "$TMP/App.xcarchive"
   xcodebuild -exportArchive -allowProvisioningUpdates -archivePath "$TMP/App.xcarchive" \
     -exportPath "$TMP/export" -exportOptionsPlist "$TMP/ExportOptions.plist"
   ```

   In `ExportOptions.plist`, set `method` to `release-testing` (`ad-hoc` on older Xcode) and
   `signingStyle` to `automatic`. Add `-workspace` or `-project` if needed, and ask if the scheme is
   unclear. If signing fails, explain the fix, such as signing in to Xcode. Never edit signing
   settings.

2. Share it:

   ```sh
   <skill-dir>/bin/appshare share "$IPA" --label "<branch> @ <short sha>" --description "<what changed>"
   ```

   The label is one line of at most 100 characters. The description is one or two sentences of at
   most 500 characters. Anyone with the link sees both, so include no secrets.

3. From the JSON output, report the link, the version as `1.4 (27)` (omit missing parts), the label,
   and the expiry. Note that anyone with the link can open it, and installing needs a device
   registered in the build's profile.

## Connect

If the helper says it isn't connected or the secret is rejected, ask the user to run
`<skill-dir>/bin/appshare login --server https://appshare.fly.dev` in their own terminal, showing
the full path. Never ask for the secret in chat.

## Manage

Use `list`, `show <id>`, and `delete <id>`, by full path. Delete only when explicitly asked, after
confirming the exact build with `list` or `show`.

Never show the owner secret, presigned URLs, device UDIDs, or raw helper output.
