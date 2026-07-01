# engines register with knitr
register_engines()
engines <- knitr::knit_engines$get()
expect_true("pi" %in% names(engines))
expect_true("pish" %in% names(engines))
expect_true(is.function(engines$pi))
expect_true(is.function(engines$pish))

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
