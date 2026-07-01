#' piknit: embed the Pi coding agent in R
#'
#' piknit is a way to **embed the Pi coding agent in R**. Drive a live agent
#' from R with a small scripting API ([pi_run()] for one turn, [pi_session()]
#' for a memory-keeping multi-turn session), or drop it into R Markdown / Quarto
#' through custom knitr engines that run a live agent (and fail-loud shell
#' commands) at render time, weaving the agent's *real* replies and command
#' output into the render. Rendering becomes an integration test: a stale claim
#' or a broken command fails the build, exactly the discipline behind leanknit
#' and duckknit.
#'
#' @section Engines (registered on load):
#' \describe{
#'   \item{`pi`}{Run a live Pi agent turn; the chunk body is the prompt. The
#'     shown command and the agent's reply (as a blockquote) are woven in.}
#'   \item{`pish`}{Run a shell command fail-loud (a non-zero exit stops the
#'     render, never bakes a failure as an answer) with automatic JSON fencing.}
#' }
#'
#' @section Options:
#' `piknit.bin` (or env `PIKNIT_PI`) sets the pi binary; `piknit.model` and
#' `piknit.provider` set defaults for [pi_run()] and the `pi` engine.
#'
#' @keywords internal
"_PACKAGE"
