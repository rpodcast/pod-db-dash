hello_world <- function() {
  print("Hello World!")
}

podcastdb_pointblank_object <- function(url, dev_mode = FALSE) {
  if (dev_mode) {
    tmp_file <- "dev_files/podcastdb_pointblank_object"
  } else {
    tmp_file <- tempfile(pattern = "pointblank")
    download.file(
      url = url,
      destfile = tmp_file
    )
  }
  res <- pointblank::x_read_disk(
    filename = fs::path_file(tmp_file),
    path = fs::path_dir(tmp_file)
  )

  #unlink(tmp_file)
  return(res)
}

get_pointblank_data_extracts <- function(pointblank_object, exports_root_path, dev_mode = FALSE) {
  meta_df <- pointblank_object$validation_set

  failed_i_values <- meta_df |>
    dplyr::filter(!all_passed) |>
    dplyr::pull(i)

  failed_step_id_values <- meta_df |>
    dplyr::filter(!all_passed) |>
    dplyr::pull(step_id)

  extract_list <- purrr::map(failed_step_id_values, ~{
    if (dev_mode) {
      tmp_file <- glue::glue("dev_files/{.x}.rds")
    } else {
      tmp_file <- tempfile(pattern = .x)
      download.file(
        url = paste0(url, glue::glue("/{.x}.rds")),
        destfile = tmp_file
      )
    }
    res <- readRDS(tmp_file)
    return(res)
  })

  names(extract_list) <- failed_step_id_values
  return(extract_list)
}

podcastdb_dupdf_object <- function(url, dev_mode = FALSE) {
  if (dev_mode) {
    tmp_file <- "dev_files/podcast_dup_df.rds"
  } else {
    tmp_file <- tempfile(pattern = "dupdf")

    download.file(
      url = url,
      destfile = tmp_file
    )
  }

  res <- readRDS(tmp_file)
  #unlink(tmp_file)
  return(res)
}

podcastdb_analysisdf_object <- function(url, dev_mode = FALSE) {
  if (dev_mode) {
    tmp_file <- "dev_files/analysis_metrics_df.rds"
  } else {
    tmp_file <- tempfile(pattern = "analysisdf")

    download.file(
      url = url,
      destfile = tmp_file
    )
  }

  res <- readRDS(tmp_file)
  #unlink(tmp_file)
  return(res)
}

podcastdb_log_object <- function(root_url, date = format(Sys.time(), "%Y-%m-%d")) {
  tmp_file <- tempfile(pattern = "dblog")

  download.file(
    url = paste0(root_url, paste0("pdblog_", date, ".log")),
    destfile = tmp_file
  )

  res <- readLines(tmp_file) |>
    purrr::map_dfr(~jsonlite::fromJSON(.x))
  return(res)
}

podcastdb_timestamp_object <- function(url, dev_mode = FALSE) {
  if (dev_mode) {
    tmp_file <- "dev_files/job_timestamp.txt"
  } else {
    tmp_file <- tempfile(pattern = "job_timestamp")

    download.file(
      url = url,
      destfile = tmp_file
    )
  }
  res <- readLines(tmp_file)
  return(res)
}

date_report <- function(log_object, tz = "UTC") {
  dt <- log_object |>
    filter(arg1 == "Downloading podcast database") |>
    pull(time)

  paste(dt, tz)
}

number <- scales::number_format(big.mark = ",")


# create concatenated list of categories
gen_categories_df <- function(data) {
  data <- dplyr::select(data, id, starts_with("category"))
  data_long <- tidyr::pivot_longer(
    data,
    cols = starts_with("category"),
    names_to = "category_index",
    values_to = "category_value"
  ) |>
    dplyr::filter(category_value != "")

  data_sum <- data_long |>
    group_by(id) |>
    summarize(category = glue::glue_collapse(category_value, ", ", last = " and ")) |>
    ungroup()
  return(data_sum)
}

clean_podcast_df <- function(podcast_dup_df, dev_mode = FALSE) {
  df <- podcast_dup_df |>
  tibble::as_tibble() |>
  mutate(newestItemPubdate = na_if(newestItemPubdate, 0),
         oldestItemPubdate = na_if(oldestItemPubdate, 0),
         title = na_if(title, ""),
         lastUpdate = na_if(lastUpdate, 0),
         createdOn = na_if(createdOn, 0),
         newestEnclosureDuration = na_if(newestEnclosureDuration, 0)) |>
  mutate(lastUpdate_p = anytime(lastUpdate),
         newestItemPubdate_p = anytime(newestItemPubdate),
         oldestItemPubdate_p = anytime(oldestItemPubdate),
         createdOn_p = anytime(createdOn)) |>
  mutate(pub_timespan_days = lubridate::interval(oldestItemPubdate_p, newestItemPubdate_p) / lubridate::ddays(1)) |>
  mutate(created_timespan_days = lubridate::interval(createdOn_p, Sys.time()) / lubridate::ddays(1))

  # obtain categories df
  cat_df <- gen_categories_df(df)

  # preprocessing
  df <- df |>
    dplyr::select(!starts_with("category")) |>
    left_join(cat_df, by = "id") |>
    dplyr::mutate(
      episodeCount_colors = dplyr::case_when(
        episodeCount >= 0 ~ 'darkgreen',
        TRUE ~ 'orange'
      )
    ) |>
    dplyr::mutate(
      imageUrl = dplyr::case_when(
        imageUrl == "" ~ "https://podcastindex.org/images/no-cover-art.png",
        stringr::str_length(imageUrl) < 29 ~ "https://podcastindex.org/images/no-cover-art.png",
        !grepl("https|http", imageUrl) ~ "https://podcastindex.org/images/no-cover-art.png",
        .default = imageUrl
      )
    ) |>
    dplyr::select(-newestItemPubdate, -oldestItemPubdate, -createdOn, -lastUpdate) |>
    dplyr::select(imageUrl, podcastGuid, title, url, lastUpdate_p, newestEnclosureDuration, newestItemPubdate_p, oldestItemPubdate_p, episodeCount, everything())

  if (dev_mode) df <- dplyr::slice(df, 1:100)

  return(df)
}
