# Changelog

## piknit 0.1.2

- `pi` cells fail the render when Pi exits nonzero and support
  `no_extensions=TRUE` for isolated explicit extension loading.

## piknit 0.1.1

- Rendered `pi` commands now pass wrapped prompts as exactly one shell
  argument and show the provider, thinking, extension, and session
  options used live.

## piknit 0.1.0

First release.

### Engines

- `pi` knitr engine — the chunk body is a prompt; a live Pi agent turn
  runs at render time and its real reply is woven in as a blockquote,
  under the exact command used. Chunk options `model`, `provider`,
  `extension`, `session`, `thinking`, and `timeout` are honoured; the
  default model is the small, fast `gpt-5.3-codex-spark` so a live turn
  is seconds, not minutes.
- `pish` knitr engine — run a shell command *fail-loud*: a non-zero exit
  stops the render (never bakes a failure as an answer), and JSON output
  is fenced as `json` for syntax highlighting.

### API

- [`pi_run()`](https://sounkou-bioinfo.github.io/piknit/reference/pi_run.md)
  — one non-interactive agent turn, returned as a `pi_reply`. A `dir`
  argument sets the project root the agent starts in (pi treats the
  working directory as the project root, scoping its file tools and
  relative paths).
- [`pi_stream()`](https://sounkou-bioinfo.github.io/piknit/reference/pi_stream.md)
  — stream a turn over `pi --mode rpc`: assistant text arrives as deltas
  (an `on_delta` callback) and every parsed event through `on_event`;
  the turn ends on pi’s `agent_end`. Uses processx + jsonlite
  (suggested).
- `pi_reply` — an S3 class (character lines + `prompt`/`model`
  attributes) with a [`print()`](https://rdrr.io/r/base/print.html)
  method that writes the reply plainly, so it renders as the agent wrote
  it in a console, script, or knitr chunk — not as a quoted vector.
- [`pi_session()`](https://sounkou-bioinfo.github.io/piknit/reference/pi_session.md)
  — a persistent session whose `ask()` turns share conversation memory
  via a stable `--session-id`, without holding a long-lived process.
- [`wrap_prompt()`](https://sounkou-bioinfo.github.io/piknit/reference/wrap_prompt.md)
  — wrap a long prompt onto short, still-runnable shell lines.
- [`register_engines()`](https://sounkou-bioinfo.github.io/piknit/reference/register_engines.md)
  — (re)register the engines with knitr.

### Notes

- Licensed GPL (\>= 2); no license text is vendored — the `License`
  field references the standard.

### Roadmap

- A persistent single-process session over `pi --mode rpc` (reusing one
  process across `ask()` turns, building on
  [`pi_stream()`](https://sounkou-bioinfo.github.io/piknit/reference/pi_stream.md)’s
  protocol handling). Today
  [`pi_session()`](https://sounkou-bioinfo.github.io/piknit/reference/pi_session.md)
  gets continuity from `--session-id` — robust (no wedged long-lived
  process) at the cost of a spawn per turn.
