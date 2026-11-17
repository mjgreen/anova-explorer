library(shiny)
library(ggplot2)
source("R/statistics.R")

group_names <- c("Placebo", "Low dose", "High dose")
group_colours <- c("#267394", "#AD6228", "#8061A2")
group_controls <- function(i, mean) {
  tags$section(class = paste("group-controls", paste0("group-", i)),
    tags$h3(tags$span(class = "group-dot", `aria-hidden` = "true"), group_names[i]),
    sliderInput(paste0("mu", i), "Population mean", 1, 50, mean, step = 0.1, ticks = FALSE),
    sliderInput(paste0("sd", i), "Population SD", 1, 50, anova_exercise$sds[i], step = 0.1, ticks = FALSE))
}
ui <- fluidPage(
  title = "ANOVA explorer | Matt Green",
  tags$head(tags$link(rel = "stylesheet", href = "explorer.css")),
  tags$div(class = "explorer-shell",
    tags$header(class = "page-header-custom",
      tags$a(class = "home-link", href = Sys.getenv("EXPLORER_HOME_URL", "https://mjgreen.uk/"), "← Matt Green"),
      tags$p(class = "eyebrow", "An interactive statistics demonstration"),
      tags$h1("ANOVA explorer"),
      tags$p(class = "intro", "Change sample size, group means and variability to see how the distributions and ANOVA result respond.")),
    tags$main(class = "explorer-grid",
      tags$aside(class = "controls panel", `aria-label` = "Simulation settings",
        tags$div(class = "panel-heading", tags$span(class = "section-number", "01"), tags$h2("Set the populations")),
        tags$div(class = "sample-control", sliderInput("np", "Participants per group", 2, 1000, anova_exercise$n, ticks = FALSE)),
        group_controls(1, anova_exercise$means[1]), group_controls(2, anova_exercise$means[2]), group_controls(3, anova_exercise$means[3]),
        tags$div(class = "sample-action",
          actionButton("reset", "Reset exercise", class = "btn-default btn-block"),
          tags$p("Reset restores the starting settings and the same teaching sample."),
          actionButton("resample", "New random sample", class = "resample-button"),
          tags$p("Sliders reuse the same random draws. Choose a new sample to explore sampling variation."))),
      tags$section(class = "results", `aria-label` = "Simulation results",
        tags$section(class = "panel sample-panel", tags$h2("Try it"),
          tags$p("Can you change this simulated example so that p falls below .05? Change one kind of setting at a time. Before moving a slider, predict what will happen; afterwards, explain what changed."),
          tags$p("The starting teaching sample is fixed and has a non-significant result. You are changing simulated populations to explore how ANOVA works."),
          tags$details(tags$summary("After your first solution"),
            tags$p("Can you find a different way? Reset the exercise before trying another route. What do your solutions tell you about what F compares?"))),
        tags$div(class = "panel plot-panel",
          tags$div(class = "panel-heading", tags$span(class = "section-number", "02"), tags$h2("See the sample")),
          tags$p(class = "plot-intro", "Three groups, one outcome. Each small dot is a participant’s relief score."),
          plotOutput("distPlot", height = "420px"),
          tags$div(class = "plot-key", tags$span("Shapes: sample distributions"),
                   tags$span("Large dots: sample means"), tags$span("Dashed line: overall sample mean")),
          tags$div(class = "result-strip", `aria-live` = "polite", uiOutput("result_summary"))),
        tags$section(class = "panel sample-panel", tags$h2("Population settings, sample results"),
          tags$p("The sliders set population means and standard deviations. The randomly sampled participants give the values below; they will usually differ from those settings."),
          tableOutput("samplestatstable")),
        tags$details(class = "panel detail-panel", tags$summary("Details and assumptions"),
          tags$div(class = "detail-content",
            tags$h3("Reading the result"),
            tags$p("The one-way ANOVA tests whether all three population means are equal. A small p-value indicates evidence against that hypothesis under the model’s assumptions; it is not the probability that the hypothesis is true."),
            tags$p("Changing a population mean shifts that group’s scores; changing its SD scales their spread. Increasing sample size adds participants without replacing the existing ones. A p-value need not fall at every increase in sample size."),
            textOutput("reportaov"), tags$h3("ANOVA table"), tableOutput("aov"),
            tags$h3("Equal variances"),
            tags$p("The conventional ANOVA assumes equal population variances. Levene’s test looks for evidence against equal variances; a non-significant result does not establish equality. Here, you can also compare the population SDs you set directly."),
            tableOutput("lev"))))),
    tags$footer("Made by Matt Green · R / Shiny · One-way ANOVA")))

