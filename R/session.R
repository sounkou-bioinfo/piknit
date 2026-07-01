#' Open a persistent Pi agent session
#'
#' Returns a session object whose `ask()` method runs successive turns that
#' share one conversation via a stable `--session-id`, so the agent remembers
#' earlier turns across chunks — a "running Pi session" inside a document. No
#' long-lived process is held: each turn is a fresh, robust spawn bound to the
#' shared session id, so a hung turn cannot wedge the whole render.
#'
#' @param id Session id. Defaults to a generated id.
#' @param ... Defaults forwarded to [pi_run()] for every turn (e.g. `model`,
#'   `provider`, `extension`, `thinking`, `timeout`).
#' @return A list with elements `id`, `ask(prompt, ...)` (per-turn overrides win
#'   over the session defaults), and `history()` (a list of `prompt`/`reply` pairs).
#' @seealso [pi_run()]
#' @export
#' @examples
#' \dontrun{
#' s <- pi_session(extension = "extensions/pi-coding-agent/index.ts")
#' s$ask("Load examples/variant-counts/manifest.json and count variants by consequence.")
#' s$ask("Now break the same counts down as percentages.") # remembers the table above
#' }
pi_session <- function(id = NULL, ...) {
  id <- id %||% paste0("piknit-", as.integer(Sys.time()), "-", sample.int(1e6, 1))
  defaults <- list(...)
  turns <- list()
  ask <- function(prompt, ...) {
    call_args <- utils::modifyList(defaults, list(...))
    out <- do.call(pi_run, c(list(prompt = prompt, session = id), call_args))
    turns[[length(turns) + 1]] <<- list(prompt = prompt, reply = out)
    out
  }
  list(
    id = id,
    ask = ask,
    history = function() turns
  )
}
