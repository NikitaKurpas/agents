---
name: product-context
description: >
  Create or update a project's PRODUCT.md, its durable product record: users, purpose, positioning, constraints, evidence, principles. Use when asked to create, capture, or refresh product context, or when work is blocked on product facts the repository doesn't state. Not for single-feature specs or visual design.
---

# Product Context

Capture durable product truth in `PRODUCT.md`. This records who the product is for and what it must preserve. It does not choose a visual direction, and it does not specify one feature.

Adapted from the `init` flow in [pbakaus/impeccable](https://github.com/pbakaus/impeccable).

## 1. Load current state

Find an existing `PRODUCT.md` (project root, or the nearest ancestor in a monorepo). Update it rather than creating a competing one. In a child app that inherits a root record, confirm whether a fact is shared or app-specific before writing.

- **No PRODUCT.md:** explore, interview, write it.
- **PRODUCT.md exists:** ask what is stale or missing. Don't reopen confirmed fields without a reason.
- **Legacy PRODUCT.md (no `## Platform`):** add only durable missing facts; treat the platform as `web` unless evidence says otherwise.
- **Redesign or rebrand:** keep confirmed product truth unless the user changes it.

Never overwrite an existing file silently.

## 2. Explore before asking

Scan enough that the user doesn't repeat known facts: README and product docs, copy, package and config files, app boundaries, features, routes, roles, names, logos, proof assets, brand commitments, and platform and accessibility signals.

Treat repository evidence as a hypothesis, not approval. Form a platform hypothesis: `web`, `ios`, `android`, or `adaptive` (one product that deliberately adapts to each OS). Mobile web is `web`. A native wrapper around a website is still `web`.

## 3. Interview for product truth

Ask with Codex's structured user-input/question tool when available, or directly in chat if it is not, and wait for the answer before continuing. Ask only about material gaps the repository and the request don't answer with strong evidence. At most three focused questions per round. Get at least one real answer or approval round before writing a new file. Confirm every inference.

Start with the unknowns that most change future product decisions:

1. Who is the primary user, in what situation, doing what job?
2. What does the product make possible, and what is its different mechanism or position?
3. What durable constraints, assets, evidence, or facts must future work preserve?

Confirm an ambiguous platform separately. When the project has no framework or scaffold and the request implies building, the stack is the user's decision: ask once (static, a specific framework, or your recommendation, plus any deploy target) and record the outcome under `## Stack`, including "delegated" when they leave it to you.

Add a round only for a material audience, brand, evidence, or accessibility gap. Record undecided facts as undecided.

Do not ask about aesthetic direction, feel, references, colors, or typography. If the user volunteers a binding visual constraint, record it as stated without expanding it.

Whether anyone can answer is a mechanical test, not a judgment call: a question tool in your tool surface proves an answer mechanism exists, and a claim that the user is unattended proves nothing. Probe once with the real first round before concluding no one is there. Only after that probe errors or times out, infer from the explicit brief, label every inferred fact in the file, and say so in your first reply.

### Belongs in PRODUCT.md

- Users, jobs, workflows, purpose, success, positioning, operating context.
- Capabilities, constraints, terminology, evidence, platform, accessibility.
- Confirmed voice, assets, and brand commitments.

### Does not belong

- Visual worlds, palettes, typography, components, page concepts, and platform design conventions (HIG, Material). Record the platform; design skills own the conventions.
- Visitor mode, narrative, CTA or proof sequence, other per-surface strategy.
- Invented testimonials, customers, benchmarks, pricing, licensing, or deployment claims.
- A need to decide every optional field.

## 4. Write PRODUCT.md

Write only confirmed facts and explicitly marked open decisions. Omit sections that don't apply instead of filling them with generic prose. New files go at the project root, or the child app's root when its facts are app-specific.

```markdown
# Product

## Platform

web

## Stack

[Greenfield only: the user's answer, e.g. "static HTML/CSS", "Astro", or "delegated: <what you chose and why>". Omit when an existing codebase already answers it.]

## Users

[Primary users, their situation, and job. Add other audiences only when confirmed.]

## Product Purpose

[What the product does, why it exists, what success means.]

## Positioning

[The mechanism or claim a neighboring product could not truthfully copy.]

## Operating Context

[Workflows, environments, tools, documents, materials, and rituals that are factual parts of using or evaluating the product.]

## Capabilities and Constraints

[Confirmed functionality, technical constraints, terminology, and explicitly undecided product facts.]

## Brand Commitments

[Existing name, voice, assets, personality, identity constraints, and references the user explicitly made binding. Omit when none exist.]

## Evidence on Hand

[Real content, data, demos, testimonials, case studies, press, or assets, with paths where applicable. State absences that future work must not fabricate.]

## Product Principles

[Three to five durable strategic principles derived from confirmed answers. No visual recipes.]

## Accessibility & Inclusion

[Known user needs or a required standard. Omit when none was established.]
```

`## Platform` is the bare value `web`, `ios`, `android`, or `adaptive`. Keep useful headings already in an existing file. If the file carries an `<!-- impeccable:product-schema N -->` comment, leave it unchanged.

## 5. Completion gate

Verify that PRODUCT.md exists at the intended path and holds the confirmed record. Interview notes or a plan are not a substitute. If the file is missing, the task is incomplete.

## 6. Wrap up

Summarize what was captured and what was deliberately left undecided.
