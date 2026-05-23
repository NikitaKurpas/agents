---
name: create-apple-project
description: Create a new iOS, macOS, or watchOS project base with Git, mise-managed tools, Apple-agent skills, Tuist manifests, Swift Testing unit tests, buildable folders, and an AGENTS.md project instruction template. Use when Codex is asked to initialize, scaffold, bootstrap, or set up a fresh Apple platform app project.
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
noglob mise use tuist@latest github:getsentry/XcodeBuildMCP@latest github:cameroncooke/AXe[asset_pattern="AXe-macOS-*-universal.tar.gz"]@latest xcsift@latest github:rorkai/App-Store-Connect-CLI[asset_pattern="asc_*_macOS_arm64",bin="asc"]@latest
noglob mise config set tools."github:cameroncooke/AXe".asset_pattern "AXe-macOS-*-universal.tar.gz"
noglob mise config set tools."github:rorkai/App-Store-Connect-CLI".asset_pattern "asc_*_macOS_arm64"
mise config set tools."github:rorkai/App-Store-Connect-CLI".bin asc
```

4. Install skills with `npx skills add`. Escalate these commands when sandbox/network access blocks them:

```bash
npx skills add cameroncooke/axe --skill axe --agent codex --yes
npx skills add git@github.com:NikitaKurpas/agents.git --skill efficient-axe --agent codex --yes
npx skills add tuist/agent-skills --skill using-tuist-generated-projects --agent codex --yes
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
Tuist/
<ProjectName>/Sources/
<ProjectName>/Resources/
<ProjectName>/Tests/
<ProjectName>/UITests/
```

6. Add `Tuist/Package.swift`, `Tuist.swift`, `Project.swift`, and `AGENTS.md` using the templates below.
7. Add a minimal app entry point, Swift Testing unit tests, and XCUIAutomation UI tests appropriate to the platform.
8. Run `mise exec -- tuist generate --no-open`.

## Tuist Templates

`Tuist/Package.swift`:

```swift
// swift-tools-version: 6.0
import PackageDescription

#if TUIST
    import struct ProjectDescription.PackageSettings

    let packageSettings = PackageSettings(
        // Customize the product types for specific package product
        // Default is .staticFramework
        // productTypes: ["Alamofire": .framework,]
        productTypes: [:]
    )
#endif

let package = Package(
    name: "<project name>",
    dependencies: [
        // Add your own dependencies here:
        // .package(url: "https://github.com/Alamofire/Alamofire", from: "5.0.0"),
    ]
)
```

`Tuist.swift`:

```swift
import ProjectDescription

let tuist = Tuist(project: .tuist())
```

`Project.swift`:

Only add targets required for the app. Do not include iOS, macOS, and watchOS targets unless the user requested a multi-platform app. Adjust the watchOS target's `infoPlist` if the iOS companion app is required.

```swift
import ProjectDescription

// All test targets that use XCTest must set "SWIFT_DEFAULT_ACTOR_ISOLATION": "nonisolated".
// This does not apply to test targets that use Swift Testing.

let project = Project(
    name: "<project name>",
    settings: .settings(
        base: [
            "ENABLE_USER_SCRIPT_SANDBOXING": "YES",
            "SWIFT_APPROACHABLE_CONCURRENCY": "YES",
            "SWIFT_DEFAULT_ACTOR_ISOLATION": "MainActor",
            "COMPILATION_CACHE_ENABLE_CACHING": "YES",
            "ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS": "YES",
            "STRING_CATALOG_GENERATE_SYMBOLS": "YES",
        ]
        .swiftVersion("6.2")
        .automaticCodeSigning(devTeam: "FC235PA96B")
        .codeSignIdentityAppleDevelopment(),
        debug: [
            "SWIFT_COMPILATION_MODE": "singlefile"
        ],
        release: [
            "SWIFT_COMPILATION_MODE": "wholemodule"
        ]
    ),
    targets: [
        // iOS app target example. Include only for iOS apps.
        .target(
            name: "<project name>",
            destinations: .iOS,
            product: .app,
            bundleId: "me.kurpas.<project bundle id>",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            buildableFolders: [
                "<project name>/Sources",
                "<project name>/Resources",
            ],
            dependencies: []
        ),
        // macOS app target example. Include only for macOS apps.
        .target(
            name: "<project name>",
            destinations: .macOS,
            product: .app,
            bundleId: "me.kurpas.<project bundle id>",
            infoPlist: .default,
            buildableFolders: [
                "<project name>/Sources",
                "<project name>/Resources",
            ],
            dependencies: []
        ),
        // watchOS app target example. Include only for watchOS apps.
        .target(
            name: "<project name>",
            destinations: .watchOS,
            product: .app,
            bundleId: "me.kurpas.<project bundle id>",
            infoPlist: .extendingDefault(
                with: [
                    "WKApplication": true,
                    "WKWatchOnly": true,
                ]
            ),
            buildableFolders: [
                "<project name>/Sources",
                "<project name>/Resources",
            ],
            dependencies: []
        ),
        .target(
            name: "<project name>Tests",
            destinations: <same destinations as app target>,
            product: .unitTests,
            bundleId: "me.kurpas.<project bundle test id>",
            infoPlist: .default,
            buildableFolders: [
                "<project name>/Tests"
            ],
            dependencies: [.target(name: "<project name>")]
        ),
        .target(
            name: "<project name>UITests",
            destinations: <same destinations as app target>,
            product: .uiTests,
            bundleId: "me.kurpas.<project bundle ui test id>",
            infoPlist: .default,
            buildableFolders: [
                "<project name>/UITests"
            ],
            dependencies: [.target(name: "<project name>")],
            settings: .settings(
                base: ["SWIFT_DEFAULT_ACTOR_ISOLATION": "nonisolated"],
                defaultSettings: .essential
            ),
        ),
        // any other targets as needed
    ],
    schemes: [
        .scheme(
            name: "<project name>",
            shared: true,
            buildAction: .buildAction(targets: [
                "<project name>",
                "<project name>Tests",
                "<project name>UITests",
            ]),
            testAction: .targets([
                "<project name>Tests",
                "<project name>UITests",
            ])
        ),
    ]
)
```

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

First, list all available simulators to find the name and ID of the latest simulator for the primary platform (or use at least iPhone 17/Apple Watch Series 11).

Then, copy the following template to the project root as `.xcodebuildmcp/config.yaml`:
```yaml
schemaVersion: 1
debug: false
sentryDisabled: false
sessionDefaults:
  workspacePath: <relative path to the Tuist-generated .xcworkspace file>
  scheme: <scheme name>
  simulatorId: <iPhone/Apple Watch simulator id>
  simulatorName: <iPhone/Apple Watch simulator name>
  ```

## Finalize

If the project compiles, check the file status, make sure the right files are included, then commit everything.