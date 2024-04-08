<h3>Tech Stack</h3>

Much like the ethos behind podcasting 2.0, the PodcastIndex Dashboard is proudly built on the foundations of open-source:

* [Quarto](https://quarto.org) technical publishing system with the new capability of dashboards.
* The [R](https://r-project.org) project for statistical computing with the following amazing packages:
    + [`{reclin2}`](https://github.com/djvanderlaan/reclin2): Record linkage toolkit for R.
    + [`{pointblank}`](https://rstudio.github.io/pointblank/): Data quality assessment and metadata reporting for data frames and database tables. 
    + [`{reactable}`](https://glin.github.io/reactable/index.html): Interactive data tables for R, based on the [React Table](https://github.com/tanstack/table/tree/v7) and made with [`{reactR}`](https://github.com/react-R/reactR).
    + [`{reactablefmtr}`](https://kcuilla.github.io/reactablefmtr/index.html): Streamlined table styling and formatting for `{reactable}` tables.
    + [`{dplyr}`](https://dplyr.tidyverse.org/): A grammar of data manipulation

<h3>Analysis Pipeline</h3>

The duplicate records and data quality analysis pipelines are executed weekly (after the Podcast Index SQLite database is refreshed) as scheduled GitHub Action workflows. Visit the GitHub repository at <https://github.com/rpodcast/pod-db-checker> to find the following scripts:

* [`duplicate_runner.R`](https://github.com/rpodcast/pod-db-checker/blob/main/duplicate_runner.R): Performs duplication analysis and necessary data pre-processing.
* [`pointblank_runner.R`](https://github.com/rpodcast/pod-db-checker/blob/main/pointblank_runner.R): Execute data quality checks with the `{pointblank}` package.

![[rpodcast@getalby.com](https://getalby.com/p/rpodcast)](assets/img/lightning_qr_code.png){width=20%}