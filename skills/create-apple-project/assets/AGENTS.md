# AGENTS.md

## Project Workflow

- Target Swift 6.3 or later, using modern Swift concurrency.
- Use `mise` for tools; read `mise.toml` before assuming available tools.
- Use `tuist` with `$using-tuist-generated-projects` to generate the Xcode project.
- Use `$xcodebuildmcp-cli` to build, test, run, inspect logs, and create/list/start/stop simulators.
- Use `$efficient-axe` for compact simulator UI inspection when possible.
- If AXe is blocked or incomplete, write/maintain basic UI tests using XCUIAutomation with XCTest.
- If invoking `xcodebuild` manually, always pipe output through `xcsift` (see `$xcsift`).
- Do not use `xcsift` with `xcodebuildmcp`.
- Use Swift Testing for unit tests, see `$swift-testing-pro`. Use XCTest only for UI tests.
- Use `$asc-xcode-build` to archive, export, upload, and publish to TestFlight or App Store Connect

## Commands

```bash
mise exec -- tuist generate --no-open
mise exec -- xcodebuildmcp --help
mise exec -- xcodebuildmcp tools
mise exec -- axe --help
mise exec -- asc --help
```

## Project Defaults

Xcode workspace/scheme/simulator defaults are already set in `.xcodebuildmcp/config.yaml`. `xcodebuildmcp` commands should work without explicit arguments.

## Verification

Run at minimum:

```bash
mise exec -- tuist generate --no-open
mise exec -- xcodebuildmcp --help
mise exec -- xcodebuildmcp tools
```

Then use `xcodebuildmcp` to discover schemes, if unknown, and build/test the project. If `xcodebuildmcp` cannot cover a needed build/test path, use:

```bash
xcodebuild -workspace <ProjectName>.xcworkspace -scheme <ProjectName> 2>&1 | mise exec -- xcsift -f toon
```

## Build Notes

- Prefer Tuist `buildableFolders`.
- Keep XCTest UI test targets on `"SWIFT_DEFAULT_ACTOR_ISOLATION": "nonisolated"`.
- Use Swift Testing for unit test targets.
- Keep app code on Swift 6.3+ approachable concurrency defaults.
- Prefer end-to-end verification before handoff.