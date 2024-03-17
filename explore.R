# Explore data sets
library(dplyr)
library(tidyr)
library(purrr)
library(reactable)
library(reactablefmtr)
library(htmltools)
library(pointblank)
library(anytime)

source("quarto_dashboard/R/utils.R")
source("quarto_dashboard/R/fct_tables.R")

pod_dup_df <- podcastdb_dupdf_object("https://podcast20-projects.us-east-1.linodeobjects.com/exports/podcast_dup_df.rds")
pod_an_df <- podcastdb_analysisdf_object("https://podcast20-projects.us-east-1.linodeobjects.com/exports/analysis_metrics_df.rds")
pointblank_object <- podcastdb_pointblank_object("https://podcast20-projects.us-east-1.linodeobjects.com/exports/podcastdb_pointblank_object/podcastdb_pointblank_object")

pb_extracts <- get_data_extracts(pointblank_object)

pb_extracts_sub <- pb_extracts[c('1', '3', '4', '7')]

pb_extracts_sub_clean <- purrr::map(
  pb_extracts_sub,
  ~clean_podcast_df(.x),
  .progress = TRUE
)

val_set <- pointblank_object$validation_set

log_list <- podcastdb_log_object(
  root_url = "https://podcast20-projects.us-east-1.linodeobjects.com/logs/",
  date = "2024-03-11"
) |>
date_report()

#saveRDS(pod_dup_df, file = "dbfiles/pod_dup_df.rds")
#saveRDS(pod_an_df, file = "dbfiles/pod_an_df.rds")

pod_dup_df |>
  filter(id == 792) |>
  #View()
  record_detail_table()

df <- pod_dup_df |>
  mutate(
    imageUrl = case_when(
      imageUrl == "" ~ "https://podcastindex.org/images/no-cover-art.png",
      stringr::str_length(imageUrl) < 29 ~ "https://podcastindex.org/images/no-cover-art.png",
      .default = imageUrl
    )
  )

df |>
  filter(!grepl("https|http", imageUrl))

pod_an_df <- pod_an_df |>
  mutate(
    pub_timespan_days_list = purrr::flatten(pub_timespan_days_list)
  ) |>
  mutate(
    pub_timespan_days_list = purrr::map(pub_timespan_days_list, ~{
      dplyr::coalesce(.x, 0L)
    })
  )

df_sub <- select(pod_an_df, record_group, pub_timespan_days_list)

reactable(
  df_sub,
  columns = list(
    pub_timespan_days_list = colDef(
      cell = react_sparkline(df_sub)
    )
  )
)
