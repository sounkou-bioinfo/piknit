# engines register with knitr
register_engines()
engines <- knitr::knit_engines$get()
expect_true("pi" %in% names(engines))
expect_true("pish" %in% names(engines))
expect_true(is.function(engines$pi))
expect_true(is.function(engines$pish))

# The rendered pi command shows the same execution options and one wrapped prompt.
old_bin <- Sys.getenv("PIKNIT_PI", unset = NA_character_)
old_bin_option <- getOption("piknit.bin")
on.exit(if (is.na(old_bin)) Sys.unsetenv("PIKNIT_PI") else Sys.setenv(PIKNIT_PI = old_bin), add = TRUE)
on.exit(options(piknit.bin = old_bin_option), add = TRUE)
Sys.setenv(PIKNIT_PI = "pi-does-not-exist-xyz")
options(piknit.bin = "pi-does-not-exist-xyz")
pi_eng <- knitr::knit_engines$get("pi")
rendered <- as.character(pi_eng(list(
  code = "count the variants by consequence in the declared manifest without using shell tools",
  provider = "openai-codex",
  model = "gpt-5.4",
  thinking = "medium",
  extension = "./extension/index.ts",
  no_extensions = TRUE,
  session = NULL,
  timeout = 5,
  dir = NULL
)))
expect_true(grepl(paste("--provider", shQuote("openai-codex")), rendered, fixed = TRUE))
expect_true(grepl(paste("--model", shQuote("gpt-5.4")), rendered, fixed = TRUE))
expect_true(grepl(paste("--thinking", shQuote("medium")), rendered, fixed = TRUE))
expect_true(grepl(paste("-e", shQuote("./extension/index.ts")), rendered, fixed = TRUE))
expect_true(grepl("--no-extensions", rendered, fixed = TRUE))
expect_true(grepl("--no-session -p", rendered, fixed = TRUE))
expect_true(grepl("$(printf %s", rendered, fixed = TRUE))

# A nonzero Pi process fails the document render.
Sys.setenv(PIKNIT_PI = "/bin/false")
options(piknit.bin = "/bin/false")
expect_error(suppressWarnings(pi_eng(list(
  code = "run one turn",
  provider = "openai-codex",
  model = "gpt-5.4",
  thinking = NULL,
  extension = NULL,
  no_extensions = FALSE,
  session = NULL,
  timeout = 5,
  dir = NULL
))), pattern = "pi render failed \\(exit 1\\)")

# pi_run fails soft when the binary is missing (never errors the render)
out <- pi_run("say ok", pi_bin = "pi-does-not-exist-xyz", timeout = 5)
expect_true(inherits(out, "pi_reply"))
expect_equal(as.character(out), "[pi unavailable]")
expect_equal(attr(out, "prompt"), "say ok")

# the pish engine fails the render on a non-zero exit
eng <- knitr::knit_engines$get("pish")
expect_error(eng(list(code = "exit 3")), pattern = "pish render failed")

# the pish engine fences JSON output and passes on success
out2 <- as.character(eng(list(code = "printf '{\"ok\":true}'")))
expect_true(grepl("``` json", out2, fixed = TRUE))
expect_true(grepl('"ok":true', out2, fixed = TRUE))

# pi_session shares one id across turns and records history
s <- pi_session(id = "fixed-test-id", pi_bin = "pi-does-not-exist-xyz", timeout = 5)
expect_equal(s$id, "fixed-test-id")
s$ask("first")
s$ask("second")
h <- s$history()
expect_equal(length(h), 2)
expect_equal(h[[1]]$prompt, "first")
expect_equal(as.character(h[[2]]$reply), "[pi unavailable]")

# pi_reply prints its lines plainly (no quotes / [1] index)
printed <- capture.output(print(structure(c("line one", "line two"), class = "pi_reply")))
expect_equal(printed, c("line one", "line two"))

# pi_run restores the working directory even when it changes it for the turn
wd <- getwd()
invisible(pi_run("hi", dir = tempdir(), pi_bin = "pi-does-not-exist-xyz", timeout = 5))
expect_equal(normalizePath(getwd()), normalizePath(wd))

# pi_stream is exported and errors cleanly on a bad binary (does not hang)
expect_true(is.function(pi_stream))
expect_error(pi_stream("hi", pi_bin = "pi-does-not-exist-xyz", timeout = 3))
