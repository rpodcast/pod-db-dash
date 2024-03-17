library(shiny)
library(bslib)
library(pointblank)
library(gt)
library(reactable)
#source("R/utils.R")

# obtain record objects from object storage
podcast_dupdf <- podcastdb_dupdf_object()
analysis_metrics_df <- podcastdb_analysisdf_object()

ui <- page_sidebar(
  title = "My Dashboard",
  sidebar = "Sidebar",
  # main content
  card(
    card_header("Duplicate Records Summary"),
    mod_tbl_ui("record_analysis")
  )
)

server <- function(input, output, session) {
  analysis_metrics_rv <- reactive(analysis_metrics_df)
  mod_tbl_server("record_analysis", analysis_metrics_rv)
}


# Create Shiny app ----
shinyApp(ui = ui, server = server)