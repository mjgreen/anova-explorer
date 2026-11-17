app_environment <- new.env(parent = globalenv())
source("app.R", local = app_environment)

stopifnot(
  is.function(app_environment$server),
  inherits(app_environment$ui, c("shiny.tag", "shiny.tag.list")),
  inherits(
    shiny::shinyApp(app_environment$ui, app_environment$server),
    "shiny.appobj"
  )
)

cat("ShinyANOVA startup smoke test passed\n")
