---
name: shape-product-work
description: "Choose and collaboratively create the right planning artifact: Product Spec, PDR, ADR, or ExecPlan. Use when the user describes a product idea or change, asks to shape or specify a feature, wants to record a durable product or technical decision, or needs an implementation handoff. Cover intake through an approved document or implementation-ready ExecPlan; do not implement the change."
---

# Shape Product Work

Turn an idea or decision into the smallest appropriate repository document, then stop at implementation handoff.

## Workflow

### 1. Inspect context

Read `docs/index.md` when it exists, the applicable bundled template, and only the code or durable docs needed to understand the request. Treat current code and tests as observed behavior, not automatically as intended behavior. Preserve the user's latest explicit decisions.

For an ExecPlan, read [references/exec-plans.md](references/exec-plans.md) completely. If the repository has its own planning instructions, read them too; repository instructions take precedence where they conflict.

### 2. Choose the document

Select by the scope and lifespan of the decision:

- **Product Spec** — what one feature should do and why. Use [assets/templates/product-spec.md](assets/templates/product-spec.md); write to `docs/specs/<slug>.md`.
- **PDR** — durable product policy that should outlive one feature. Use [assets/templates/pdr.md](assets/templates/pdr.md); write to `docs/pdrs/<slug>.md`.
- **ADR** — durable technical direction that should constrain future work. Use [assets/templates/adr.md](assets/templates/adr.md); write to `docs/adrs/<slug>.md`.
- **ExecPlan** — detailed, self-contained implementation handoff for complex or multi-step work. Use the skeleton in [references/exec-plans.md](references/exec-plans.md); write to `docs/plans/<slug>.md`.
- **No document** — small bug, mechanical edit, or already-unambiguous bounded maintenance.

Do not create every document by default. A substantial feature normally needs a Product Spec and later an ExecPlan. Add a PDR or ADR only when a decision must remain authoritative beyond that feature.

State the recommended document and brief rationale. Ask for confirmation only when another choice would materially change the workflow.

### 3. Shape it collaboratively

Do not ask questions that a quick read-only inspection can answer. Ask one focused question at a time, prioritizing blockers whose answers eliminate materially different directions; defer or omit nice-to-know questions. Resolve the problem, intended experience, scope, constraints, behavior, acceptance, and consequential trade-offs only to the degree relevant to the selected document.

When a consequential choice has multiple viable paths, present two or three options with trade-offs and recommend one. Do not manufacture alternatives when the choice is straightforward. Do not commit a document to a direction while a blocking question remains. If the user prefers to proceed, state the consequential assumptions and confirm them first.

Once the direction is sufficiently clear, restate the intended outcome, scope, key constraints, and acceptance in one to three sentences. Draft the complete Product Spec, PDR, or ADR for review, then revise it with the user. Revisit earlier decisions when feedback exposes a conflict. Remove speculative scope and anything unnecessary to satisfy the agreed outcome. In a Product Spec, keep observable behavioral rules and proof scenarios together in `Acceptance` instead of restating them in separate requirements and acceptance sections. Mark unsupported claims as assumptions and unresolved choices as open questions. Do not invent evidence, metrics, current behavior, or user decisions.

For a Product Spec, keep the normal result to one to three pages. Across all three document types, omit optional sections unless they preserve meaningful context that cannot be inferred from the required sections. Include them when a future reader could otherwise inspect the document or code and reasonably wonder why the chosen direction exists. Keep feature-scoped technical constraints in `Technical Direction`; promote only durable choices.

Write Product Specs, PDRs, and ADRs for fast reading:

- Use plain, simple, coherent, concise language, like one human talking clearly to another.
- Prefer common words, short sentences, and one main idea per sentence.
- Use only ordinary language and vocabulary already established in the project. Exceptions:
  - If a new domain term is necessary, define it in the document's `Terminology` section before relying on it.
  - Use technical terms only when they add needed precision. Explain them in plain language the first time they appear.
- Use a clear subject and verb: "The service stores the record" is easier to process than "record persistence is performed by the service."
- Use short lists for parallel facts, rules, or trade-offs instead of dense paragraphs.
- Keep exact constraints, edge cases, and acceptance meaning. Simpler wording must not weaken or remove product decisions.
- On revision, remove abstract noun phrases and repeated qualifiers the reader does not need.

Delete an unused `Terminology` section. Do not add one merely to restate common words or vocabulary the project already defines.

### 4. Keep authority clean

- Update the Product Spec when user behavior, scope, constraints, or acceptance changes.
- Create a PDR when the product rationale or policy crosses feature boundaries.
- Create an ADR when a technical choice should constrain future implementations.
- Keep incidental implementation choices and discoveries in the ExecPlan.

Link or summarize related decisions; do not duplicate full documents. If a conflict appears, surface it and resolve the authoritative document with the user.

### 5. Finalize and hand off

Do not mark a Product Spec approved until the user approves it. Before handoff, resolve all blocking questions and validate introduced links, paths, formatting, and `git diff --check`. Follow repository-specific verification instructions when present.

After an approved Product Spec, create an ExecPlan only when requested. When the ExecPlan is ready, provide a short digest covering the technical approach, consequential choices, risks or migrations, Product Spec coverage, required human verification, and any intentional deviation.

Stop there. Do not implement, dispatch another agent, commit, or push unless the user separately requests it.
