library(shiny)
library(pointblank)
library(gt)
source("R/utils.R")

# Define UI for app that draws a histogram ----
ui <- fluidPage(

  # App title ----
  titlePanel(hello_world()),

  # Sidebar layout with input and output definitions ----
  sidebarLayout(

    # Sidebar panel for inputs ----
    sidebarPanel(

      # Input: Slider for the number of bins ----
      sliderInput(inputId = "bins",
                  label = "Number of bins:",
                  min = 1,
                  max = 50,
                  value = 30)

    ),

    # Main panel for displaying outputs ----
    mainPanel(

      # Output: Histogram ----
      gt_output("gt_table"),
      #plotOutput(outputId = "distPlot"),
      verbatimTextOutput("df")

    )
  )
)

# Define server logic required to draw a histogram ----
server <- function(input, output) {

  dupdf <- podcastdb_dupdf_object()
  pb_object <- podcastdb_pointblank_object()
  # Histogram of the Old Faithful Geyser Data ----
  # with requested number of bins
  # This expression that generates a histogram is wrapped in a call
  # to renderPlot to indicate that:
  #
  # 1. It is "reactive" and therefore should be automatically
  #    re-executed when inputs (input$bins) change
  # 2. Its output type is a plot
  # output$distPlot <- renderPlot({

  #   x    <- faithful$waiting
  #   bins <- seq(min(x), max(x), length.out = input$bins + 1)

  #   hist(x, breaks = bins, col = "#75AADB", border = "white",
  #        xlab = "Waiting time to next eruption (in mins)",
  #        main = "Histogram of waiting times")

  #   })

  output$df <- renderPrint({
    str(dupdf)
  })

  output$gt_table <- render_gt({
    get_agent_report(pb_object, display_table = FALSE)
  })



}

# Create Shiny app ----
shinyApp(ui = ui, server = server)