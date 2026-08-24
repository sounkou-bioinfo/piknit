# The `pi` engine: run a live agent turn, weave the shown command + reply blockquote.
.pi_engine <- function(options) {
  prompt <- paste(options$code, collapse = " ")
  model <- options$model %||% getOption("piknit.model", "gpt-5.3-codex-spark")
  provider <- options$provider %||% getOption("piknit.provider", "openai-codex")
  args <- c("--provider", shQuote(provider), "--model", shQuote(model))
  if (!is.null(options$thinking)) {
    args <- c(args, "--thinking", shQuote(options$thinking))
  }
  for (extension in options$extension) {
    args <- c(args, "-e", shQuote(extension))
  }
  if (is.null(options$session)) {
    args <- c(args, "--no-session")
  } else {
    args <- c(args, "--session-id", shQuote(options$session))
  }
  command <- paste(c(shQuote(.pi_bin()), args, "-p"), collapse = " ")
  if (!is.null(options$dir)) {
    command <- paste0("cd ", shQuote(options$dir), " && ", command)
  }
  cmd <- paste0("``` sh\n", command, " \\\n", wrap_prompt(prompt), "\n```\n\n")
  # Where the agent is not on PATH (e.g. CI), don't fail or emit noise: show the
  # command with a note. The document still builds; only the live reply is absent.
  if (!nzchar(Sys.which(.pi_bin()))) {
    return(knitr::asis_output(paste0(cmd, "> *(pi not on PATH -- not run in this environment)*\n")))
  }
  out <- pi_run(
    prompt,
    model = model,
    provider = options$provider,
    extension = options$extension,
    session = options$session,
    thinking = options$thinking,
    timeout = options$timeout %||% 300,
    dir = options$dir
  )
  reply <- paste0("> ", gsub("\n", "\n> ", paste(out, collapse = "\n")))
  knitr::asis_output(paste0(cmd, reply, "\n"))
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