server <- function(input, output, session) {
  # Each visitor starts with the same example; resampling remains unrestricted.
  draws <- reactiveVal(make_exercise_draws())
  observeEvent(input$reset, {
    updateSliderInput(session, "np", value = anova_exercise$n)
    for (i in seq_len(3L)) {
      updateSliderInput(session, paste0("mu", i), value = anova_exercise$means[i])
      updateSliderInput(session, paste0("sd", i), value = anova_exercise$sds[i])
    }
    draws(make_exercise_draws())
  }, ignoreInit = TRUE)
  observeEvent(input$resample, { draws(make_anova_draws()) }, ignoreInit = TRUE)
  dd <- reactive(build_anova_data(input$np, c(input$mu1, input$mu2, input$mu3),
                                  c(input$sd1, input$sd2, input$sd3), draws = draws()))
  aa <- reactive(fit_one_way_anova(dd()))
  anova_table <- reactive(summary(aa())[[1]])
  output$distPlot <- renderPlot({
    data <- dd()
    narrow <- isTRUE(session$clientData$output_distPlot_width < 500)
    means <- aggregate(relief ~ dose, data, mean)
    means$x <- seq_len(3L)
    ggplot(data, aes(x = as.numeric(dose), y = relief, group = dose)) +
      geom_violin(aes(fill = dose, colour = dose), alpha = 0.10, trim = FALSE, linewidth = 0.6, width = 0.8) +
      geom_hline(yintercept = mean(data$relief), colour = "#83938D", linetype = "dashed", linewidth = 0.5) +
      geom_point(aes(x = plot_x, colour = dose), alpha = if (input$np > 200) 0.13 else 0.42,
                 size = if (input$np > 200) 1.15 else 1.8) +
      geom_point(data = means, aes(x = x, y = relief, fill = dose),
                 shape = 21, colour = "#FFFFFF", stroke = 1, size = 4.5) +
      scale_colour_manual(values = group_colours) + scale_fill_manual(values = group_colours) +
      scale_x_continuous(breaks = seq_len(3L),
                         labels = if (narrow) c("Placebo", "Low\ndose", "High\ndose") else group_names,
                         limits = c(0.45, 3.55)) +
      labs(x = NULL, y = "Relief score") + theme_minimal(base_size = if (narrow) 11 else 13) +
      theme(legend.position = "none", panel.grid.minor = element_blank(), panel.grid.major.x = element_blank(),
            panel.grid.major.y = element_line(colour = "#E9EDE9", linewidth = 0.4),
            axis.text = element_text(colour = "#43574F"),
            axis.text.x = element_text(face = "bold", margin = margin(t = 10)),
            axis.title.y = element_text(margin = margin(r = 12)), plot.margin = margin(10, 14, 4, 5),
            plot.background = element_rect(fill = "white", colour = NA))
  }, res = 110, alt = "Simulated relief scores for three dose groups. Small dots show participants, large dots show sample means, and the dashed line shows the overall sample mean.")
  output$result_summary <- renderUI({
    tab <- anova_table()
    eta <- tab$`Sum Sq`[1] / sum(tab$`Sum Sq`)
    tags$div(class = "result-metrics",
      tags$div(tags$span(class = "metric-label", sprintf("F(%d, %d)", tab$Df[1], tab$Df[2])), tags$strong(sprintf("%.2f", tab$`F value`[1]))),
      tags$div(tags$span(class = "metric-label", "p-value"), tags$strong(format_anova_p(tab$`Pr(>F)`[1]))),
      tags$div(tags$span(class = "metric-label", "Effect size · η²"), tags$strong(sprintf("%.3f", eta))))
  })
  output$samplestatstable <- renderTable({
    data <- dd()
    data.frame(Group = group_names, n = as.integer(table(data$dose)),
               Mean = as.numeric(tapply(data$relief, data$dose, mean)), SD = as.numeric(tapply(data$relief, data$dose, sd)))
  }, digits = 2, striped = FALSE, bordered = FALSE, spacing = "s", width = "100%")
  output$reportaov <- renderText(gsub("The ANOVA suggests that:\n\n  - ", "",
                                     summary(report::report_text(aa())), fixed = TRUE))
  output$aov <- renderTable({
    tab <- anova_table()
    data.frame(Source = c("Between groups", "Within groups"), df = as.integer(tab$Df),
               `Sum of squares` = tab$`Sum Sq`, `Mean square` = tab$`Mean Sq`, F = tab$`F value`,
               p = c(format_anova_p(tab$`Pr(>F)`[1]), ""), check.names = FALSE)
  }, digits = 3, na = "", width = "100%")
  output$lev <- renderTable({
    tab <- car::leveneTest(relief ~ dose, center = median, data = dd())
    data.frame(Test = "Levene (median-centred)", df1 = tab$Df[1], df2 = tab$Df[2],
               F = tab$`F value`[1], p = format_anova_p(tab$`Pr(>F)`[1]))
  }, digits = 3, width = "100%")
}
shinyApp(ui, server)
