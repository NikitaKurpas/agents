---
name: principle-laziness-protocol
description: "Prefers deletion and the smallest change that solves the problem over new abstractions or layers."
disable-model-invocation: true
---

# Laziness Protocol

- **Consolidate decisions.** Do not repeat the same choice in several places. Put it behind one source of truth and pass the result as a simple flag.
- **Minimize the diff.** Make the smallest change that solves the problem. Fewer lines beat "elegant" boilerplate.
- **Reuse before you write.** Search for an existing helper, type, or pattern that already does the job, and use it the way its callers do. Then try the standard library or platform, then an installed dependency, before adding one.
- **Justify abstractions by change cost.** An abstraction earns its place by making a concrete, likely change cheaper.
- **Make the program lazy too.** Do not repeat a read or call another path already made. Do not write an unchanged value when observers re-run on every write. Run independent waits concurrently. Act and handle the failure instead of checking first, since the check goes stale.
