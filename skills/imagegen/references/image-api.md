# Image API quick reference

This file is for the fallback CLI mode only. Use it when the user explicitly asks to use `scripts/image_gen.py` / CLI / API / model controls, or after the user explicitly confirms that a transparent-output request should use the `gpt-image-1.5` true-transparency fallback path.

These parameters describe the Image API and bundled CLI fallback surface. Do not assume they are normal arguments on the built-in `image_gen` tool.

## Scope
- This fallback CLI is intended for GPT Image models (`gpt-image-2.6-*`, `gpt-image-2.5-*`, `gpt-image-2`, `gpt-image-1.5`, `gpt-image-1`, and `gpt-image-1-mini`).
- The built-in `image_gen` tool and the fallback CLI do not expose the same controls.

## Model summary

| Model | Quality | Input fidelity | Resolutions | Recommended use |
| --- | --- | --- | --- | --- |
| `gpt-image-2.6-sunburst` (CLI default) | `low`, `medium`, `high`, `xhigh`, `max`, `auto` | Image inputs always high fidelity; do not set `input_fidelity` | `auto` or flexible sizes (same rules as `gpt-image-2`) | Detailed compositions, dense text and layouts, precise edits, final assets. Supports `complexity`, `--markup`, SVG, GIF, transparent backgrounds |
| `gpt-image-2.6-flare` | same as 2.6 Sunburst | same | same | Fast iteration and everyday generation; same controls as Sunburst |
| `gpt-image-2.5-sunburst`, `gpt-image-2.5-flare` | same as 2.6 | same | same | Same token rates as 2.6; transparent backgrounds and `--markup`; no `complexity`, GIF, or SVG |
| `gpt-image-2` | `low`, `medium`, `high`, `auto` | Always high fidelity for image inputs; do not set `input_fidelity` | `auto` or flexible sizes that satisfy the constraints below | Earlier generation: high-quality generation and editing, text-heavy images, photorealism, compositing; no transparent backgrounds |
| `gpt-image-1.5` | `low`, `medium`, `high`, `auto` | `low`, `high` | `1024x1024`, `1024x1536`, `1536x1024`, `auto` | True transparent-background fallback and backward-compatible workflows |
| `gpt-image-1` | `low`, `medium`, `high`, `auto` | `low`, `high` | `1024x1024`, `1024x1536`, `1536x1024`, `auto` | Legacy compatibility |
| `gpt-image-1-mini` | `low`, `medium`, `high`, `auto` | `low`, `high` | `1024x1024`, `1024x1536`, `1536x1024`, `auto` | Cost-sensitive draft batches and lower-stakes previews |

## gpt-image-2 sizes

`gpt-image-2` accepts `auto` or any `WIDTHxHEIGHT` size that satisfies all constraints:

- Maximum edge length must be less than or equal to `3840px`.
- Both edges must be multiples of `16px`.
- Long edge to short edge ratio must not exceed `3:1`.
- Total pixels must be at least `655,360` and no more than `8,294,400`.

Popular sizes:

| Label | Size | Notes |
| --- | --- | --- |
| Square | `1024x1024` | Typical fast default |
| Landscape | `1536x1024` | Standard landscape |
| Portrait | `1024x1536` | Standard portrait |
| 2K square | `2048x2048` | Larger square output |
| 2K landscape | `2048x1152` | Widescreen output |
| 4K landscape | `3840x2160` | Widescreen 4K output |
| 4K portrait | `2160x3840` | Vertical 4K output |
| Auto | `auto` | Default size |

Square images are typically fastest to generate. For 4K-style output, use `3840x2160` or `2160x3840`.

## Endpoints
- Generate: `POST /v1/images/generations` (`client.images.generate(...)`)
- Edit: `POST /v1/images/edits` (`client.images.edit(...)`)

