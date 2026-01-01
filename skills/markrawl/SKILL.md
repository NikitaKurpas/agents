---
name: markrawl
description: Fetch and convert web pages to Markdown using the local markrawl CLI. Use when asked to download or inspect a web page, capture a URL's content as Markdown, or save page content for analysis.
---

# Markrawl

## Quick start

1. Run the bundled binary:
   `./bin/markrawl <url> [output-file]` (always requires escalation due to Puppeteer usage)
2. If `output-file` is omitted, markrawl writes to a temp file and prints the path.
3. Prefer saving to `/tmp/` or `./.tmp/`, then inspect with `rg` or `sed -n '1,250p'`.
4. If Chrome is missing, run: `./scripts/ensure_puppeteer_chrome.sh` (always requires escalation).

## Notes

- This tool uses headless Chrome via Puppeteer. If it fails to launch, install the required Chrome runtime.
- Use markrawl instead of `curl` when you need a full rendered page or non-text content.
