## PodcastIndex Database Dashboard

The PodcastIndex Database Dashboard is an interactive web application which displays potential duplicate podcast entries currently in the PodcastIndex database, as well as custom quality assessments of the database. The dashboard is updated every week and deployed via GitHub actions.

## Background and Motivation

The [Podcast Index](https://podcastindex.org) is an independent and open catalog of podcasts feeds serving as the backbone of what is referred to as the Podcasting 2.0 initiative. The data contained in the Podcast Index is available through a robust [REST API](https://podcastindex-org.github.io/docs-api/#overview--libraries) as well as a [SQLite database](https://public.podcastindex.org/podcastindex_feeds.db.tgz) updated every week. 

In previous episodes of [Podcasting 2.0](https://podcastindex.org/podcast/920666), Dave Jones lamented that duplicate podcast entries in the Podcast Index can cause annoying issues for many podcast apps and other services relying on the integrity of the index. Seeing an opportunity to help this amazing project, I sent a boost to the show in [episode 156](https://podverse.fm/episode/hLh98zHNo) to offer up a new solution powered by the R statistical computing language for identifiying potential duplicates alongside other data quality issues. Hence the objectives of this dashboard are to highlight potential duplicate podcast entries as well as perform quality assessments of the index to highlight potential issues.
