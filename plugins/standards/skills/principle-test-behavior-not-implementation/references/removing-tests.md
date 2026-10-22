# Removing tests

Use when checking a test for junk patterns or before deleting one.

## Junk patterns

Check new and existing tests for these patterns:

- Running code without checking a result.
- Comparing a value with itself or with a copy made the same way.
- Copying a file list, manifest, or export list into expected results without checking an independent requirement.
- Matching exact source text, imports, or strings that can change without affecting behavior.
- Checking private helpers or exact calls when a public-interface test already covers the behavior.
- Repeating the same scenario without covering a different failure.
- Keeping unused production code or exposing internal details solely for tests.
- Computing expected values with the function being tested.
- Using mocks that produce the result the real code should produce.
- Using the same mock for different APIs in a way that hides differences in their behavior.
- Supplying test data that skips the decision, state change, or ordering the test claims to check.
- Checking a data store that the code under test never writes to.
- Checking a setting or feature flag without exercising the behavior it promises.
- Passing a failure-case test because an unrelated check rejects the input first.
- Using a test name that claims more than its inputs and assertions demonstrate.

You MUST NOT add tests that match these patterns unless they independently protect a requirement described under [Tests worth keeping](#tests-worth-keeping). For existing tests, investigate before deleting: matching a pattern alone does not prove the test is unnecessary.

## Tests worth keeping

Keep tests that independently protect a real requirement, including public APIs, protocols, stored data, migrations, security, platform behavior, packaging, or architecture.

- Keep call-order checks when the order affects observable behavior.
- Keep regression tests that catch a realistic bug.
- Keep source checks when source structure is itself a requirement and the check survives unrelated renaming or reorganization.
- Keep exact text or byte comparisons when that output is part of the contract.
- Investigate tests that fail before your change as possible product bugs. Do not delete them to make the suite pass.

A slow or static test can still be valuable. Refactoring sensitivity is a reason to inspect a test, not automatic permission to remove it.

## Before removing a test

Read the applicable repository instructions, the complete test, the code it exercises, and overlapping tests. Trace enough callers and dependencies to understand the behavior. Check relevant history and how the test runs in CI. Inspect dependency code or documentation when the test relies on that dependency's behavior.

Before removing a test, you MUST record the following in the review or change description:

- The test's name and location.
- Which failures it can detect.
- Which production callers use the code it covers.
- Which remaining test covers the same risk, or why that risk no longer applies.
- Why the test and any supporting code were added.
- Which supporting code, if any, becomes unused after removal.
- The removal risk and the checks needed to verify the change.

Keep uncertain cases and report the missing evidence. Work in small groups of related changes. Remove unused test support only after checking its callers. Move useful assertions into the test responsible for that behavior. Measure success by confidence and maintainability, not deleted tests or lines.
