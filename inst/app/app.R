library(shiny)
library(bslib)
library(bushfireheat)

town_choices <- sort(unique(fire_daily$town))
baseline <- c(1950, 1979)
recent <- c(1996, 2025)

# Text helpers ----------------------------------------------------------------

list_towns <- function(towns) {
  if (length(towns) <= 1) {
    return(towns)
  }
  paste(paste(towns[-length(towns)], collapse = ", "), "and", towns[length(towns)])
}

signed_pct <- function(x) {
  sprintf("%+.0f%%", x)
}

# The headline answers the app's question for the current selection.
answer_headline <- function(cmp, threshold) {
  ok <- cmp[cmp$reliable, ]
  if (nrow(ok) == 0) {
    return(paste0(
      "At ", threshold, " °C, the selected towns had too few hot days in ",
      "1950–79 to compare. Lower the threshold."
    ))
  }
  where <- if (nrow(ok) == 1) {
    paste("In", ok$town)
  } else if (nrow(ok) == nrow(cmp)) {
    paste("Across the", nrow(ok), "selected towns")
  } else {
    paste("Across the", nrow(ok), "towns with enough data")
  }
  ratios <- round(range(ok$ratio), 1)
  times <- if (ratios[1] == ratios[2]) {
    sprintf("%.1f times", ratios[1])
  } else {
    sprintf("%.1f to %.1f times", ratios[1], ratios[2])
  }
  paste0(
    where, ", fire-season days at or above ", threshold, " °C are now ",
    times, " as common as in 1950–79."
  )
}

answer_detail <- function(cmp, threshold) {
  change <- 100 * (cmp$recent_rain / cmp$baseline_rain - 1)
  range_text <- if (length(change) == 1) {
    signed_pct(change)
  } else {
    paste("between", signed_pct(min(change)), "and", signed_pct(max(change)))
  }
  rain <- if (max(abs(change)) < 10) {
    paste0("Fire-season rainfall barely changed over the same period (", range_text, ").")
  } else {
    paste0("Fire-season rainfall changed by ", range_text, " over the same period.")
  }

  weak <- cmp$town[!cmp$reliable]
  if (length(weak) == 0 || length(weak) == nrow(cmp)) {
    return(rain)
  }
  paste0(
    rain, " ", list_towns(weak), if (length(weak) == 1) " is" else " are",
    " left out: fewer than 10 hot days in 1950–79 at ", threshold,
    " °C. Lower the threshold to include ", if (length(weak) == 1) "it." else "them."
  )
}

# facet_wrap() lays panels out in a near-square grid.
plot_height <- function(n_towns) {
  n <- max(1, n_towns)
  80 + 260 * ceiling(n / ceiling(sqrt(n)))
}

# Theme -----------------------------------------------------------------------

