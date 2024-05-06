# Select input filter with an "All" default option
selectFilter <- function(tableId, style = "width: 100%; height: 100%;") {
  function(values, name) {
    tags$select(
      # Set to undefined to clear the filter
      onchange = sprintf("
        const value = event.target.value
        Reactable.setFilter('%s', '%s', value === '__ALL__' ? undefined : value)
      ", tableId, name),
      # "All" has a special value to clear the filter, and is the default option
      tags$option(value = "__ALL__", "All"),
      lapply(unique(values), tags$option),
      "aria-label" = sprintf("Filter %s", name),
      style = style
    )
  }
}

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

podcast_db_theme <- function() {
  reactableTheme(
    style = list(fontSize = '0.875rem')
  )
}

pointblank_table <- function(pointblank_object, report_date, extracts = NULL) {
  lookup_df <- pointblank_object$validation_set |>
    select(i, i_o, step_id, label)

  df <- pointblank_object$validation_set |>
    mutate(
      f_passed_colors = case_when(
        f_passed < 0.5 ~ "#FDE725FF",
        between(f_passed, 0.5, 0.7) ~ "#35B779FF",
        between(f_passed, 0.7, 0.9) ~ "#31688EFF",
        TRUE ~ "#440154FF"
      ),
      all_passed_icons = case_when(
        !all_passed ~"square-xmark",
        TRUE ~ "square-check"
      ),
      all_passed_colors = case_when(
        !all_passed ~ "red",
        TRUE ~ "darkgreen"
      )
    ) |>
    select(label, n, all_passed, proc_duration_s, n_passed, n_failed, f_passed, f_failed, step_id, assertion_type, all_passed_colors, all_passed_icons, f_passed_colors, i)

  tbl <- reactable::reactable(
    df,
    details = function(index) {
      all_passed <- dplyr::slice(df, index) |>
        dplyr::pull(all_passed)

      if (!all_passed) {
        step_index <- dplyr::slice(df, index) |>
          dplyr::pull(i) |>
          as.character()

        step_id <- dplyr::slice(df, index) |>
          dplyr::pull(step_id)

        assertion_type <- dplyr::slice(df, index) |>
          dplyr::pull(assertion_type)

        if (!is.null(extracts)) {
          extract_df <- extracts[[step_index]]
        } else {
          extract_df <- get_data_extracts(pointblank_object, step_index)
        }

        if (assertion_type == "rows_distinct") {
          reactable(
            dplyr::distinct(extract_df),
            filterable = TRUE
          )
        } else {
          record_detail_table(
            extract_df,
            preprocess = FALSE,
            nrow = 1000
            #clean_podcast_df(extract_df)
          )
        }
      }
    },
    columns = list(
      label = colDef(
        name = "Assessment",
        width = 350
      ),
      all_passed = colDef(
        name = "Passed",
        width = 150,
        align = "center",
        cell = icon_sets(
          df,
          icon_ref = "all_passed_icons",
          icon_color_ref = "all_passed_colors",
          icon_position = "over",
          icon_size = 28
        )
      ),
      all_passed_icons = colDef(show = FALSE),
      all_passed_colors = colDef(show = FALSE),
      n = colDef(
        name = "DB Records",
        width = 200,
        format = colFormat(
          separators = TRUE,
          digits = 0
        )
      ),
      n_passed = colDef(
        show = FALSE
      ),
      n_failed = colDef(
        name = "Failed Records",
        width = 200,
        format = colFormat(
          separators = TRUE,
          digits = 0
        ),
        show = TRUE
      ),
      f_failed = colDef(
        show = FALSE
      ),
      f_passed = colDef(
        name = "Records Pass",
        cell = data_bars(
          df,
          box_shadow = TRUE,
          fill_color_ref = "f_passed_colors",
          number_fmt = scales::percent_format(accuracy = 0.001)
        )
      ),
      f_passed_colors = colDef(show = FALSE),
      proc_duration_s = colDef(
        show = FALSE
      ),
      step_id = colDef(
        name = "Failed Extract Download Link",
        na = "Not Applicable",
        cell = function(value, index) {
          all_passed <- dplyr::slice(df, index) |>
            dplyr::pull(all_passed)

          if (!all_passed) {
            extract_file <- paste0(value, ".parquet")
            root_url <- "https://podcast20-projects.us-east-1.linodeobjects.com/exports/"
            full_url <- paste0(root_url, extract_file)
            download_url <- htmltools::tags$a(href = full_url, target = "_blank", extract_file)

            div(
              class = "podcast-urls",
              download_url
            )
          }
        }
      ),
      assertion_type = colDef(
        show = FALSE
      ),
      i = colDef(show = FALSE)
    ),
    pagination = FALSE
  ) |>
  add_source(
    "Display of failed assessment data truncated to 1,000 records, with full extracts available for download as parquet files."
  ) |>
  add_source(
    paste("Analysis performed on", report_date)
  )
  return(tbl)
}

record_analysis_table <- function(df, podcast_dup_df, report_date) {
  tbl <- reactable::reactable(
    df,
    wrap = FALSE,
    resizable = TRUE,
    #selection = "single",
    #onClick = "select",
    bordered = TRUE,
    columns = list(
      record_group = colDef(
        name = "Group ID",
        show = FALSE
      ),
      n_records = colDef(
        name = "Records"
      ),
      n_distinct_podcastGuid = colDef(
        name = "Podcast Guids"
      ),
      n_distinct_title = colDef(
        show = FALSE
      ),
      n_distinct_chash = colDef(
        name = "Content Hashes"
      ),
      n_distinct_description = colDef(
        show = FALSE
      ),
      n_distinct_episode_count = colDef(
        name = "Episodes"
      ),
      n_distinct_imageUrl = colDef(
        show = FALSE
      ),
      med_newestEnclosureDuration = colDef(
        name = "Enclosure Duration",
        format = colFormat(
          separators = TRUE,
          digits = 0
        )
      ),
      med_created_timespan_days = colDef(
        name = "Origin Timespan",
        format = colFormat(
          separators = TRUE,
          digits = 0
        )
      ),
      med_pub_timespan_days = colDef(
        name = "Publish Timespan",
        format = colFormat(
          separators = TRUE,
          digits = 0
        )
      )
    ),
    columnGroups = list(
      colGroup(
        name = "Distinct Counts per Record Group", 
        columns = c(
          "n_distinct_podcastGuid",
          "n_distinct_chash",
          "n_distinct_episode_count"
        )
      ),
      colGroup(
        name = "Group Statistics (Median)",
        columns = c(
          "med_newestEnclosureDuration",
          "med_created_timespan_days",
          "med_pub_timespan_days"
        )
      )
    ),
    filterable = FALSE,
    defaultSorted = list(n_records = "desc"),
    details = function(index) {
      record_group_selected = dplyr::slice(df, index) |>
        dplyr::pull(record_group)

      podcast_dup_df <- dplyr::filter(podcast_dup_df, record_group == !!record_group_selected) |>
      dplyr::select(-record_group)

      record_detail_table(podcast_dup_df)
    },
    elementId = 'analysis-table'
  ) |>
  add_source(
    "Origin Timespan = Days since podcast was originally published. Publish Timespan = Days between oldest and newest episodes."
  ) |>
  add_source(
    paste("Analysis performed on", report_date)
  )
  return(tbl)
}

record_detail_table <- function(df, preprocess = TRUE, nrow = NULL) {
  if (preprocess) {
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
  }

  if (!is.null(nrow)) {
    df <- dplyr::slice(df, 1:nrow)
  }
  
  reactable::reactable(
    df,
    defaultColDef = colDef(vAlign = "center", headerClass = "header"),
    columns = list(
      imageUrl = colDef(
        name = NULL,
        maxWidth = 70,
        align = "center",
        sticky = "left",
        cell = reactablefmtr::embed_img(height = 40, width = 40)
      ),
      podcastGuid = colDef(
        name = "Podcast GUID",
        sticky = "left"
      ),
      title = colDef(
        name = "Title",
        sticky = "left",
        show = TRUE
      ),
      id = colDef(
        show = FALSE
      ),
      url = colDef(
        name = "URLs",
        cell = function(value, index) {
          id <- dplyr::slice(df, index) |> dplyr::pull(id)
          podindex_url <- htmltools::tags$a(href = paste0("https://podcastindex.org/podcast/", id), target = "_blank", " podcastindex ")
          url <- htmltools::tags$a(href = value, target = "_blank", " rss-feed ")
          link <- htmltools::tags$a(href = dplyr::slice(df, index) |> dplyr::pull(link), target = "_blank", " link ")
          original_url <- htmltools::tags$a(href = dplyr::slice(df, index) |> dplyr::pull(originalUrl), target = "_blank", " original url ")

          div(
            class = "podcast-urls",
            podindex_url,
            url
          )
        }
      ),
      lastUpdate_p = colDef(
        name = "Last Update",
        format = colFormat(datetime = TRUE, hour12 = NULL)
      ),
      link = colDef(
        name = "Link",
        cell = function(value) {
          htmltools::tags$a(href = value, target = "_blank", "click here")
        },
        show = FALSE
      ),
      lastHttpStatus = colDef(
        name = "HTTP Status",
        style = function(value) {
          if (value == 200L) {
            color <- "#008000"
          } else {
            color <- "#e00000"
          }
        }
      ),
      dead = colDef(
        show = FALSE
      ),
      contentType = colDef(
        show = FALSE
      ),
      itunesId = colDef(
        show = FALSE
      ),
      itunesIdText = colDef(
        show = FALSE
      ),
      originalUrl = colDef(
        name = "Original URL",
        cell = function(value) {
          htmltools::tags$a(href = value, target = "_blank", "click here")
        },
        show = FALSE
      ),
      itunesAuthor = colDef(
        show = FALSE
      ),
      itunesOwnerName = colDef(
        show = FALSE
      ),
      explicit = colDef(
        show = FALSE
      ),
      itunesType = colDef(
        name = "itunesType",
        show = FALSE
      ),
      generator = colDef(
        name = "Generator",
        show = FALSE
      ),
      newestItemPubdate_p = colDef(
        name = "Newest Entry",
        format = colFormat(datetime = TRUE)
      ),
      language = colDef(
        name = "Language",
        show = FALSE
      ),
      oldestItemPubdate_p = colDef(
        name = "Oldest Entry",
        format = colFormat(datetime = TRUE)
      ),
      episodeCount = colDef(
        name = "Episodes",
        style = reactablefmtr::color_scales(df, color_ref = 'episodeCount_colors')
      ),
      popularityScore = colDef(
        name = "Popularity Score",
        show = FALSE
      ),
      priority = colDef(
        show = FALSE
      ),
      createdOn_p = colDef(
        name = "CreatedOn",
        format = colFormat(datetime = TRUE),
        show = FALSE
      ),
      updateFrequency = colDef(
        name = "Update Frequency",
        style = color_scales(df),
        show = FALSE
      ),
      chash = colDef(
        show = FALSE
      ),
      host = colDef(
        name = "Host",
        show = FALSE
      ),
      newestEnclosureUrl = colDef(
        name = "Newest Enclosure URL",
        cell = function(value) {
          htmltools::tags$a(href = value, target = "_blank", "click here")
        },
        show = FALSE
      ),
      description = colDef(
        show = FALSE
      ),
      category = colDef(
        name = "Categories",
        show = FALSE
      ),
      newestEnclosureDuration = colDef(
        name = "Newest Duration",
        cell = function(value) {
          if (is.na(value)) return("NA")

          td <- lubridate::seconds_to_period(value)
          sprintf(
            '%02d:%02d:%02d',
            td@hour,
            lubridate::minute(td),
            lubridate::second(td))
        }
        #format = colFormat(separators = TRUE)
      ),
      # record_group = colDef(
      #   show = FALSE
      # ),
      episodeCount_colors = colDef(
        show = FALSE
      ),
      created_timespan_days = colDef(
        show = FALSE
      ),
      pub_timespan_days = colDef(
        show = FALSE
      )
    ),
    theme = podcast_db_theme()
    #elementId = paste0('detail-table-', record_group)
  )
}