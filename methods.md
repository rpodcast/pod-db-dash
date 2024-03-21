<h3>Introduction</h3>

The [Podcast Index](https://podcastindex.org) is an independent and open catalog of podcasts feeds serving as the backbone of what is referred to as the Podcasting 2.0 initiative. The data contained in the Podcast Index is available through a robust [REST API](https://podcastindex-org.github.io/docs-api/#overview--libraries) as well as a [SQLite database](https://public.podcastindex.org/podcastindex_feeds.db.tgz) updated every week. 

In previous episodes of [Podcasting 2.0](https://podcastindex.org/podcast/920666), Dave Jones lamented that duplicate podcast entries in the Podcast Index can cause annoying issues for many podcast apps and other services relying on the integrity of the index. Seeing an opportunity to help this amazing project, I sent a boost to the show in [episode 156](https://podverse.fm/episode/hLh98zHNo) to offer up a new solution powered by the R statistical computing language for identifiying potential duplicates alongside other data quality issues. Hence the objectives of this dashboard are to highlight potential duplicate podcast entries as well as perform quality assessments of the index to highlight potential issues.

<h3>Duplicates Analysis</h3>

The methodology used to identify candidate duplicates is a technique called [record linkage](https://rpubs.com/ahmademad/RecordLinkage). At a high level, record linkage evaluates possible pairwise combinations of records from two data sets (or in the case of de-duplication, a single data set compared to itself) and determines if a given pair are likely to originate from the same entity. For a data set the size of the Podcast Index, it would be next to impossible to perform the analysis on all pairwise combinations of records. Next we describe the techniques for pruning the possible record combinations and the criteria used to categorize a given pair as a possible duplicate. Within R, we leverage the [`{reclin2}`](https://github.com/djvanderlaan/reclin2) package that strikes a nice balance between performance and logical workflow for performing probabilistic record linkage and de-duplication.

<h4>Reducing Candidate Pairs</h4>

To reduce candidate record pairs supplied to the record linkage analyses, we apply a technique called **blocking**, which requires a pair of records to agree on one or multiple variables before it can be moved to further analysis. For this analysis, we are using the **title** and **content hash** variables as the blocking variables. 

<h4>Comparing Pairs</h4>

With the candidate pairs available, the next step is to derive a similarity score between the records in a given pair based on a set of variables common between the records. Based on advice from the Pod Sage Dave Jones, we use the following variables for comparison:

* URL
* Newest Enclosure URL
* Image URL

The statistical method used to derive the similarity score is the [Jaro-Winkler distance](https://en.wikipedia.org/wiki/Jaro%E2%80%93Winkler_distance) metric, which is a great fit for the URL variables. The metric produces a score ranging from 0 (no match in any of the string characters) to 1 (perfect match between the strings). The algorithm can be customized with a threshold value that gives a cutoff for determining if the two strings are a likely match. For this analysis we use a threshold of 0.95, but this is up for discussion as there is a tradeoff between a threshold value and the number of candidate duplicate groupings identified. This is a subject that requires further attention going forward.

With the Jaro-WInkler distance score calculated, only the records with a score of 0.95 or above will be retained for further evaluation.

<h4>Derive Duplicate Groups</h4>

Once the candidate pairs are pruned with the threshold cutoff, the last step is to organize the potential duplicate records into groups. The dashboard presents each of these groups with the ability to drill down within each group and inspect the records that were considered duplicates.