---
name: shape-product-work
description: >
  Shape product ideas and durable decisions into the smallest appropriate
  Product Spec, PDR, ADR, ExecPlan, or no document. Use when asked to specify a
  feature, record product or technical direction, or create an implementation
  handoff. Do not invoke for ordinary implementation.
---

# Shape Product Work

Turn the request into the smallest useful planning artifact, then hand it off.

## 1. Choose the artifact

Read `docs/index.md` when it exists and only relevant code and durable decisions.
Treat code and tests as observed behavior, not intended behavior. Preserve the
user's latest explicit decisions.

- **Product Spec:** one feature's intended behavior and acceptance. Use [the template](assets/templates/product-spec.md); write to `docs/specs/<slug>.md`.
- **PDR:** durable product policy beyond one feature. Use [the template](assets/templates/pdr.md); write to `docs/pdrs/<slug>.md`.
- **ADR:** durable technical direction. Use [the template](assets/templates/adr.md); write to `docs/adrs/<slug>.md`.
- **ExecPlan:** self-contained implementation handoff for complex work; write to `docs/plans/<slug>.md`.
- **No document:** small fixes, mechanical edits, or unambiguous maintenance.

Read the selected template. For an ExecPlan, read repository planning instructions
and [the bundled guide](references/exec-plans.md) completely; repository
instructions win conflicts.

Recommend one with a brief rationale. Confirm only when another choice would
materially change the workflow. Create only what the request needs.

## 2. Resolve decisions and draft

Answer what inspection can establish. Ask one focused question at a time, only
when the answer materially changes the outcome. When multiple consequential paths
are viable, give two or three options with trade-offs and recommend one. State and
confirm consequential assumptions before drafting. Resolve every blocking choice.

Restate the outcome, scope, constraints, and acceptance in one to three sentences.
Draft the complete artifact for review, then revise it with the user. Distinguish
observed behavior, intended behavior, assumptions, and open questions. Use only
supported evidence and metrics.

In Product Specs, keep behavioral rules and proof scenarios together in
`Acceptance`, and feature-scoped technical constraints in `Technical Direction`.
Use `Terminology` only for necessary new domain terms. Omit optional sections
unless they preserve non-obvious context a future reader needs.

Write plain, concrete prose with common project vocabulary, short sentences, and
one main idea per sentence. Prefer clear subjects and active verbs. Use short
lists for parallel facts, rules, or trade-offs. Use technical terms only for
needed precision and explain them on first use. Preserve exact constraints and
edge cases; remove needless qualifiers and repetition without weakening decisions.

Link related records instead of repeating them. Resolve consequential conflicts
with the user.

## 3. Finalize and hand off

Mark a Product Spec approved only after user approval. Validate introduced links,
paths, and `git diff --check`; follow relevant repository verification instructions.
Report remaining open questions.

Create an ExecPlan when requested; summarize its approach, risks, acceptance, and
required human checks. The shaping workflow ends at handoff. If the request also
includes implementation, continue afterward under the repository's implementation
workflow. Dispatch agents, commit, or publish only when authorized.
