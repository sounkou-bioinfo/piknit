# The reply from a Pi agent turn

[`pi_run()`](https://sounkou-bioinfo.github.io/piknit/reference/pi_run.md)
and a session's `ask()` return a `pi_reply`: the agent's output as a
character vector (one element per line) carrying the `prompt` and
`model` as attributes, with a print method that writes the lines
plainly. So a reply prints as the agent wrote it — in an R console, a
script, or a knitr chunk — instead of as a quoted character vector.

## Usage

``` r
# S3 method for class 'pi_reply'
print(x, ...)

# S3 method for class 'pi_reply'
as.character(x, ...)
```

## Arguments

- x:

  A `pi_reply`.

- ...:

  Ignored.

## Value

[`print()`](https://rdrr.io/r/base/print.html) returns `x` invisibly;
[`as.character()`](https://rdrr.io/r/base/character.html) returns the
plain reply lines with attributes stripped.

## Examples

``` r
r <- structure(c("hello", "world"), class = "pi_reply")
r
#> hello
#> world
as.character(r)
#> [1] "hello" "world"
```
