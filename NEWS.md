# piknit 0.1.0

First release.

## Engines

* `pi` knitr engine — the chunk body is a prompt; a live Pi agent turn runs at
  render time and its real reply is woven in as a blockquote, under the exact
  command used. Chunk options `model`, `provider`, `extension`, `session`,
  `thinking`, and `timeout` are honoured; the default model is the small, fast
  `gpt-5.3-codex-spark` so a live turn is seconds, not minutes.
* `pish` knitr engine — run a shell command *fail-loud*: a non-zero exit stops
  the render (never bakes a failure as an answer), and JSON output is fenced as
  `json` for syntax highlighting.

## API

* `pi_run()` — one non-interactive agent turn, returned as character lines.
* `pi_session()` — a persistent session whose `ask()` turns share conversation
  memory via a stable `--session-id`, without holding a long-lived process.
* `wrap_prompt()` — wrap a long prompt onto short, still-runnable shell lines.
* `register_engines()` — (re)register the engines with knitr.

## Notes

* Licensed GPL (>= 2); no license text is vendored — the `License` field
  references the standard.

## Roadmap

* A single-process backend over `pi --mode rpc` (JSON-on-stdin/stdout:
  `{"type":"prompt","message":...}`), to avoid re-spawning per turn for long
  sessions. The current `pi_session()` gets continuity from `--session-id`,
  which is robust (no wedged long-lived process) at the cost of a spawn per turn.
