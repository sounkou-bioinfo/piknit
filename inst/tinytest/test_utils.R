check_wrapped_prompt <- function(prompt, width) {
  wrapped <- wrap_prompt(prompt, width = width)
  script <- tempfile(fileext = ".sh")
  on.exit(unlink(script), add = TRUE)
  writeLines(c(
    "#!/bin/sh",
    paste0("set -- ", wrapped),
    '[ "$#" -eq 1 ] || exit 10',
    paste0('[ "$1" = ', shQuote(prompt, type = "sh"), ' ] || exit 11')
  ), script)
  expect_equal(system2("sh", script), 0L)
  wrapped
}

# A wrapped prompt remains exactly one shell argument.
prompt <- "count the variants by consequence in the manifest"
w <- check_wrapped_prompt(prompt, width = 24)
expect_true(grepl("printf %s", w, fixed = TRUE))
expect_true(grepl("\\\n", w))

# Shell metacharacters and both quote styles survive unchanged.
check_wrapped_prompt("It's \"quoted\" with $HOME and (parentheses)", width = 16)

# A single short prompt remains one quoted shell word.
expect_equal(wrap_prompt("hello", width = 56), paste0("  ", shQuote("hello")))
check_wrapped_prompt("hello", width = 56)
