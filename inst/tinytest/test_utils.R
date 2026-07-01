# wrap_prompt: lines stay within width and remain a runnable shell string
w <- wrap_prompt("count the variants by consequence in the manifest", width = 24)
lines <- strsplit(w, "\n")[[1]]
expect_true(all(grepl('"', lines)))                          # each line is a quoted shell string
expect_true(all(grepl("\\\\$", lines[-length(lines)])))      # all but last end in a continuation
expect_false(grepl("\\\\$", lines[length(lines)]))           # last line has no continuation
joined <- gsub('[\\\\" ]+', " ", w)                          # words survive the round-trip
expect_true(grepl("consequence", joined))
expect_true(grepl("manifest", joined))

# a single short prompt is one quoted string
expect_equal(wrap_prompt("hello", width = 56), '  "hello"')
