# internal null-coalescing helper
`%||%` <- function(a, b) if (is.null(a)) b else a

# Resolve the pi binary: option piknit.bin, else env PIKNIT_PI, else "pi".
.pi_bin <- function() {
  getOption("piknit.bin", Sys.getenv("PIKNIT_PI", unset = "pi"))
}

#' Wrap a prompt onto short, runnable shell-string lines
#'
#' Splits `prompt` into shell-quoted segments passed to `printf` inside one
#' command substitution. The displayed command remains readable while the shell
#' supplies Pi exactly one prompt argument with the original text.
#'
#' @param prompt A single prompt string.
#' @param width Target maximum line width in characters (default 56).
#' @return A single string: the wrapped, continuation-joined shell strings.
#' @export
#' @examples
#' cat(wrap_prompt("count the variants by consequence in the manifest", 24))
wrap_prompt <- function(prompt, width = 56) {
  words <- strsplit(prompt, " ")[[1]]
  lines <- character(0)
  cur <- ""
  for (w in words) {
    if (nzchar(cur) && nchar(cur) + nchar(w) + 1 > width) {
      lines <- c(lines, cur)
      cur <- w
    } else {
      cur <- if (nzchar(cur)) paste(cur, w) else w
    }
  }
  lines <- c(lines, cur)
  if (length(lines) == 1L) return(paste0("  ", shQuote(prompt)))

  lines[-length(lines)] <- paste0(lines[-length(lines)], " ")
  quoted <- vapply(lines, shQuote, character(1), type = "sh")
  rendered <- c(
    paste0('  "$(printf %s \\'),
    paste0("    ", quoted, c(rep(" \\", length(quoted) - 1L), ")\""))
  )
  paste(rendered, collapse = "\n")
}
