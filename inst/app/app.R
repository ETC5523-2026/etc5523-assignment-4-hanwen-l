library(shiny)
library(bslib)
library(bushfireheat)

town_choices <- sort(unique(fire_daily$town))

ui <- page_sidebar(
  title = "Fire-season heat in south-eastern Australia",
  theme = bs_theme(version = 5),
  sidebar = sidebar(
    selectizeInput(
      "towns", "Towns",
      choices = town_choices,
      selected = intersect(c("Canberra", "Bega"), town_choices),
      multiple = TRUE
    ),
    sliderInput(
      "threshold", "Hot-day threshold (°C)",
      min = 30, max = 42, value = 35, step = 1
    )
  ),
  p(
    strong("For risk analysts pricing bushfire exposure:"),
    "how much more often does fire-season heat occur now than in 1950–79,",
    "and does the answer depend on where the threshold is set?"
  ),
  card(
    card_header(textOutput("plot_title", inline = TRUE)),
    plotOutput("hot_days_plot", height = "450px")
  ),
  card(
    card_header("Average per fire season: 1950–79 baseline against 1996–2025"),
    textOutput("reliability_note"),
    tableOutput("comparison_table")
  )
)

server <- function(input, output, session) {
  seasons <- reactive({
    validate(need(
      length(input$towns) > 0,
      "Select at least one town to see results."
    ))
    summarise_seasons(fire_daily, threshold = input$threshold, towns = input$towns)
  })

  comparison <- reactive(compare_periods(seasons()))

  output$plot_title <- renderText(
    paste0("Days at or above ", input$threshold, " °C in each fire season (Sep–Feb)")
  )

  output$hot_days_plot <- renderPlot(plot_hot_days(seasons()))

  output$reliability_note <- renderText({
    weak <- comparison()$town[!comparison()$reliable]
    if (length(weak) == 0) {
      return(NULL)
    }
    paste0(
      "Fewer than 10 hot days in the 1950–79 baseline for ",
      paste(weak, collapse = ", "),
      ", so the ratio is not shown. Lower the threshold to compare these towns."
    )
  })

  output$comparison_table <- renderTable(
    {
      cmp <- comparison()
      data.frame(
        Town = cmp$town,
        `Hot days, 1950–79` = cmp$baseline_hot_days,
        `Hot days, 1996–2025` = cmp$recent_hot_days,
        Ratio = ifelse(cmp$reliable, sprintf("%.1f×", cmp$ratio), "–"),
        `Rain (mm), 1950–79` = cmp$baseline_rain,
        `Rain (mm), 1996–2025` = cmp$recent_rain,
        check.names = FALSE
      )
    },
    digits = 1
  )
}

shinyApp(ui, server)
