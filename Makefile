# h/t @jimhester and @yihui for the DESCRIPTION parse block.
PKGNAME := $(shell sed -n 's/Package: *\([^ ]*\)/\1/p' DESCRIPTION)
PKGVERS := $(shell sed -n 's/Version: *\([^ ]*\)/\1/p' DESCRIPTION)

all: check

# regenerate man/ + NAMESPACE from roxygen2 tags
rd:
	R -e 'roxygen2::roxygenise()'

build:
	R CMD build .

check: build
	R CMD check --as-cran --no-manual $(PKGNAME)_$(PKGVERS).tar.gz

install:
	R CMD INSTALL .

install_deps:
	R \
	-e 'if (!requireNamespace("remotes")) install.packages("remotes")' \
	-e 'remotes::install_deps(dependencies = TRUE)'

test: install
	R -e "tinytest::test_package('$(PKGNAME)', testdir = 'inst/tinytest')"

# render README.Rmd (runs a LIVE pi agent + pish; needs pi on PATH and a model)
rdm: install
	R -e "rmarkdown::render('README.Rmd')" && rm -f README.html

# build the pkgdown site into docs/
site: install
	R -e "pkgdown::build_site()"

clean:
	@rm -rf $(PKGNAME)_$(PKGVERS).tar.gz $(PKGNAME).Rcheck README.html

.PHONY: all rd build check install install_deps test rdm site clean
