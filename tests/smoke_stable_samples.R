source("R/statistics.R")
exercise_draws <- make_exercise_draws()
stopifnot(!exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE))
set.seed(42)
seed_before <- .Random.seed
stopifnot(identical(exercise_draws, make_exercise_draws()), identical(seed_before, .Random.seed))
exercise_p <- function(n = anova_exercise$n, means = anova_exercise$means, sds = anova_exercise$sds) {
  summary(fit_one_way_anova(build_anova_data(n, means, sds, exercise_draws)))[[1]]$`Pr(>F)`[1]
}
stopifnot(abs(exercise_p() - 0.7694413642) < 1e-8,
          exercise_p(means = c(20, 25, 30)) < .001,
          exercise_p(sds = c(1, 1, 1)) < .001,
          exercise_p(n = 200) < .001)
draws <- make_anova_draws()
base <- build_anova_data(20, c(20, 25, 40), c(5, 5, 5), draws)
shifted <- build_anova_data(20, c(23, 25, 40), c(5, 5, 5), draws)
stopifnot(isTRUE(all.equal(shifted$relief[1:20], base$relief[1:20] + 3)),
          identical(shifted$relief[21:60], base$relief[21:60]),
          identical(base$plot_x, shifted$plot_x))
scaled <- build_anova_data(20, c(20, 25, 40), c(10, 5, 5), draws)
stopifnot(isTRUE(all.equal(scaled$relief[1:20] - 20, 2 * (base$relief[1:20] - 20))))
larger <- build_anova_data(100, c(20, 25, 40), c(5, 5, 5), draws)
retained <- larger[match(as.character(base$pid), as.character(larger$pid)), ]
stopifnot(identical(base$relief, retained$relief), identical(base$plot_x, retained$plot_x),
          identical(base, build_anova_data(20, c(20, 25, 40), c(5, 5, 5), draws)),
          !identical(base$relief, build_anova_data(20, c(20, 25, 40), c(5, 5, 5), make_anova_draws())$relief),
          identical(format_anova_p(.00001), "< .001"), identical(format_anova_p(.34567), ".346"))
cat("Stable draw transformations, nested participants and resampling passed\n")
