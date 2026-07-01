# Register piknit's knitr engines

Registers the `pi` and `pish` engines with knitr. Called automatically
from `.onLoad`, so
[`library(piknit)`](https://github.com/sounkou-bioinfo/piknit) is
enough; exported for manual re-registration (e.g. after another package
overwrites an engine name).

## Usage

``` r
register_engines()
```

## Value

Invisibly `TRUE`.
