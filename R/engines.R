# The `pi` engine: run a live agent turn, weave the shown command + reply blockquote.
.pi_engine <- function(options) {
  prompt <- paste(options$code, collapse = " ")
  model <- options$model %||% getOption("piknit.model", "gpt-5.3-codex-spark")
  out <- pi_run(
    prompt,
    model = model,
    provider = options$provider,
    extension = options$extension,
    session = options$session,
    thinking = options$thinking,
    timeout = options$timeout %||% 300
  )
  reply <- paste0("> ", gsub("\n", "\n> ", paste(out, collapse = "\n")))
  ext <- if (is.null(options$extension)) "" else paste0(" -e ", paste(options$extension, collapse = " -e "))
  knitr::asis_output(paste0(
    "``` sh\n", .pi_bin(), " --model ", model, ext, " -p \\\n", wrap_prompt(prompt), "\n```\n\n",
    reply, "\n"
  ))
}

# The `pish` engine: run a shell command fail-loud, JSON-fence JSON output.
.pish_engine <- function(options) {
  cmd <- paste(options$code, collapse = " ")
  out <- suppressWarnings(system(paste(cmd, "2>&1"), intern = TRUE))
  status <- attr(out, "status")
  txt <- paste(out, collapse = "\n")
  if (!is.null(status) && status != 0) {
    stop("pish render failed (exit ", status, "): ", cmd, "\n", txt, call. = FALSE)
  }
  lang <- if (grepl("^\\s*[\\[{]", txt)) "json" else ""
  knitr::asis_output(paste0("``` sh\n", cmd, "\n```\n\n``` ", lang, "\n", txt, "\n```\n"))
}

#' Register piknit's knitr engines
#'
#' Registers the `pi` and `pish` engines with knitr. Called automatically from
#' `.onLoad`, so `library(piknit)` is enough; exported for manual
#' re-registration (e.g. after another package overwrites an engine name).
#'
#' @return Invisibly `TRUE`.
#' @export
register_engines <- function() {
  knitr::knit_engines$set(pi = .pi_engine)
  knitr::knit_engines$set(pish = .pish_engine)
  invisible(TRUE)
}

.onLoad <- function(libname, pkgname) {
  if (requireNamespace("knitr", quietly = TRUE)) register_engines()
}
