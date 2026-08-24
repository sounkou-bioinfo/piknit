# Wrap a prompt onto short, runnable shell-string lines

Splits `prompt` into shell-quoted segments passed to `printf` inside one
command substitution. The displayed command remains readable while the
shell supplies Pi exactly one prompt argument with the original text.

## Usage

``` r
wrap_prompt(prompt, width = 56)
```

## Arguments

- prompt:

  A single prompt string.

- width:

  Target maximum line width in characters (default 56).

## Value

A single string: the wrapped, continuation-joined shell strings.

## Examples

``` r
cat(wrap_prompt("count the variants by consequence in the manifest", 24))
#>   "$(printf %s \
#>     'count the variants by ' \
#>     'consequence in the ' \
#>     'manifest')"
```
