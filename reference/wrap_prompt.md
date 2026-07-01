# Wrap a prompt onto short, runnable shell-string lines

Splits `prompt` on spaces into adjacent double-quoted shell strings
(which a POSIX shell concatenates) no wider than `width`, each but the
last ending in a line continuation. Used to render a long prompt as a
readable, still runnable, multi-line command.

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
#>   "count the variants by " \
#>   "consequence in the " \
#>   "manifest"
```