## Core parameters for GPT Image models
- `prompt`: text prompt
- `model`: image model
- `n`: number of images (1-10)
- `size`: `auto` by default; flexible `WIDTHxHEIGHT` sizes are allowed for `gpt-image-2`, `gpt-image-2.5-*`, and `gpt-image-2.6-*`; older GPT Image models use `1024x1024`, `1536x1024`, `1024x1536`, or `auto`. For GIF output it is the per-frame size; see `references/cli.md`
- `quality`: rendering fidelity (detail and polish of the final pixels). `low`, `medium`, `high`, or `auto`; `gpt-image-2.5-*` and `gpt-image-2.6-*` also accept `xhigh` and `max` (verified live on both 2.6 models). The API default is `auto`; the CLI default is `medium`. Separate from `complexity`
- `background`: output transparency behavior (`transparent`, `opaque`, or `auto`) for generated output; this is not the same thing as the prompt's visual scene/backdrop
- `output_format`: `png` (default), `jpeg`, `webp`, `svg`, or `gif`. `svg` and `gif` are generations only on `gpt-image-2.6-*`; `svg` needs `n=1`
- `frame_count`, `frame_duration_ms`: GIF only (2-16 frames, default 9; 20 ms or more per frame, default 200). Sent by the CLI as `--frame-count` / `--frame-duration-ms`
- `markup` (edits only): transparent PNG annotation layer, same dimensions as the first input image; `gpt-image-2.5-*` and `gpt-image-2.6-*`; not with `mask`. Sent by the CLI as `--markup`
- `output_compression`: 0-100 (jpeg/webp only)
- `complexity`: `low`, `medium`, or `high` (`gpt-image-2.6-sunburst` and `gpt-image-2.6-flare` only; API default `high`; no extra fee). How much the image model plans before rendering; separate from `quality`. Lower suits focused edits, higher suits dense text and complex layouts. For SVG output it controls the reference image. Sent by the CLI as `--complexity`.
- `svg`: `{model, reasoning: {effort}}` — the model that authors the SVG (required when SVG model selection is enabled; omit otherwise). Only with `output_format=svg`. Sent by the CLI as `--svg-model` / `--svg-reasoning-effort`.
- `moderation`: `auto` (default) or `low`

## Edit-specific parameters
- `image`: one or more input images. For GPT Image models, you can provide up to 16 images.
- `mask`: optional mask image
- `input_fidelity`: `low` or `high` only for models that support it; do not set this for `gpt-image-2`

Model-specific note for `input_fidelity`:
- `gpt-image-2` always uses high fidelity for image inputs and does not support setting `input_fidelity`.
- `gpt-image-1` and `gpt-image-1-mini` preserve all input images, but the first image gets richer textures and finer details.
- `gpt-image-1.5` preserves the first 5 input images with higher fidelity.

## Transparent backgrounds

`gpt-image-2.5-*` and `gpt-image-2.6-*` support `background=transparent` with `output_format` `png` or `webp` (confirmed in the API reference for 2.5 and by live test for 2.6-flare and 2.6-sunburst). `gpt-image-2` does not currently support it. In explicit CLI/API fallback mode, keep `gpt-image-2` when a flat chroma-key background plus local alpha extraction with `python "${CODEX_HOME:-$HOME/.codex}/skills/.system/imagegen/scripts/remove_chroma_key.py"` is acceptable.

Use CLI `gpt-image-1.5` with `background=transparent` and a transparent-capable output format such as `png` or `webp` only after the user explicitly confirms that fallback, unless they already requested `gpt-image-1.5`, `scripts/image_gen.py`, or CLI fallback. If the user asks for true/native transparency, the subject is too complex for clean chroma-key removal, or local background removal fails validation, explain the tradeoff and ask before switching.

## Output
- `data[]` list with `b64_json` per image
- The bundled `scripts/image_gen.py` CLI decodes `b64_json` and writes output files for you.

## Limits and notes
- Input images and masks must be under 50MB.
- Use the edits endpoint when the user requests changes to an existing image.
- Masking is prompt-guided; exact shapes are not guaranteed.
- Large sizes and high quality increase latency and cost.
- Use `quality=low` for fast drafts, thumbnails, and quick iterations. Use `medium`, `high`, `xhigh`, or `max` for final assets, dense text, diagrams, identity-sensitive edits, or high-resolution outputs.
- High `input_fidelity` can materially increase input token usage on models that support it.
- If a request fails because a specific option is unsupported by the selected GPT Image model, retry manually without that option only when the option is not required by the user. If true transparent CLI output is required, ask before switching to `gpt-image-1.5` instead of dropping `background=transparent`, unless the user already explicitly chose that fallback.

## Important boundary
- `quality`, `input_fidelity`, explicit masks, `background`, `output_format`, and related parameters are fallback-only execution controls.
- Do not assume they are built-in `image_gen` tool arguments.
