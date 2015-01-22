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
