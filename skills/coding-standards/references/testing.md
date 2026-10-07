# Testing standards

You MUST apply these rules when writing, changing, or reviewing tests. If a rule in the repository's `CODING_STANDARDS.md` conflicts with this skill, follow the repository's rule for that conflict. Apply the rest of this skill. Review existing tests without editing them unless an audit with fixes or a cleanup is requested.

## Value bar

Every test MUST justify its maintenance cost by protecting observable behavior, catching a realistic bug, or independently checking a meaningful requirement. Passing tests and higher coverage alone do not justify a test.

## Before writing a test

Answer these questions before adding or changing a test:

1. What observable behavior, requirement, or invariant does it protect?
2. What realistic bug would make it fail?
3. Why would existing tests miss that bug?
4. Can it exercise the real interface without adding an export, flag, wrapper, or hook used only by tests?

If an answer is missing, improve the test design first.

- Test through the interface responsible for the behavior. Test another layer only when it covers a different risk, such as transport errors or cleanup.
- Prefer adding a case to an existing test over copying the same setup and assertions. When changing tests, combine repeated setup where it makes them clearer.
- Keep expected results independent of the code under test. A mock must not perform the behavior the test claims to verify.
- Make tests survive refactoring that preserves behavior. If a test checks internal structure, identify the requirement that makes that structure matter.
- For a bug fix, show that the regression test fails before the fix for the intended reason and passes afterward. If you cannot run it against the old code, report that limitation.
- Keep tests deterministic and independent. Control time, randomness, and external dependencies when they affect the result.

## Tests

- Treat tests as production-quality code.
- Keep tests clean, readable, deterministic, and maintainable.
- A test should communicate one main idea.
- Prefer simple setup and clear assertions.
- Avoid brittle tests coupled to irrelevant implementation details.
- Tests should be fast when possible.
- Tests should be isolated and order-independent.
- Tests should be self-checking.
- Add or update tests for behavior changes, bug fixes, and significant refactors.
- Do not ship code changes without proportionate validation.
- When fixing a bug, add a test that would have caught it, when feasible.

## TDD and clean test rules

- Prefer writing a failing test before production code when the behavior can be specified clearly.
- Do not write production behavior beyond what a failing test or explicit requirement justifies.
- Keep tests small enough that a failure names one behavior or one concept.
- Prefer one assert or one conceptual assertion per test when that improves clarity.
- Use test names and test data that reveal the business or technical behavior under test.
- Build a small testing vocabulary or helper DSL when repeated setup hides intent.
- Keep test code clean; dirty tests reduce the ability to change production code safely.
- Avoid tests that require multiple manual steps to run.
- Use coverage patterns to find untested risk, not as a substitute for meaningful assertions.
- Treat ignored, flaky, or skipped tests as unresolved questions.

## Integration and concurrency tests

- Add learning tests or focused integration tests for tricky external behavior.
- Test-drive architectural decisions with executable slices, not only diagrams or configuration.
- Test concurrent behavior carefully where it matters.
- Timing-sensitive tests must coordinate on observable events or a controlled clock instead of assuming elapsed sleeps prove ordering.
- Run concurrency-sensitive tests under varied thread counts, schedules, and platforms where practical.
- Treat spurious failures as possible concurrency defects until evidence says otherwise.

## Test smells

Look for:

- fragile tests
- environment-dependent tests without need
- ignored tests and insufficient boundary tests

## Junk patterns

Check new and existing tests for these patterns:

- Running code without checking a result.
- Comparing a value with itself or with a copy made the same way.
- Copying a file list, manifest, or export list into expected results without checking an independent requirement.
- Matching exact source text, imports, or strings that can change without affecting behavior.
- Checking private helpers or exact calls when a public-interface test already covers the behavior.
- Repeating the same scenario without covering a different failure.
- Keeping unused production code or extra interfaces solely for tests.
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

## Checking and reporting changes

- Run the affected tests and nearby tests that share the changed behavior or support code.
- When replacing a source-text check, exercise the behavior it was meant to protect.
- Run the repository's required formatting, validation, and review checks after the final edit.
- Keep the code under test unchanged during a test run so the result describes a known version.
- Report what changed, why it was safe, and which checks actually ran. State failures, skipped checks, and remaining uncertainty.