theme <- bs_theme(
  version = 5,
  bg = "#f4f6f5",
  fg = "#1e2a2e",
  primary = "#2f78b0",
  secondary = "#56656b",
  base_font = font_google("Barlow", wght = c(400, 600), local = FALSE),
  heading_font = font_google("Barlow Semi Condensed", wght = c(500, 600), local = FALSE),
  "card-bg" = "#ffffff",
  "card-cap-bg" = "#ffffff",
  "card-border-color" = "#d5dcdf",
  "border-radius" = "0.25rem"
) |>
  bs_add_rules("
    strong, b { font-weight: 600; }
    .navbar { border-bottom: 1px solid #d5dcdf; }
    .navbar-brand { font-family: $headings-font-family; font-weight: 600; }
    .bslib-card { box-shadow: none; }
    .bslib-card .table { --bs-table-bg: #ffffff; margin-bottom: 0; }
    .bslib-card .card-header {
      font-family: $headings-font-family;
      font-weight: 600;
      font-size: 1.15rem;
    }
    .question { color: $secondary; font-size: 1.05rem; max-width: 70ch; }
    .answer {
      font-size: unquote('clamp(1.5rem, 1.1rem + 1.6vw, 2.25rem)');
      font-weight: 600;
      line-height: 1.2;
      max-width: 34ch;
      margin-bottom: 0.75rem;
    }
    .answer-detail { font-size: 1.05rem; max-width: 70ch; margin-bottom: 1.5rem; }
    .card-footer { color: $secondary; background: #ffffff; max-width: 100%; }
    .card-footer p { max-width: 80ch; margin: 0; }
    .form-text { color: $secondary; margin-top: -0.5rem; margin-bottom: 1.25rem; }
    .data-note {
      color: $secondary;
      font-size: 0.875rem;
      border-top: 1px solid #d5dcdf;
      padding-top: 0.75rem;
    }
    .guide { max-width: 72ch; padding: 1.5rem 1.5rem 3rem; }
    .guide h2 { margin-bottom: 1rem; }
    .guide h3 { font-size: 1.35rem; margin-top: 2rem; }
  ")

# UI --------------------------------------------------------------------------

explore <- layout_sidebar(
  fillable = FALSE,
  border = FALSE,
  sidebar = sidebar(
    width = 300,
    selectizeInput(
      "towns", "Towns",
      choices = town_choices,
      selected = c("Bega", "Canberra", "Orbost", "Tumut"),
      multiple = TRUE,
      options = list(plugins = list("remove_button"))
    ),
    div(
      class = "form-text",
      "Pick the towns to compare. Highland towns (Armidale, Katoomba) rarely",
      "reach 35 °C, so compare them at a lower threshold."
    ),
    sliderInput(
      "threshold", "Hot-day threshold (°C)",
      min = 30, max = 42, value = 35, step = 1, ticks = FALSE
    ),
    div(
      class = "form-text",
      "A hot day is one whose maximum temperature reaches this value. Move it",
      "to see whether the change holds for milder and for more extreme heat."
    ),
    div(
      class = "data-note",
      "Daily ERA5 reanalysis via Open-Meteo, fire seasons 1950/51 to 2025/26.",
      "Definitions and limitations are under How to use."
    )
  ),
  p(
    class = "question",
    "For risk analysts pricing bushfire exposure in south-eastern Australia:",
    "how much more often does extreme heat occur in the fire season now than",
    "in 1950–79, and does the answer depend on where the threshold is set?"
  ),
  div(`aria-live` = "polite", uiOutput("answer")),
  conditionalPanel(
    "input.towns && input.towns.length > 0",
    card(
      card_header(textOutput("chart_title", inline = TRUE)),
      plotOutput("hot_days_plot", height = "auto"),
      card_footer(p(
        "Each bar is one fire season, September to February, labelled by the",
        "year it starts. The orange bar is 2019/20, the Black Summer. The black",
        "line averages the previous 10 seasons, so where it rises, hot days have",
        "become more common. All panels share one scale, so bar heights can be",
        "compared across towns."
      ))
    ),
    card(
      card_header("Average per fire season, 1950–79 against 1996–2025"),
      div(class = "table-responsive", tableOutput("comparison_table")),
      card_footer(p(
        "Ratio divides recent hot days by baseline hot days, so 2.0× means",
        "twice as many. A dash means the town had fewer than 10 hot days in",
        "1950–79 at this threshold, too few for a stable ratio. Rain is the",
        "average total for a season."
      ))
    )
  )
)

guide <- div(
  class = "guide",
  markdown("
## How to use this app

### Who it is for

Risk analysts who price bushfire exposure in south-eastern Australia. The app
answers one question: how much more often does extreme heat occur in the fire
season now than in 1950–79, and does the answer depend on where the threshold
for \"extreme\" is set?

### Terms

- **Fire season**: September to February, labelled by the year it starts.
  2019 is the 2019/20 season, the Black Summer.
- **Hot day**: a day whose maximum temperature reaches the threshold you set.
- **Baseline and recent periods**: the 30 seasons from 1950/51 to 1979/80, and
  the 30 seasons from 1996/97 to 2025/26.
- **Ratio**: average hot days per season in the recent period divided by the
  average in the baseline. 2.0× means twice as many.
- **Rain**: total rainfall in a season, averaged over each period.

### Using the controls

- **Towns**: type a name or pick from the list. Remove a town with its ×.
- **Hot-day threshold**: lower values count warm days that happen most
  summers; higher values count only the most extreme days.
- To check whether the answer depends on the threshold, move the slider and
  watch the headline. If the ratio stays above 1 at every threshold, heat has
  become more common however \"extreme\" is defined. Ratios tend to grow at
  higher thresholds, but they rest on fewer days.

### Reading the results

- **The headline** gives the range of ratios across the selected towns that
  have enough data, and the sentence below it compares rainfall.
- **The chart** shows hot days in every season. Look for whether the black
  line rises after the 1990s, and where the orange 2019/20 bar sits against
  earlier seasons.
- **The table** gives the numbers behind the headline for each town.
- **For pricing**: a ratio well above 1 with little change in rain means heat,
  rather than drier seasons, has driven the change. This matches attribution
  research on the 2019/20 fires (van Oldenborgh et al. 2021). Loadings built on
  1950–79 experience would understate how often these towns now see
  fire-season heat.

### When a town is left out

A town with fewer than 10 hot days in 1950–79 at the chosen threshold would
have a ratio resting on a handful of days, so the headline leaves it out and
the table shows a dash. Highland towns such as Armidale and Katoomba need a
threshold of about 32 °C.

### Data and limitations

- Daily maximum temperature and rainfall come from the ERA5 reanalysis,
  retrieved through [Open-Meteo](https://open-meteo.com/) under the CC BY 4.0
  licence. Generated using Copernicus Climate Change Service information.
- ERA5 averages over grid cells about 25 km across and is adjusted to each
  town's elevation. It is not a weather-station record and smooths out local
  extremes.
- The app measures heat and rain only. Fire risk also depends on wind,
  humidity, fuel, ignition and exposure, which are not included.
")
)

ui <- page_navbar(
  title = "Fire-season heat",
  window_title = "Fire-season heat in south-eastern Australia",
  theme = theme,
  fillable = FALSE,
  nav_panel("Explore", explore),
  nav_panel("How to use", guide)
)

# Server ----------------------------------------------------------------------

server <- function(input, output, session) {
  seasons <- reactive({
    validate(need(
      length(input$towns) > 0,
      "Select at least one town to see results."
    ))
    summarise_seasons(fire_daily, threshold = input$threshold, towns = input$towns)
  })

  comparison <- reactive(compare_periods(seasons(), baseline, recent))

  output$answer <- renderUI({
    if (length(input$towns) == 0) {
      return(h2(
        class = "answer",
        "Choose at least one town in the sidebar to see how fire-season heat has changed."
      ))
    }
    tagList(
      h2(class = "answer", answer_headline(comparison(), input$threshold)),
      p(class = "answer-detail", answer_detail(comparison(), input$threshold))
    )
  })

  output$chart_title <- renderText(
    paste0("Days at or above ", input$threshold, " °C in each fire season")
  )

  output$hot_days_plot <- renderPlot(
    plot_hot_days(seasons()) + ggplot2::labs(caption = NULL),
    height = function() plot_height(length(input$towns)),
    res = 96,
    alt = reactive(paste0(
      "Bar charts of days at or above ", input$threshold, " °C in each fire ",
      "season since 1950 for ", list_towns(input$towns), "."
    ))
  )

  output$comparison_table <- renderTable(
    {
      cmp <- comparison()
      data.frame(
        Town = cmp$town,
        `Hot days, 1950–79` = sprintf("%.1f", cmp$baseline_hot_days),
        `Hot days, 1996–2025` = sprintf("%.1f", cmp$recent_hot_days),
        Ratio = ifelse(cmp$reliable, sprintf("%.1f×", cmp$ratio), "–"),
        `Rain, 1950–79 (mm)` = sprintf("%.0f", cmp$baseline_rain),
        `Rain change` = signed_pct(100 * (cmp$recent_rain / cmp$baseline_rain - 1)),
        check.names = FALSE
      )
    },
    align = "lrrrrr",
    width = "100%",
    hover = TRUE
  )
}

shinyApp(ui, server)
