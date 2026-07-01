#' Stream a live Pi agent turn as it happens
#'
#' Runs one agent turn over pi's JSON-RPC mode (`pi --mode rpc`) and delivers the
#' output *incrementally* as it is produced, instead of waiting for the whole
#' turn like [pi_run()]. Assistant text arrives as deltas (streamed to `on_delta`
#' by default), and every parsed event is available through `on_event` for
#' tool-call, thinking, or lifecycle handling. The turn ends on pi's `agent_end`
#' event. Needs the suggested packages \pkg{processx} and \pkg{jsonlite}.
#'
#' @inheritParams pi_run
#' @param on_delta Function called with each chunk of assistant text as it
#'   streams (default writes it to the console with [cat()]). `NULL` suppresses
#'   live output.
#' @param on_event Optional function called with every parsed JSON event (a
#'   named list), e.g. to react to `message_update` tool calls or `turn_end`.
#' @return A [pi_reply] with the full assistant text, accumulated from the deltas.
#' @seealso [pi_run()] for a simpler blocking turn.
#' @export
#' @examples
#' \dontrun{
#' # print the answer as it is typed
#' pi_stream("Explain content-addressed storage in two sentences.")
#' }
pi_stream <- function(prompt, model = NULL, provider = NULL, extension = NULL,
                      session = NULL, thinking = NULL, timeout = 300, dir = NULL,
                      on_delta = function(text) cat(text), on_event = NULL,
                      pi_bin = .pi_bin()) {
  if (!requireNamespace("processx", quietly = TRUE) ||
      !requireNamespace("jsonlite", quietly = TRUE)) {
    stop("pi_stream() needs the 'processx' and 'jsonlite' packages.", call. = FALSE)
  }
  if (!is.null(dir)) {
    old <- setwd(dir)
    on.exit(setwd(old), add = TRUE)
  }
  model <- model %||% getOption("piknit.model", "gpt-5.3-codex-spark")
  provider <- provider %||% getOption("piknit.provider", "openai-codex")
  args <- c("--mode", "rpc", "--provider", provider, "--model", model)
  if (!is.null(thinking)) args <- c(args, "--thinking", thinking)
  for (e in extension) args <- c(args, "-e", e)
  if (is.null(session)) args <- c(args, "--no-session") else args <- c(args, "--session-id", session)

  proc <- processx::process$new(pi_bin, args, stdin = "|", stdout = "|", stderr = "|")
  on.exit(if (proc$is_alive()) proc$kill(), add = TRUE)
  proc$write_input(paste0(
    jsonlite::toJSON(list(type = "prompt", message = prompt), auto_unbox = TRUE), "\n"))

  text <- character(0)
  deadline <- Sys.time() + timeout
  repeat {
    if (Sys.time() > deadline) break
    proc$poll_io(250)
    lines <- proc$read_output_lines()          # processx buffers partial lines across reads
    if (length(lines) == 0) {
      if (!proc$is_alive()) break
      next
    }
    done <- FALSE
    for (ln in lines) {
      if (!nzchar(trimws(ln))) next
      ev <- tryCatch(jsonlite::fromJSON(ln, simplifyVector = FALSE), error = function(e) NULL)
      if (is.null(ev)) next
      if (!is.null(on_event)) on_event(ev)
      if (identical(ev$type, "message_update") &&
          identical(ev$assistantMessageEvent$type, "text_delta")) {
        d <- ev$assistantMessageEvent$delta
        if (!is.null(d)) {
          text <- c(text, d)
          if (!is.null(on_delta)) on_delta(d)
        }
      }
      if (identical(ev$type, "agent_end")) {
        done <- TRUE
        break
      }
    }
    if (done) break
  }
  if (proc$is_alive()) proc$kill()
  full <- paste(text, collapse = "")
  new_pi_reply(strsplit(full, "\n", fixed = TRUE)[[1]], prompt = prompt, model = model)
}
