# piknit: embed the Pi coding agent in R

piknit is a way to **embed the Pi coding agent in R**. Drive a live
agent from R with a small scripting API
([`pi_run()`](https://sounkou-bioinfo.github.io/piknit/reference/pi_run.md)
for one turn,
[`pi_session()`](https://sounkou-bioinfo.github.io/piknit/reference/pi_session.md)
for a memory-keeping multi-turn session), or drop it into R Markdown /
Quarto through custom knitr engines that run a live agent (and fail-loud
shell commands) at render time, weaving the agent's *real* replies and
command output into the render. Rendering becomes an integration test: a
stale claim or a broken command fails the build, exactly the discipline
behind leanknit and duckknit.

## Engines (registered on load)

- `pi`:

  Run a live Pi agent turn; the chunk body is the prompt. The shown
  command and the agent's reply (as a blockquote) are woven in.

- `pish`:

  Run a shell command fail-loud (a non-zero exit stops the render, never
  bakes a failure as an answer) with automatic JSON fencing.

## Options

`piknit.bin` (or env `PIKNIT_PI`) sets the pi binary; `piknit.model` and
`piknit.provider` set defaults for
[`pi_run()`](https://sounkou-bioinfo.github.io/piknit/reference/pi_run.md)
and the `pi` engine.

## See also

Useful links:

- <https://github.com/sounkou-bioinfo/piknit>

- Report bugs at <https://github.com/sounkou-bioinfo/piknit/issues>

## Author

**Maintainer**: Sounkou Mahamane Toure <sounkoutoure@gmail.com>
