#' tbl UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_tbl_ui <- function(id) {
  ns <- NS(id)
  tagList(
    reactable::reactableOutput(ns("record_table"))
  )
}

#' tbl Server Functions
#'
#' @noRd
#' 
mod_tbl_server <- function(id, record_df) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    output$record_table <- reactable::renderReactable({
      req(record_df())
      record_detail_table(record_df())
    })
  })
}

## To be copied in the UI
# mod_tbl_ui("tbl_1")
    
## To be copied in the server
# mod_tbl_server("tbl_1")