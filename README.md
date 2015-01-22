Download and convert the RAM Legacy Stock Assessment Database in R
==================================================================

This package does one thing right now: it downloads the latest Microsoft
Access version of the [RAM Legacy Stock Assessment
Database](http://ramlegacy.org) (version 2.5) and converts it to a local
sqlite3 database. This makes it easy to [work with
dplyr](http://cran.r-project.org/web/packages/dplyr/vignettes/databases.html),
for example. The `make_ramlegacy()` function also leaves a copy of
`.csv` files for each table in the database in the R working directory.

Perhaps eventually I'll add additional functionality, but for now I just
wanted a reproducible way to bring the latest copy of the database into
a local (non-Access) database that I could use with R.

### Example use

Install the package:

    # install.packages("devtools")
    devtools::install_github("seananderson/ramlegacy")

Cache and convert the database:

    library("ramlegacy")
    make_ramlegacy()

    ## Converting table area
    ## Converting table assessment
    ## Converting table assessmethod
    ## Converting table assessor
    ## Converting table biometrics
    ## Converting table bioparams
    ## Converting table bioparams_units_views
    ## Converting table bioparams_values_views
    ## Converting table management
    ## Converting table model_results
    ## Converting table stock
    ## Converting table taxonomy
    ## Converting table timeseries
    ## Converting table timeseries_units_views
    ## Converting table timeseries_values_views
    ## Converting table tsmetrics

Work with the data:

    library("dplyr")

    ## 
    ## Attaching package: 'dplyr'
    ## 
    ## The following object is masked from 'package:stats':
    ## 
    ##     filter
    ## 
    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

    ram <- src_sqlite("ramlegacy.sqlite3")
    ram

    ## src:  sqlite 3.8.6 [ramlegacy.sqlite3]
    ## tbls: area, assessment, assessmethod, assessor, biometrics, bioparams,
    ##   bioparams_units_views, bioparams_values_views, management,
    ##   model_results, sqlite_stat1, stock, taxonomy, timeseries,
    ##   timeseries_units_views, timeseries_values_views, tsmetrics

    area <- tbl(ram, "area")
    glimpse(area)

    ## Variables:
    ## $ country           (chr) "Argentina", "Argentina", "Australia", "Aust...
    ## $ areatype          (chr) "CFP", "CFP", "AFMA", "AFMA", "AFMA", "AFMA"...
    ## $ areacode          (chr) "ARG-N", "ARG-S", "CASCADE", "ESE", "GAB", "...
    ## $ areaname          (chr) "Northern Argentina", "Southern Argentina", ...
    ## $ alternateareaname (chr) NA, NA, NA, NA, NA, "", NA, NA, NA, NA, NA, ...
    ## $ areaid            (chr) "Argentina-CFP-ARG-N", "Argentina-CFP-ARG-S"...

    ts <- tbl(ram, "timeseries")
    stock <- tbl(ram, "stock")
    select(stock, stockid, scientificname, commonname, region) %>%
      inner_join(select(ts, -tsid, -assessid, -stocklong)) %>%
      glimpse

    ## Joining by: "stockid"

    ## Variables:
    ## $ stockid        (chr) "ACADREDGOMGB", "ACADREDGOMGB", "ACADREDGOMGB",...
    ## $ scientificname (chr) "Sebastes fasciatus", "Sebastes fasciatus", "Se...
    ## $ commonname     (chr) "Acadian redfish", "Acadian redfish", "Acadian ...
    ## $ region         (chr) "US East Coast", "US East Coast", "US East Coas...
    ## $ tsyear         (dbl) 1913, 1914, 1915, 1916, 1917, 1918, 1919, 1920,...
    ## $ tsvalue        (dbl) 2.37, 2.37, 2.37, 2.37, 2.37, 2.37, 2.37, 2.37,...
