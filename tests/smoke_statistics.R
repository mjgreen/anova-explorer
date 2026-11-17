source("R/statistics.R")

set.seed(20260718)
data <- build_anova_data(
  n_per_group = 1000,
  means = c(20, 25, 40),
  standard_deviations = c(5, 5, 5)
)
model <- fit_one_way_anova(data)
anova_table <- summary(model)[[1]]
group_means <- tapply(data$relief, data$dose, mean)
levene_table <- car::leveneTest(relief ~ dose, center = median, data = data)
report_text <- summary(report::report_text(model))

stopifnot(
  nrow(data) == 3000L,
  identical(levels(data$dose), c("placebo", "low dose", "high dose")),
  max(abs(group_means - c(20, 25, 40))) < 0.5,
  identical(as.integer(anova_table$Df), c(2L, 2997L)),
  is.finite(anova_table$`F value`[1]),
  anova_table$`Pr(>F)`[1] < 0.001,
  is.finite(levene_table[1, "F value"]),
  grepl("ANOVA", report_text, fixed = TRUE)
)

cat("ShinyANOVA statistical smoke test passed\n")
