---
name: create-apple-project
description: Create a new iOS, macOS, or watchOS project base with Git, mise-managed tools, Apple-agent skills, Swift Testing unit tests, buildable folders, and an AGENTS.md project instruction template. Use when Codex is asked to initialize, scaffold, bootstrap, or set up a fresh Apple platform app project.
disable-model-invocation: true
---

# Create Apple Project

IMPORTANT: execute each step individually to surface potential errors early, i.e. don't use `&&` to collapse all commands in this file.

## Inputs

Get or infer:

- Project directory under `~/Developer`.
- Project display name, e.g. `BlackIron`.
- Bundle slug, e.g. `black-iron`; use lower kebab/camel only for bundle ids.
- Platform: `ios`, `macos`, `watchos`, or multiple; if `watchos` - is `ios` companion app required or not.

If platform or project name is unclear, ask before creating files.

## Workflow

1. Create/enter the project directory.
2. Initialize Git and rename branch to `main`:

```bash
git init
git branch -M main
```

3. Install tools with `mise use`. This usually needs escalation because mise writes outside the project sandbox:

```bash
mise settings -l lockfile=true
noglob mise use github:getsentry/XcodeBuildMCP@latest github:cameroncooke/AXe[asset_pattern="AXe-macOS-*-universal.tar.gz"]@latest xcsift@latest github:rorkai/App-Store-Connect-CLI[asset_pattern="asc_*_macOS_arm64",bin="asc"]@latest
noglob mise config set tools."github:cameroncooke/AXe".asset_pattern "AXe-macOS-*-universal.tar.gz"
noglob mise config set tools."github:rorkai/App-Store-Connect-CLI".asset_pattern "asc_*_macOS_arm64"
mise config set tools."github:rorkai/App-Store-Connect-CLI".bin asc
```

4. Install skills with `npx skills add`. Escalate these commands when sandbox/network access blocks them:

```bash
npx skills add cameroncooke/axe --skill axe --agent codex --yes
npx skills add git@github.com:NikitaKurpas/agents.git --skill efficient-axe --agent codex --yes
npx skills add git@github.com:NikitaKurpas/agents.git --skill xcproj --agent codex --yes
npx skills add getsentry/xcodebuildmcp --skill xcodebuildmcp-cli --agent codex --yes
npx skills add https://github.com/ldomaradzki/xcsift/tree/master/plugins/codex --agent codex --yes
npx skills add twostraws/Swift-Testing-Agent-Skill --skill swift-testing-pro --agent codex --yes
npx skills add twostraws/Swift-Concurrency-Agent-Skill --skill swift-concurrency-pro --agent codex --yes
npx skills add rorkai/app-store-connect-cli-skills --skill asc-xcode-build --agent codex --yes
```

If the project will use SwiftData, also add the SwiftData skill:

```bash
npx skills add twostraws/SwiftData-Agent-Skill --skill swiftdata-pro --agent codex --yes
```

5. Create folders:

```text
<ProjectName>/Sources/
<ProjectName>/Resources/
<ProjectName>/Tests/
<ProjectName>/UITests/
```

6. Add a minimal app entry point, Swift Testing unit tests, and XCUIAutomation UI tests appropriate to the platform. The files must exist before step 7 links their folders.
7. Create the Xcode project in the JSON format with `xcrun xcodeproj`, following `$xcproj` and the commands below.
8. Copy `AGENTS.md` from the template below.

## Xcode Project

Run from the project root. Each command is one `xcodeproj` call. Replace `<Name>` with the project name and `<bundle id>` with the bundle slug.

Project-level settings, shared by every target:

```bash
xcrun xcodeproj init <Name>.xcodeproj
xcrun xcodeproj setting set SWIFT_VERSION 6.0
xcrun xcodeproj setting set SWIFT_APPROACHABLE_CONCURRENCY YES
xcrun xcodeproj setting set SWIFT_DEFAULT_ACTOR_ISOLATION MainActor
xcrun xcodeproj setting set ENABLE_USER_SCRIPT_SANDBOXING YES
xcrun xcodeproj setting set COMPILATION_CACHE_ENABLE_CACHING YES
xcrun xcodeproj setting set ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS YES
xcrun xcodeproj setting set STRING_CATALOG_GENERATE_SYMBOLS YES
xcrun xcodeproj setting set CODE_SIGN_STYLE Automatic
xcrun xcodeproj setting set DEVELOPMENT_TEAM FC235PA96B
xcrun xcodeproj setting set CODE_SIGN_IDENTITY "Apple Development"
xcrun xcodeproj setting set --config Debug SWIFT_COMPILATION_MODE singlefile
xcrun xcodeproj setting set --config Release SWIFT_COMPILATION_MODE wholemodule
xcrun xcodeproj setting set --config Debug ENABLE_TESTABILITY YES
xcrun xcodeproj setting set ALWAYS_SEARCH_USER_PATHS NO
```

Platform settings. Use the current SDK's major version with `.0` as the deployment target unless the user names one; a minor version like `27.2` won't run on older simulator runtimes.

| Platform | Settings |
| --- | --- |
| iOS | `SDKROOT iphoneos`, `IPHONEOS_DEPLOYMENT_TARGET <v>`, `TARGETED_DEVICE_FAMILY 1,2` |
| macOS | `SDKROOT macosx`, `MACOSX_DEPLOYMENT_TARGET <v>` |
| watchOS | `SDKROOT watchos`, `WATCHOS_DEPLOYMENT_TARGET <v>`, `TARGETED_DEVICE_FAMILY 4` |
| Multi-platform | `SDKROOT auto`, `SUPPORTED_PLATFORMS` with each platform and its simulator (e.g. `"iphoneos iphonesimulator macosx"`), plus each platform's deployment target |

