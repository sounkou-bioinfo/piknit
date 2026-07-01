# Stream a live Pi agent turn as it happens

Runs one agent turn over pi's JSON-RPC mode (`pi --mode rpc`) and
delivers the output *incrementally* as it is produced, instead of
waiting for the whole turn like
[`pi_run()`](https://sounkou-bioinfo.github.io/piknit/reference/pi_run.md).
Assistant text arrives as deltas (streamed to `on_delta` by default),
and every parsed event is available through `on_event` for tool-call,
thinking, or lifecycle handling. The turn ends on pi's `agent_end`
event. Needs the suggested packages processx and jsonlite.

## Usage

``` r
pi_stream(
  prompt,
  model = NULL,
  provider = NULL,
  extension = NULL,
  session = NULL,
  thinking = NULL,
  timeout = 300,
  dir = NULL,
  on_delta = function(text) cat(text),
  on_event = NULL,
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

- on_delta:

  Function called with each chunk of assistant text as it streams
  (default writes it to the console with
  [`cat()`](https://rdrr.io/r/base/cat.html)). `NULL` suppresses live
  output.

- on_event:

  Optional function called with every parsed JSON event (a named list),
  e.g. to react to `message_update` tool calls or `turn_end`.

- pi_bin:

  Path to the pi binary (default resolves `piknit.bin` / `PIKNIT_PI` /
  "pi").

## Value

A
[pi_reply](https://sounkou-bioinfo.github.io/piknit/reference/pi_reply.md)
with the full assistant text, accumulated from the deltas.

## See also

[`pi_run()`](https://sounkou-bioinfo.github.io/piknit/reference/pi_run.md)
for a simpler blocking turn.

## Examples

``` r
if (FALSE) { # \dontrun{
# print the answer as it is typed
pi_stream("Explain content-addressed storage in two sentences.")
} # }
```
