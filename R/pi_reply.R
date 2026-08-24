#' The reply from a Pi agent turn
#'
#' [pi_run()] and a session's `ask()` return a `pi_reply`: the agent's output as
#' a character vector (one element per line) carrying the `prompt` and `model`
#' as attributes, with a print method that writes the lines plainly. So a reply
#' prints as the agent wrote it — in an R console, a script, or a knitr chunk —
#' instead of as a quoted character vector.
#'
#' @param x A `pi_reply`.
#' @param ... Ignored.
#' @return `print()` returns `x` invisibly; `as.character()` returns the plain
#'   reply lines with attributes stripped.
#' @name pi_reply
#' @examples
#' r <- structure(c("hello", "world"), class = "pi_reply")
#' r
#' as.character(r)
NULL

# Construct a pi_reply from raw output lines.
new_pi_reply <- function(lines, prompt = NULL, model = NULL) {
  structure(
    lines,
    class = "pi_reply",
    prompt = prompt,
    model = model,
    status = attr(lines, "status", exact = TRUE)
  )
}

#' @rdname pi_reply
#' @export
print.pi_reply <- function(x, ...) {
  writeLines(as.vector(x, mode = "character"))
  invisible(x)
}

#' @rdname pi_reply
#' @export
as.character.pi_reply <- function(x, ...) {
  as.vector(x, mode = "character")
}
