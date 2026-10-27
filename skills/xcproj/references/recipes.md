# xcodeproj recipes

Command sequences that `--help` doesn't spell out, each with its gotchas. Flags beyond these are in `xcrun xcodeproj help <cmd> <subcmd>`.

## New project with an app target

```bash
xcrun xcodeproj init App.xcodeproj
xcrun xcodeproj setting set SDKROOT iphoneos
xcrun xcodeproj setting set IPHONEOS_DEPLOYMENT_TARGET 27.0
xcrun xcodeproj setting set SWIFT_VERSION 6.0
xcrun xcodeproj target add App --product-type application
xcrun xcodeproj target phase add sources --target App
xcrun xcodeproj target phase add frameworks --target App
xcrun xcodeproj target phase add resources --target App
xcrun xcodeproj group add App --filesystem-path App
xcrun xcodeproj group include --group /App --target App
xcrun xcodeproj setting set PRODUCT_BUNDLE_IDENTIFIER me.example.app --target App
```

- `init` carries no template defaults. Without `SWIFT_VERSION` the build fails; without a deployment target the app runs only on the latest OS; without a bundle ID `simctl install` rejects it.
- Add phases before including a synchronized group. In the reverse order, the new Sources phase writes per-file exclusions and nothing compiles; repair with `group include <file> --group /App --target App` per excluded file.
- The Frameworks phase is where `pkg add` links products.
- Files in a synchronized group join the target from disk, so create them on disk.

## Unit tests hosted in the app

```bash
xcrun xcodeproj target add AppTests --product-type unit-test-bundle
xcrun xcodeproj target phase add sources --target AppTests
xcrun xcodeproj group add AppTests --filesystem-path AppTests
xcrun xcodeproj group include --group /AppTests --target AppTests
xcrun xcodeproj target add-dependency AppTests App
xcrun xcodeproj setting set TEST_HOST '$(BUILT_PRODUCTS_DIR)/App.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/App' --target AppTests
xcrun xcodeproj setting set BUNDLE_LOADER '$(TEST_HOST)' --target AppTests
xcrun xcodeproj setting set --config Debug ENABLE_TESTABILITY YES
```

UI tests use `--product-type ui-test-bundle` and `TEST_TARGET_NAME App` in place of `TEST_HOST`/`BUNDLE_LOADER`.

Schemes: the one `xcodebuild` auto-generates for the app runs only the unit tests. To run UI tests from the app scheme, add a shared scheme in `xcshareddata/xcschemes`; read target IDs for it with `plutil -extract targets json -o - App.xcodeproj/project.xcproj`. An existing shared scheme needs each new target added to it.

## Build settings

```bash
xcrun xcodeproj setting set KEY value [--target App] [--config Debug]
xcrun xcodeproj setting set --config Debug SWIFT_OPTIMIZATION_LEVEL -- -Onone
xcrun xcodeproj setting set-multi OTHER_LDFLAGS -- -ObjC
xcrun xcodeproj setting unset KEY [--target App]
```

- Project level is the default; `--target` and `--config` narrow it.
- A value starting with a dash goes after a bare `--`, which ends option parsing, so `--config` comes before it.
- List settings take `set-multi`; the tool rejects the wrong setter and names the right one.

## xcconfig files

```bash
xcrun xcodeproj group add Config
xcrun xcodeproj group add-file Project.xcconfig --group /Config
xcrun xcodeproj config set Project.xcconfig --group /Config
```

The xcconfig lives in a regular group; `config set` refuses one inside a synchronized folder. `setting get` reports keys the xcconfig defines as unset. A project-level xcconfig applies to every target, so target-specific values like bundle IDs belong on the target.

## Swift packages

```bash
xcrun xcodeproj pkg add https://github.com/org/pkg --from 1.0.0 --product Pkg --target App
xcrun xcodeproj pkg add-local ../LocalPkg --product Pkg --target App
```

`--from` is up to next major. `--up-to-next-minor`, `--exact`, `--range-min`/`--range-max`, `--branch`, and `--revision` cover the other requirements. `link`, `unlink`, `link-plugin`, `unlink-plugin`, and `remove` cover the rest.

## Merge conflicts in `project.xcproj`

Sorted entries from two branches land side by side and conflict. Resolve array entries (packages, files, targets) into separate objects, one per side; a single object holding both sides' keys gets one side silently dropped by the formatter. Dictionary entries with different keys, like build settings, can stay side by side.

Alternatively, take one side whole and replay the other branch's changes with `xcodeproj`, including the parts that merged cleanly.

Then run the formatter diff from the skill and check that `target list` and `pkg list` show both branches' changes.
