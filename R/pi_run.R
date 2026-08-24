#' Run one turn of a live Pi agent
#'
#' Spawns the Pi CLI in non-interactive print mode (`-p`) and returns its reply
#' as a character vector (one element per output line). This is the primitive
#' the `pi` knitr engine is built on; call it directly for scripting.
#'
#' @param prompt The user prompt (a single string).
#' @param model Model pattern or ID. Defaults to `getOption("piknit.model")`,
#'   then "gpt-5.3-codex-spark" — a small, fast model keeps a live turn to
#'   seconds, so a whole document renders as a real integration test.
#' @param provider Provider id. Defaults to `getOption("piknit.provider")`,
#'   then "openai-codex".
#' @param extension Optional character vector of extension entrypoints, passed
#'   as repeated `-e` flags (e.g. a Pi coding-agent extension that exposes tools).
#' @param session Optional session id. When set, turns that share the id share
#'   conversation memory (a persistent session across chunks); when `NULL`
#'   (default) the turn is ephemeral (`--no-session`). See [pi_session()].
#' @param thinking Optional thinking level (e.g. "high"), for models that support it.
#' @param timeout Seconds before the turn is killed (default 300).
#' @param dir Project root to start the agent in (its working directory). pi
#'   treats the working directory as the project root, so `dir` is what scopes
#'   the agent's file tools, and `extension`/skill/manifest paths are resolved
#'   relative to it. The working directory is restored afterwards. `NULL`
#'   (default) runs in the current directory.
#' @param pi_bin Path to the pi binary (default resolves `piknit.bin` /
#'   `PIKNIT_PI` / "pi").
#' @return A [pi_reply] — the agent's reply lines (a character vector with a
#'   plain-printing method), carrying `prompt` and `model` as attributes. On
#'   spawn failure the reply is the single line `"[pi unavailable]"`.
#' @seealso [pi_session()] for multi-turn continuity.
#' @export
#' @examples
#' \dontrun{
#' pi_run("List the files in this directory and summarize them.")
#' }
pi_run <- function(prompt, model = NULL, provider = NULL, extension = NULL,
                   session = NULL, thinking = NULL, timeout = 300,
                   dir = NULL, pi_bin = .pi_bin()) {
  if (!is.null(dir)) {
    old <- setwd(dir)               # pi uses the working directory as its project root
    on.exit(setwd(old), add = TRUE)
  }
  model <- model %||% getOption("piknit.model", "gpt-5.3-codex-spark")
  provider <- provider %||% getOption("piknit.provider", "openai-codex")
  args <- c("--provider", provider, "--model", model)
  if (!is.null(thinking)) args <- c(args, "--thinking", thinking)
  for (e in extension) args <- c(args, "-e", e)
  if (is.null(session)) {
    args <- c(args, "--no-session")
  } else {
    args <- c(args, "--session-id", session)
  }
  # system2 with stdout/stderr = TRUE captures via a shell, which pastes args
  # unquoted; shQuote keeps a prompt with (), quotes, etc. from breaking it.
  args <- c(args, "-p", shQuote(prompt))
  out <- tryCatch(
    system2(pi_bin, args, stdout = TRUE, stderr = TRUE, timeout = timeout),
    error = function(e) "[pi unavailable]"
  )
  new_pi_reply(out, prompt = prompt, model = model)
}