Only add platforms the user requested.

Targets. Add build phases before including folders; otherwise Xcode writes per-file exclusions and nothing compiles:

```bash
xcrun xcodeproj target add <Name> --product-type application
xcrun xcodeproj target phase add sources --target <Name>
xcrun xcodeproj target phase add frameworks --target <Name>
xcrun xcodeproj target phase add resources --target <Name>
xcrun xcodeproj target add <Name>Tests --product-type unit-test-bundle
xcrun xcodeproj target phase add sources --target <Name>Tests
xcrun xcodeproj target add <Name>UITests --product-type ui-test-bundle
xcrun xcodeproj target phase add sources --target <Name>UITests
xcrun xcodeproj target add-dependency <Name>Tests <Name>
xcrun xcodeproj target add-dependency <Name>UITests <Name>
```

Synchronized folders:

```bash
xcrun xcodeproj group add <Name>
xcrun xcodeproj group add Sources --parent /<Name> --filesystem-path Sources
xcrun xcodeproj group add Resources --parent /<Name> --filesystem-path Resources
xcrun xcodeproj group add Tests --parent /<Name> --filesystem-path Tests
xcrun xcodeproj group add UITests --parent /<Name> --filesystem-path UITests
xcrun xcodeproj group include --group /<Name>/Sources --target <Name>
xcrun xcodeproj group include --group /<Name>/Resources --target <Name>
xcrun xcodeproj group include --group /<Name>/Tests --target <Name>Tests
xcrun xcodeproj group include --group /<Name>/UITests --target <Name>UITests
```

Target settings:

```bash
xcrun xcodeproj setting set PRODUCT_BUNDLE_IDENTIFIER me.kurpas.<bundle id> --target <Name>
xcrun xcodeproj setting set PRODUCT_BUNDLE_IDENTIFIER me.kurpas.<bundle id>.tests --target <Name>Tests
xcrun xcodeproj setting set TEST_HOST '$(BUILT_PRODUCTS_DIR)/<Name>.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/<Name>' --target <Name>Tests
xcrun xcodeproj setting set BUNDLE_LOADER '$(TEST_HOST)' --target <Name>Tests
xcrun xcodeproj setting set PRODUCT_BUNDLE_IDENTIFIER me.kurpas.<bundle id>.uitests --target <Name>UITests
xcrun xcodeproj setting set TEST_TARGET_NAME <Name> --target <Name>UITests
# XCTest UI tests can't run on MainActor default isolation; Swift Testing targets keep it.
xcrun xcodeproj setting set SWIFT_DEFAULT_ACTOR_ISOLATION nonisolated --target <Name>UITests
```

App target Info.plist keys, per platform:

- iOS: `INFOPLIST_KEY_UILaunchScreen_Generation YES`.
- watchOS: `INFOPLIST_KEY_WKApplication YES`, plus `INFOPLIST_KEY_WKWatchOnly YES` without an iOS companion, or `INFOPLIST_KEY_WKCompanionAppBundleIdentifier me.kurpas.<bundle id>` with one.

Check the result:

```bash
xcrun xcprojformatter <Name>.xcodeproj | diff <Name>.xcodeproj/project.xcproj -
xcrun xcodeproj target list
```

The diff must print nothing.

## Shared Scheme

`xcodeproj` doesn't create schemes, and the scheme `xcodebuild` auto-generates for the app runs only the unit tests. Copy `./assets/scheme.xcscheme` to `<Name>.xcodeproj/xcshareddata/xcschemes/<Name>.xcscheme` and replace `<Name>`, `<APP_ID>`, `<TESTS_ID>`, and `<UITESTS_ID>`. Read each target's ID from the project file:

```bash
plutil -extract targets json -o - <Name>.xcodeproj/project.xcproj
```

Each entry has `name` and `id`. Then confirm `xcodebuild -list -project <Name>.xcodeproj` shows the scheme.

## Test Source Rules

Unit tests must use Swift Testing:

```swift
import Testing
@testable import <project name>

@Test
func example() {
    #expect(true)
}
```

UI tests must use XCTest/XCUIAutomation:

```swift
import XCTest

final class <project name>UITests: XCTestCase {
    @MainActor
    func testLaunches() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.exists)
    }
}
```

## .gitignore Template

Copy the `./assets/gitignore` template to the new project root as `.gitignore`.

## AGENTS.md Template

Copy the `./assets/AGENTS.md` template to the new project root as `AGENTS.md`.

## XcodebuildMCP Config

First, list all available simulators to find the name and ID of the latest simulator for the primary platform (or use at least iPhone 17/Apple Watch Series 11). Its runtime must be at or above the deployment target.

Then, copy the following template to the project root as `.xcodebuildmcp/config.yaml`:

```yaml
schemaVersion: 1
debug: false
sentryDisabled: false
sessionDefaults:
  projectPath: <relative path to the .xcodeproj>
  scheme: <scheme name>
  simulatorId: <iPhone/Apple Watch simulator id>
  simulatorName: <iPhone/Apple Watch simulator name>
```

## Finalize

If the project compiles, check the file status, make sure the right files are included, then commit everything.
