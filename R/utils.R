# internal null-coalescing helper
`%||%` <- function(a, b) if (is.null(a)) b else a

# Resolve the pi binary: option piknit.bin, else env PIKNIT_PI, else "pi".
.pi_bin <- function() {
  getOption("piknit.bin", Sys.getenv("PIKNIT_PI", unset = "pi"))
}

#' Wrap a prompt onto short, runnable shell-string lines
#'
#' Splits `prompt` on spaces into adjacent double-quoted shell strings (which a
#' POSIX shell concatenates) no wider than `width`, each but the last ending in
#' a line continuation. Used to render a long prompt as a readable, still
#' runnable, multi-line command.
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
  n <- length(lines)
  paste(vapply(seq_len(n), function(i) {
    paste0('  "', lines[i], if (i < n) " " else "", '"', if (i < n) " \\" else "")
  }, character(1)), collapse = "\n")
}
