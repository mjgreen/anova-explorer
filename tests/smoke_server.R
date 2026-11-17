options(shiny.useragg = FALSE, shiny.usecairo = FALSE)
app_environment <- new.env(parent = globalenv())
source("app.R", local = app_environment)
shiny::testServer(app_environment$server, {
  session$setInputs(np = 20, mu1 = 24, mu2 = 25, mu3 = 26, sd1 = 5, sd2 = 5, sd3 = 5, resample = 0, reset = 0)
  original <- dd()
  session$setInputs(mu1 = 25)
  stopifnot(identical(dd()$relief[21:60], original$relief[21:60]))
  session$setInputs(mu1 = 24)
  stopifnot(identical(original, dd()))
  session$setInputs(resample = 1)
  stopifnot(!identical(original$relief, dd()$relief))
  session$setInputs(reset = 1)
  stopifnot(identical(original, dd()))
  session$setInputs(resample = 2)
  second_sample <- dd()
  session$setInputs(reset = 2)
  session$setInputs(resample = 3)
  stopifnot(!identical(second_sample, dd()), !identical(original, dd()))
  for (n in c(2, 1000)) {
    session$setInputs(np = n, mu1 = 25, mu2 = 25, mu3 = 25, sd1 = 1, sd2 = 50, sd3 = 5)
    stopifnot(nrow(dd()) == 3 * n, all(is.finite(dd()$relief)), is.finite(anova_table()$`F value`[1]))
    # Exercise every output at the slider boundaries, including the diagnostics.
    output$distPlot
    output$result_summary
    output$samplestatstable
    output$aov
    output$lev
    output$reportaov
  }
})
cat("Stable samples, nested participants, resampling and server reactivity passed\n")
