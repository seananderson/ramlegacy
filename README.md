<!-- README.md is generated from README.Rmd. Please edit that file -->

Import the RAM Legacy Stock Assessment Database into R
======================================================

[![Travis-CI Build
Status](https://travis-ci.org/seananderson/ramlegacy.svg?branch=master)](https://travis-ci.org/seananderson/ramlegacy)
[![Lifecycle:
superseded](https://img.shields.io/badge/lifecycle-superseded-orange.svg)](https://www.tidyverse.org/lifecycle/#superseded)

**Please use Carl Boettiger and Gupta Kshitiz’s ramlegacy package
<a href="https://github.com/ropensci/ramlegacy" class="uri">https://github.com/ropensci/ramlegacy</a>
instead.**

This package does one thing: it downloads a Microsoft Access copy of the
[RAM Legacy Stock Assessment Database](http://ramlegacy.org) and
converts it to a local sqlite3 database. This makes it easy to [work
with
dplyr/dbplyr](https://cran.r-project.org/web/packages/dbplyr/vignettes/dbplyr.html),
for example. The `make_ramlegacy()` function also leaves a copy of
`.csv` files for each table in the database in the R working directory
if you’d prefer to work with those.

**Note that you must have the utility `mdb-tables` installed** and in
your path from `mdbtools`. This utility provides tools for extracting
Access databases. You can find installation instructions at
<a href="http://mdbtools.sourceforge.net" class="uri">http://mdbtools.sourceforge.net</a>.
If you’re on OS X and using homebrew, you can install it with
`brew install mdbtools`.

### Example use

Install the package:

``` r
# install.packages("devtools")
devtools::install_github("seananderson/ramlegacy")
```

Cache and convert the database:

``` r
library("ramlegacy")
make_ramlegacy()
#> Converting table area
#> Converting table assessment
#> Converting table assessmethod
#> Converting table assessor
#> Converting table biometrics
#> Converting table bioparams
#> Converting table bioparams_units_views
#> Converting table bioparams_values_views
#> Converting table management
#> Converting table model_results
#> Converting table stock
#> Converting table taxonomy
#> Converting table timeseries
#> Converting table timeseries_units_views
#> Converting table timeseries_values_views
#> Converting table tsmetrics
```

Work with the data:

``` r
library("dplyr")
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
ram <- src_sqlite("ramlegacy.sqlite3")
ram # see the available tables
#> src:  sqlite 3.19.3 [/Users/seananderson/src/ramlegacy/ramlegacy.sqlite3]
#> tbls: area, assessment, assessmethod, assessor, biometrics, bioparams,
#>   bioparams_units_views, bioparams_values_views, management,
#>   model_results, sqlite_stat1, sqlite_stat4, stock, taxonomy, timeseries,
#>   timeseries_units_views, timeseries_values_views, tsmetrics
```

Access the `area` table:

``` r
tbl(ram, "area")
#> # Source:   table<area> [?? x 6]
#> # Database: sqlite 3.19.3
#> #   [/Users/seananderson/src/ramlegacy/ramlegacy.sqlite3]
#>    country   areatype areacode areaname        alternateareaname areaid   
#>    <chr>     <chr>    <chr>    <chr>           <chr>             <chr>    
#>  1 Argentina CFP      ARG-N    Northern Argen… <NA>              Argentin…
#>  2 Argentina CFP      ARG-S    Southern Argen… <NA>              Argentin…
#>  3 Australia AFMA     CASCADE  Cascade Plateau <NA>              Australi…
#>  4 Australia AFMA     ESE      Eastern half o… <NA>              Australi…
#>  5 Australia AFMA     GAB      Great Australi… <NA>              Australi…
#>  6 Australia AFMA     MI       Macquarie Isla… ""                Australi…
#>  7 Australia AFMA     NAUST    Northern Austr… <NA>              Australi…
#>  8 Australia AFMA     NSWWA    New South Wale… <NA>              Australi…
#>  9 Australia AFMA     SE       Southeast Aust… <NA>              Australi…
#> 10 Australia AFMA     TAS      Tasmania        <NA>              Australi…
#> # ... with more rows
```

Join the time series `ts` and `stock` tables on the `stockid` column:

``` r
ts <- tbl(ram, "timeseries")
stock <- tbl(ram, "stock")
select(stock, stockid, scientificname, commonname, region) %>%
  inner_join(ts)
#> Joining, by = "stockid"
#> # Source:   lazy query [?? x 9]
#> # Database: sqlite 3.19.3
#> #   [/Users/seananderson/src/ramlegacy/ramlegacy.sqlite3]
#>    stockid  scientificname  commonname region assessid  stocklong   tsid  
#>    <chr>    <chr>           <chr>      <chr>  <chr>     <chr>       <chr> 
#>  1 ACADRED… Sebastes fasci… Acadian r… US Ea… NEFSC-AC… Acadian re… BdivB…
#>  2 ACADRED… Sebastes fasci… Acadian r… US Ea… NEFSC-AC… Acadian re… BdivB…
#>  3 ACADRED… Sebastes fasci… Acadian r… US Ea… NEFSC-AC… Acadian re… BdivB…
#>  4 ACADRED… Sebastes fasci… Acadian r… US Ea… NEFSC-AC… Acadian re… BdivB…
#>  5 ACADRED… Sebastes fasci… Acadian r… US Ea… NEFSC-AC… Acadian re… BdivB…
#>  6 ACADRED… Sebastes fasci… Acadian r… US Ea… NEFSC-AC… Acadian re… BdivB…
#>  7 ACADRED… Sebastes fasci… Acadian r… US Ea… NEFSC-AC… Acadian re… BdivB…
#>  8 ACADRED… Sebastes fasci… Acadian r… US Ea… NEFSC-AC… Acadian re… BdivB…
#>  9 ACADRED… Sebastes fasci… Acadian r… US Ea… NEFSC-AC… Acadian re… BdivB…
#> 10 ACADRED… Sebastes fasci… Acadian r… US Ea… NEFSC-AC… Acadian re… BdivB…
#> # ... with more rows, and 2 more variables: tsyear <dbl>, tsvalue <dbl>
```

Note that because you are working with dplyr and a database, you will
need to use `dplyr::collect()` once you want to load the data into a
local data frame. For example:

``` r
tbl(ram, "area") %>% 
  collect()
#> # A tibble: 275 x 6
#>    country   areatype areacode areaname        alternateareaname areaid   
#>    <chr>     <chr>    <chr>    <chr>           <chr>             <chr>    
#>  1 Argentina CFP      ARG-N    Northern Argen… <NA>              Argentin…
#>  2 Argentina CFP      ARG-S    Southern Argen… <NA>              Argentin…
#>  3 Australia AFMA     CASCADE  Cascade Plateau <NA>              Australi…
#>  4 Australia AFMA     ESE      Eastern half o… <NA>              Australi…
#>  5 Australia AFMA     GAB      Great Australi… <NA>              Australi…
#>  6 Australia AFMA     MI       Macquarie Isla… ""                Australi…
#>  7 Australia AFMA     NAUST    Northern Austr… <NA>              Australi…
#>  8 Australia AFMA     NSWWA    New South Wale… <NA>              Australi…
#>  9 Australia AFMA     SE       Southeast Aust… <NA>              Australi…
#> 10 Australia AFMA     TAS      Tasmania        <NA>              Australi…
#> # ... with 265 more rows
```

For safety, you may want to use `dplyr::collect(n = Inf)` to return all
rows of data, not just the minimum default number. In this case it won’t
make a difference.

``` r
tbl(ram, "area") %>% 
  collect(n = Inf)
#> # A tibble: 275 x 6
#>    country   areatype areacode areaname        alternateareaname areaid   
#>    <chr>     <chr>    <chr>    <chr>           <chr>             <chr>    
#>  1 Argentina CFP      ARG-N    Northern Argen… <NA>              Argentin…
#>  2 Argentina CFP      ARG-S    Southern Argen… <NA>              Argentin…
#>  3 Australia AFMA     CASCADE  Cascade Plateau <NA>              Australi…
#>  4 Australia AFMA     ESE      Eastern half o… <NA>              Australi…
#>  5 Australia AFMA     GAB      Great Australi… <NA>              Australi…
#>  6 Australia AFMA     MI       Macquarie Isla… ""                Australi…
#>  7 Australia AFMA     NAUST    Northern Austr… <NA>              Australi…
#>  8 Australia AFMA     NSWWA    New South Wale… <NA>              Australi…
#>  9 Australia AFMA     SE       Southeast Aust… <NA>              Australi…
#> 10 Australia AFMA     TAS      Tasmania        <NA>              Australi…
#> # ... with 265 more rows
```
