# Preferred dependencies

Use these defaults when needed. Follow repository dependency rules.

## Utilities

- TypeScript input validation: use [Zod](https://zod.dev/) by default for untrusted input at system boundaries. Reuse schemas and infer types from them.
- Deno utilities: prefer [JSR `@std/*`](https://docs.deno.com/runtime/reference/std/) for capabilities missing from Deno and Web APIs.
- Swift CLIs: use Apple's [swift-argument-parser](https://github.com/apple/swift-argument-parser) for argument parsing and help text.

## Observability

- Swift: use [swift-log](https://github.com/apple/swift-log), [swift-distributed-tracing](https://github.com/apple/swift-distributed-tracing), and [swift-metrics](https://github.com/apple/swift-metrics) for logging, tracing, and metrics.
- Prefer established ecosystem APIs for instrumentation. Connect them to OpenTelemetry through compatible bridges or backends when needed.
- Use [OpenTelemetry APIs](https://opentelemetry.io/docs/languages/) when the language lacks an established API for logging, tracing, or metrics. For custom traces and metrics in TypeScript and JavaScript, use `@opentelemetry/api`.
- Use [Deno's built-in OpenTelemetry support](https://docs.deno.com/runtime/fundamentals/open_telemetry/) with `@opentelemetry/api`; avoid adding a second SDK.
