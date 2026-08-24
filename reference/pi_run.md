# Run one turn of a live Pi agent

Spawns the Pi CLI in non-interactive print mode (`-p`) and returns its
reply as a character vector (one element per output line). This is the
primitive the `pi` knitr engine is built on; call it directly for
scripting.

## Usage

``` r
pi_run(
  prompt,
  model = NULL,
  provider = NULL,
  extension = NULL,
  session = NULL,
  thinking = NULL,
  timeout = 300,
  dir = NULL,
  pi_bin = .pi_bin()
)
```

## Arguments

- prompt:

  The user prompt (a single string).

- model:

  Model pattern or ID. Defaults to `getOption("piknit.model")`, then
  "gpt-5.3-codex-spark" — a small, fast model keeps a live turn to
  seconds, so a whole document renders as a real integration test.

- provider:

  Provider id. Defaults to `getOption("piknit.provider")`, then
  "openai-codex".

- extension:

  Optional character vector of extension entrypoints, passed as repeated
  `-e` flags (e.g. a Pi coding-agent extension that exposes tools).

- session:

  Optional session id. When set, turns that share the id share
  conversation memory (a persistent session across chunks); when `NULL`
  (default) the turn is ephemeral (`--no-session`). See
  [`pi_session()`](https://sounkou-bioinfo.github.io/piknit/reference/pi_session.md).

- thinking:

  Optional thinking level (e.g. "high"), for models that support it.

- timeout:

  Seconds before the turn is killed (default 300).

- dir:

  Project root to start the agent in (its working directory). pi treats
  the working directory as the project root, so `dir` is what scopes the
  agent's file tools, and `extension`/skill/manifest paths are resolved
  relative to it. The working directory is restored afterwards. `NULL`
  (default) runs in the current directory.

- pi_bin:

  Path to the pi binary (default resolves `piknit.bin` / `PIKNIT_PI` /
  "pi").

## Value

A
[pi_reply](https://sounkou-bioinfo.github.io/piknit/reference/pi_reply.md)
— the agent's reply lines (a character vector with a plain-printing
method), carrying `prompt` and `model` as attributes. On spawn failure
the reply is the single line `"[pi unavailable]"`.

## See also

[`pi_session()`](https://sounkou-bioinfo.github.io/piknit/reference/pi_session.md)
for multi-turn continuity.

## Examples

``` r
if (FALSE) { # \dontrun{
pi_run("List the files in this directory and summarize them.")
} # }
```
