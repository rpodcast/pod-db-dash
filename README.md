## PodcastIndex Database Dashboard

The PodcastIndex Database Dashboard is an interactive web application which displays potential duplicate podcast entries currently in the PodcastIndex database, as well as custom quality assessments of the database. The dashboard is updated every week and deployed via GitHub actions.

## Background and Motivation

The [Podcast Index](https://podcastindex.org) is an independent and open catalog of podcasts feeds serving as the backbone of what is referred to as the Podcasting 2.0 initiative. The data contained in the Podcast Index is available through a robust [REST API](https://podcastindex-org.github.io/docs-api/#overview--libraries) as well as a [SQLite database](https://public.podcastindex.org/podcastindex_feeds.db.tgz) updated every week. 

In previous episodes of [Podcasting 2.0](https://podcastindex.org/podcast/920666), Dave Jones lamented that duplicate podcast entries in the Podcast Index can cause annoying issues for many podcast apps and other services relying on the integrity of the index. Seeing an opportunity to help this amazing project, I sent a boost to the show in [episode 156](https://podverse.fm/episode/hLh98zHNo) to offer up a new solution powered by the R statistical computing language for identifiying potential duplicates alongside other data quality issues. Hence the objectives of this dashboard are to highlight potential duplicate podcast entries as well as perform quality assessments of the index to highlight potential issues.

## Tech Stack

Much like the ethos behind podcasting 2.0, the PodcastIndex Dashboard is proudly built on the foundations of open-source:

* [Quarto](https://quarto.org) technical publishing system with the new capability of dashboards.
* The [R](https://r-project.org) project for statistical computing with the following amazing packages:
    + [`{reclin2}`](https://github.com/djvanderlaan/reclin2): Record linkage toolkit for R.
    + [`{pointblank}`](https://rstudio.github.io/pointblank/): Data quality assessment and metadata reporting for data frames and database tables. 
    + [`{reactable}`](https://glin.github.io/reactable/index.html): Interactive data tables for R, based on the [React Table](https://github.com/tanstack/table/tree/v7) and made with [`{reactR}`](https://github.com/react-R/reactR).
    + [`{reactablefmtr}`](https://kcuilla.github.io/reactablefmtr/index.html): Streamlined table styling and formatting for `{reactable}` tables.
    + [`{dplyr}`](https://dplyr.tidyverse.org/): A grammar of data manipulation

## Analysis Pipeline

The duplicate records and data quality analysis pipelines are executed weekly (after the Podcast Index SQLite database is refreshed) as scheduled GitHub Action workflows. Visit the GitHub repository at <https://github.com/rpodcast/pod-db-checker> to find the following scripts:
* [`duplicate_runner.R`](https://github.com/rpodcast/pod-db-checker/blob/main/duplicate_runner.R): Performs duplication analysis and necessary data pre-processing.
* [`pointblank_runner.R`](https://github.com/rpodcast/pod-db-checker/blob/main/pointblank_runner.R): Execute data quality checks with the `{pointblank}` package.