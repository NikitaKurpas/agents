---
name: coding-standards
description: Apply language-agnostic coding standards when implementing, refactoring, or reviewing code, auditing or cleaning up a codebase.
---

# Coding standards

Working code is not automatically clean code.

Read the repository's instructions and `CODING_STANDARDS.md`, if it exists, first. If a rule in the repository's `CODING_STANDARDS.md` conflicts with this skill, follow the repository's rule for that conflict. Apply the rest of this skill. You MUST follow every applicable rule below; rules beginning with “Prefer” allow a justified tradeoff.

Use this file for routine coding, review, and testing. Read the references when the work needs deeper guidance.

## Decision rules

- Treat cleanliness as part of delivery. Preserve behavior, leave touched code cleaner within scope.
- Write for local reasoning. A reader should follow the code without reconstructing hidden state, wide jumps, or naming trivia.
- Use precise names and one term per concept. Rename code when vocabulary hides intent, overloads meaning, or forces comments to compensate.
- Keep functions small, focused, and at one level of abstraction. Tell the story top-down so intent appears before detail.
- Keep parameters few and meaningful. Prefer named concepts to grab-bag arguments and separate operations to boolean mode switches.
- Prefer splitting functions that both query and mutate where practical. Make mutation explicit in the operation's name and contract.
- Keep the happy path readable. Isolate error handling, invalid-state handling, and cleanup; prefer explicit optionality or typed results over null-like sentinel flow when the language supports it.
- Give each fact one owner. Derive values instead of keeping copies in sync.
- Expose behavior rather than raw/internal representation. Keep related behavior together and give each module a clear responsibility. Avoid train-wreck access and utility dumping grounds.
- Keep construction, framework, persistence, transaction, and vendor details outside business behavior. Isolate security mechanisms while keeping permission rules with the behavior they protect.
- Validate untrusted data at the boundary before using it as trusted input.
- Make public APIs small, explicit, and hard to misuse. Encode boundary logic, required order, and likely changes where readers can see them.
- Use parameters and types that make invalid inputs difficult to pass.
- Use comments for rationale, constraints, warnings, and external contracts. Do not narrate code instead of improving it. Keep them accurate as code changes.
- Treat tests as production code: readable, deterministic, and backed by proportionate validation.
- Every test MUST justify its maintenance cost. Name the behavior or contract it protects, the bug it catches, and why existing tests would miss it.
- Test behavior through the interface responsible for it. Keep expected results independent; mocks must not do the work being tested. Keep tests stable when refactoring preserves the tested contract.
- Avoid interfaces solely for tests. Mock substitution alone is not enough; require substantially simpler test setup or isolation of a third-party dependency. Expose only what the caller needs.
- Let design emerge through duplication removal, expressiveness, and minimal structure; do not add needless abstractions or infrastructure.
- Share code that has the same responsibility. Keep similar-looking code separate when it changes for different reasons.
- Prefer standard libraries, platform features, and existing dependencies over writing custom utilities where practical. Use established, well-maintained utility libraries to fill gaps without reshaping the application's design.
- Propose frameworks that would significantly simplify the code, reduce maintenance, or improve reliability or readability. Explain the benefit and the design changes before adopting them, unless already agreed.
- Add small abstractions only when they clarify responsibilities, reduce concrete duplication or change cost, hide distracting details, or make required behavior testable. Keep them limited to current needs.
- Build for current requirements. Avoid extension points, configuration, and fallback paths for very distant or uncertain needs.
- Match edge-case handling to the likelihood and impact of failure. A theoretical possibility alone does not justify complexity; rare failures with serious consequences can.
- Capture context that helps explain unexpected behavior: what happened, where, and under what conditions. Prefer enriching existing signals (e.g. logs, events, traces) over adding new ones. Each field should add useful context.
- When touching code, remove the smell that most increases change cost, but do not silently broaden the task beyond the smallest cleanup that makes the requested change safe.

## Trigger rules

- When a function mixes setup, validation, computation, and side effects, split the phases.
- When a comment explains control flow, simplify names or structure before keeping it.
- When a query hides mutation or a flag switches behavior, separate the responsibilities.
- When duplication, repeated switches, or primitive clusters reveal a shared responsibility, name the concept with a small abstraction.
- When a boundary leaks framework, vendor, or persistence details, add or strengthen a local adapter.
- When async or concurrency enters, isolate threading/scheduling policy and minimize shared mutable state, and test timing-sensitive behavior.
- When choosing utility or observability dependencies, read [dependencies.md](references/dependencies.md).
- When fixing a bug or changing behavior, add or update the test that protects the intended contract. A bug regression test must fail for the right reason before the fix and pass afterward. If you cannot run the old code, report that limitation.
- When code needs a deeper review or cleanup, read [clean-code.md](references/clean-code.md) in full.
- When test quality or coverage needs a deeper review, read [testing.md](references/testing.md) in full.
- When removing existing tests, read the [removal rules](references/testing.md#before-removing-a-test) first.
- When these rules do not settle a design or testing question, read the relevant section of [clean-code.md](references/clean-code.md) or [testing.md](references/testing.md).
- When cleanup spreads into unrelated areas, cut back to the smallest refactor, keeping the requested change safe and readable.

For a codebase audit or cleanup:

- Review the requested codebase or paths module by module, including their dependencies. Track progress until all areas are reviewed; report any blockers or gaps.
- For audits, report each finding's location and impact. For cleanup, fix the smells that most increase change cost in small, verified steps. Explain anything left for later.

## Final checklist

- Can a reader follow the change locally?
- Are names and APIs carrying the meaning without narration?
- Is mutation explicit and the happy path still clear?
- Did framework, persistence, vendor, and construction details stay behind boundaries?
- Do functions and modules have clear responsibilities?
- Does the change follow the repository's standards?
- Was cleanup justified and kept within the requested scope?
- Do tests protect the changed behavior or contract without depending on irrelevant implementation details?
- Did I inspect the final diff and run the relevant checks after the last edit?
