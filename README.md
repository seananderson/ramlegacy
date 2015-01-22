# Import the RAM Legacy Stock Assessment Database into R

This package does one thing right now: it downloads the latest Microsoft Access version of the [RAM Legacy Stock Assessment Database](http://ramlegacy.org) (version 2.5) and converts it to a local sqlite3 database. This makes it easy to [work with dplyr](http://cran.r-project.org/web/packages/dplyr/vignettes/databases.html), for example. The `make_ramlegacy()` function also leaves a copy of `.csv` files for each table in the database in the R working directory if you'd prefer to work with those. Eventually I may add additional functionality.

**Note that you must have the utility `mdb-tables` installed** and in your path. This utility provides tools for extracting Access databases. You can find installation instructions at <http://mdbtools.sourceforge.net>. If you're on OS X and using homebrew, you can install it with `brew install mdbtools`.

### Example use



Install the package:


```r
# install.packages("devtools")
devtools::install_github("seananderson/ramlegacy")
```

Cache and convert the database:


```r
library("ramlegacy")
make_ramlegacy()
```

```
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
```

Work with the data:


```r
library("dplyr")
ram <- src_sqlite("ramlegacy.sqlite3")
ram # see the available tables
```

```
## src:  sqlite 3.8.6 [ramlegacy.sqlite3]
## tbls: area, assessment, assessmethod, assessor, biometrics, bioparams,
##   bioparams_units_views, bioparams_values_views, management,
##   model_results, sqlite_stat1, stock, taxonomy, timeseries,
##   timeseries_units_views, timeseries_values_views, tsmetrics
```

Access the `area` table:


```r
area <- tbl(ram, "area")
glimpse(area)
```

```
## Variables:
## $ country           (chr) "Argentina", "Argentina", "Australia", "Aust...
## $ areatype          (chr) "CFP", "CFP", "AFMA", "AFMA", "AFMA", "AFMA"...
## $ areacode          (chr) "ARG-N", "ARG-S", "CASCADE", "ESE", "GAB", "...
## $ areaname          (chr) "Northern Argentina", "Southern Argentina", ...
## $ alternateareaname (chr) NA, NA, NA, NA, NA, "", NA, NA, NA, NA, NA, ...
## $ areaid            (chr) "Argentina-CFP-ARG-N", "Argentina-CFP-ARG-S"...
```

Join the time series `ts` and `stock` tables on the `stockid` column:


```r
ts <- tbl(ram, "timeseries")
stock <- tbl(ram, "stock")
select(stock, stockid, scientificname, commonname, region) %>%
  inner_join(ts) %>%
  glimpse
```

```
## Joining by: "stockid"
```

```
## Variables:
## $ stockid        (chr) "ACADREDGOMGB", "ACADREDGOMGB", "ACADREDGOMGB",...
## $ scientificname (chr) "Sebastes fasciatus", "Sebastes fasciatus", "Se...
## $ commonname     (chr) "Acadian redfish", "Acadian redfish", "Acadian ...
## $ region         (chr) "US East Coast", "US East Coast", "US East Coas...
## $ assessid       (chr) "NEFSC-ACADREDGOMGB-1913-2007-MILLER", "NEFSC-A...
## $ stocklong      (chr) "Acadian redfish Gulf of Maine / Georges Bank",...
## $ tsid           (chr) "BdivBmsytouse-dimensionless", "BdivBmsytouse-d...
## $ tsyear         (dbl) 1913, 1914, 1915, 1916, 1917, 1918, 1919, 1920,...
## $ tsvalue        (dbl) 2.37, 2.37, 2.37, 2.37, 2.37, 2.37, 2.37, 2.37,...
```
