---
name: coding-standards
description: Apply language-agnostic coding standards when implementing, refactoring, or reviewing code, auditing or cleaning up a codebase.
---

# Coding standards

Working code is not automatically clean code.

Read the repository's instructions and `CODING_STANDARDS.md`, if it exists, first. If a rule in the repository's `CODING_STANDARDS.md` conflicts with this skill, follow the repository's rule for that conflict. Apply the rest of this skill. You MUST follow every applicable rule below; rules beginning with “Prefer” allow a justified tradeoff.

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
- Keep construction, framework, persistence, transaction, security, and vendor details outside business behavior.
- Validate untrusted data at the boundary before using it as trusted input.
- Make public APIs small, explicit, and hard to misuse. Encode boundary logic, required order, and likely changes where readers can see them.
- Use parameters and types that make invalid inputs difficult to pass.
- Use comments for rationale, constraints, warnings, and external contracts. Do not narrate code instead of improving it. Keep them accurate as code changes.
- Treat tests as production code: readable, deterministic, aligned with the behavior or contract they protect, and backed by proportionate validation before calling the change done.
- Let design emerge through duplication removal, expressiveness, and minimal structure; do not add needless abstractions or infrastructure.
- Share code that has the same responsibility. Keep similar-looking code separate when it changes for different reasons.
- Prefer standard libraries, platform features, and existing dependencies over writing custom utiltiies where practical.
- Add abstractions only when they reduce concrete duplication or change cost.
- When touching code, remove the smell that most increases change cost, but do not silently broaden the task beyond the smallest cleanup that makes the requested change safe.

## Trigger rules

- When a function mixes setup, validation, computation, and side effects, split the phases.
- When a comment explains control flow, simplify names or structure before keeping it.
- When a query hides mutation or a flag switches behavior, separate the responsibilities.
- When duplication, repeated switches, or primitive clusters appear, name the concept with an argument object, polymorphism, special case, or other small abstraction.
- When a boundary leaks framework, vendor, or persistence details, add or strengthen a local adapter.
- When async or concurrency enters, isolate threading/scheduling policy and minimize shared mutable state, and test timing-sensitive behavior.
- When writing, changing, reviewing, or auditing tests, you MUST read [testing standards](references/testing.md). Use the audit workflow only for a requested audit or cleanup.
- When fixing a bug or changing behavior, add or update the test that protects the intended contract and meets the testing standards.
- When an API or design tradeoff needs more detail, or the work involves external boundaries, resources, or concurrency, read the relevant section of [detailed guidance](references/clean-code.md).
- When cleanup spreads into unrelated areas, cut back to the smallest refactor, keeping the requested change safe and readable.

For a codebase audit or cleanup:

- You MUST read [clean-code.md](references/clean-code.md) in full first.
- Review the requested codebase or paths module by module, including their dependencies. Track progress until all areas are reviewed; report any blockers or gaps.
- For audits, report each finding's location and impact. For cleanup, fix the smells that most increase change cost in small, verified steps. Explain anything left for later.

## Final checklist

- Can a reader follow the change locally?
- Are names and APIs carrying the meaning without narration?
- Is mutation explicit and the happy path still clear?
- Did framework, persistence, vendor, and construction details stay behind boundaries?
- Do functions and modules have clear responsibilities?
- Does the change follow the repository's standards?
- Did I remove at least one smell from the touched area?
- Do tests protect the changed behavior or contract without depending on implementation details?
- Did I inspect the final diff and run the relevant checks after the last edit?
