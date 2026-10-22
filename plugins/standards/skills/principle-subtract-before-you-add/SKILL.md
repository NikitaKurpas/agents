---
name: principle-subtract-before-you-add
description: "Removes dead code and redundant pieces before adding, refactoring, or rewriting."
disable-model-invocation: true
---

# Subtract Before You Add

When evolving a system, remove complexity first, then build. Default to subtraction.

Make simplification a continual investment. Leave the design slightly simpler and more capable behind the same or smaller surface than you found it.

- Sequence removal before construction
- Cut before you polish (get to the minimum before investing in quality)
- Design for observed usage, not speculative edge cases
- Handle an edge case in proportion to its likelihood and impact: a rare failure with serious consequences earns handling, a theoretical one doesn't
- No speculative validators, parsers, or guards beyond what the spec demands
- Simplify prompts (remove redundant instructions, excessive templates)
- When a reference has no novel content, delete it rather than leaving a stub
