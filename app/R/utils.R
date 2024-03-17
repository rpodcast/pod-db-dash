hello_world <- function() {
  print("Hello World!")
}

podcastdb_pointblank_object <- function() {
  tmp_file <- tempfile(pattern = "pointblank")
  download.file(
    url = config::get("pointblank_object_path"),
    destfile = tmp_file
  )

  res <- pointblank::x_read_disk(
    filename = fs::path_file(tmp_file),
    path = fs::path_dir(tmp_file)
  )

  unlink(tmp_file)
  return(res)
}

podcastdb_dupdf_object <- function() {
  tmp_file <- tempfile(pattern = "dupdf")

  download.file(
    url = config::get("podcast_dup_df_path"),
    destfile = tmp_file
  )

  res <- readRDS(tmp_file)

  unlink(tmp_file)
  return(res)
}

podcastdb_analysisdf_object <- function() {
  tmp_file <- tempfile(pattern = "analysisdf")

  download.file(
    url = config::get("podcast_analysis_df_path"),
    destfile = tmp_file
  )

  res <- readRDS(tmp_file)

  unlink(tmp_file)
  return(res)
}
