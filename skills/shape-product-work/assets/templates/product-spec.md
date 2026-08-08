# {Feature name}

Status: Draft | Approved | Superseded
Last updated: {YYYY-MM-DD}

Keep this product contract short enough to review in one sitting; one to three pages is the normal target. Delete unused optional sections and all placeholder instructions. Leave implementation details to the ExecPlan.

Mark uncertain claims as assumptions and unresolved choices as open questions. Approve the spec only when no blocking product questions remain. After approval, record material product changes in the change log and update the ExecPlan.

## Summary

{In one short paragraph, identify the user, their problem, the proposed change, and the intended outcome.}

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

{List boundaries that shape the product, such as privacy, cost, monetization, compatibility, legal requirements, or platform limitations.}

- {Constraint and why it matters.}

## Product Requirements (Optional)

Use stable identifiers for observable rules that the ExecPlan and verification need to reference. Include only relevant edge cases and constraints.

- **R1:** {When or while a user does X, the product does Y.}
- **R2:** {If Z prevents the normal path, the user experiences A.}

## Acceptance

Define concrete scenarios that prove the product contract. Keep test mechanics and commands in the ExecPlan.

- **A1:** Given {starting state}, when {user action}, then {observable result}.
- **A2:** Given {edge state}, when {action or event}, then {result or recovery}.

## Success Signals (Optional)

{List the smallest useful qualitative or quantitative signals. Include targets only when evidence supports them, and state how they can be evaluated.}

## Product Decisions and Trade-offs (Optional)

Include only decisions needed to understand the product contract. Move durable, cross-feature policy to a PDR.

- **Decision:** {Choice.} **Rationale:** {Why.} **Consequence:** {Cost or limit.}

## Technical Direction (Optional)

Include only high-level choices you want to control, such as the architecture, system boundary, source of truth, data lifetime, privacy, compatibility, platform capability, or required or forbidden dependency. Explain why each matters; leave detailed design to the ExecPlan. Keep unsettled choices in `Open Questions`.

- **Direction:** {Constraint or choice.} **Rationale:** {Why it matters.}

## Open Questions (Optional)

- **Blocking | Non-blocking:** {Question and current options.}

## Follow-ups (Optional)

Preserve useful product ideas that were deliberately cut from this feature's current scope. Explain enough context, motivation, and open questions for future work to start without reconstructing the original discussion.

Follow-ups are not approved requirements or implementation commitments. Give a substantial follow-up its own Draft Product Spec before design or implementation begins. Add it to `TODO.md` only when the team decides to prioritize the work.

- **{Follow-up idea}:** {What the idea is, why it may be valuable, why it is not included now, and the main questions a future spec must answer.}

## Change Log (Optional)

Record changes to behavior, scope, acceptance, or constraints after review.

- {YYYY-MM-DD} — {What changed and why.}
