# Open a persistent Pi agent session

Returns a session object whose `ask()` method runs successive turns that
share one conversation via a stable `--session-id`, so the agent
remembers earlier turns across chunks — a "running Pi session" inside a
document. No long-lived process is held: each turn is a fresh, robust
spawn bound to the shared session id, so a hung turn cannot wedge the
whole render.

## Usage

``` r
pi_session(id = NULL, ...)
```

## Arguments

- id:

  Session id. Defaults to a generated id.

- ...:

  Defaults forwarded to
  [`pi_run()`](https://sounkou-bioinfo.github.io/piknit/reference/pi_run.md)
  for every turn (e.g. `model`, `provider`, `extension`, `thinking`,
  `timeout`).

## Value

A list with elements `id`, `ask(prompt, ...)` (per-turn overrides win
over the session defaults), and
[`history()`](https://rdrr.io/r/utils/savehistory.html) (a list of
`prompt`/`reply` pairs).

## See also

[`pi_run()`](https://sounkou-bioinfo.github.io/piknit/reference/pi_run.md)

## Examples

``` r
if (FALSE) { # \dontrun{
s <- pi_session(extension = "extensions/pi-coding-agent/index.ts")
s$ask("Load examples/variant-counts/manifest.json and count variants by consequence.")
s$ask("Now break the same counts down as percentages.") # remembers the table above
} # }
```
