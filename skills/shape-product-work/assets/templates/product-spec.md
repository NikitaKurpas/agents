# {Feature name}

Status: Draft | Approved | Superseded
Last updated: {YYYY-MM-DD}

Keep this product contract short enough to review in one sitting; one to three pages is the normal target. Delete optional sections unless they preserve meaningful, non-obvious context that a future reader cannot infer from the required sections or code. Include them when omitting that context would leave the reader wondering why the product works this way. Delete all placeholder instructions and leave detailed implementation choices out of the spec.

Mark uncertain claims as assumptions and unresolved choices as open questions. Approve the spec only when no blocking product questions remain. After approval, record material product changes in the change log.

## Summary

{In one short paragraph, identify the user, their problem, the proposed change, and the intended outcome.}

## Terminology (Optional)

{Define only new domain vocabulary needed by this document. Use ordinary language and vocabulary already established in the project everywhere else.}

## Problem and Evidence (Optional)

{Explain why this is worth solving now. Cite the strongest available evidence and clearly label assumptions.}

## Proposed Experience

{Describe the end-to-end experience from the user's point of view, including the most important failure or recovery path. Link mocks only when needed.}

## Scope (Optional)

### Included

- {Capability included in this version.}

### Not Included

- {Related capability deliberately excluded.}

## Constraints (Optional)

{List external product boundaries the solution must respect, such as privacy, cost, monetization, legal requirements, or supported environments. State the boundary without prescribing how the implementation satisfies it.}

- {Constraint and why it matters.}

## Acceptance

Define the observable rules and concrete scenarios that prove the product contract. Use stable identifiers that implementation and verification can reference. Include relevant edge cases and recovery behavior; keep test mechanics and commands out of the spec.

- **A1:** Given {starting state}, when {user action}, then {observable result}.
- **A2:** Given {edge state}, when {action or event}, then {result or recovery}.

## Success Signals (Optional)

{List the smallest useful qualitative or quantitative signals. Include targets only when evidence supports them, and state how they can be evaluated.}

## Visual Direction (Optional)

{Describe the intended UI character, hierarchy, layout, interaction patterns, motion, and accessibility considerations. Link visual references or mocks when they communicate the direction better than prose. Keep detailed screen specifications out of the product contract.}

## Technical Direction (Optional)

Include only high-level implementation choices the product contract intentionally controls, such as the architecture, system boundary, source of truth, data lifetime, platform capability, or required or forbidden dependency. Explain why each choice matters; leave detailed design out of the product contract. Keep external product boundaries in `Constraints` and unsettled choices in `Open Questions`.

- **Direction:** {Constraint or choice.} **Rationale:** {Why it matters.}

## Testing Direction (Optional)

{Describe the testing choices that materially shape implementation or verification. Define what makes a valuable test for this feature by naming the externally observable behavior and boundary to verify, without coupling tests to implementation details. Identify the modules that need coverage and link similar tests in the codebase when they provide useful precedent. Leave individual test cases, commands, and mechanics out of the product contract.}

## Open Questions (Optional)

- **Blocking | Non-blocking:** {Question and current options.}

## Follow-ups (Optional)

Preserve useful product ideas that were deliberately cut from this feature's current scope. Explain enough context, motivation, and open questions for future work to start without reconstructing the original discussion.

Follow-ups are not approved requirements or implementation commitments. Give a substantial follow-up its own Draft Product Spec before design or implementation begins. Add it to `TODO.md` only when the team decides to prioritize the work.

- **{Follow-up idea}:** {What the idea is, why it may be valuable, why it is not included now, and the main questions a future spec must answer.}

## Change Log (Optional)

Record changes to behavior, scope, acceptance, or constraints after review.

- {YYYY-MM-DD} — {What changed and why.}
