anova_exercise <- list(n = 20L, means = c(24, 25, 26), sds = c(5, 5, 5))

make_exercise_draws <- function() {
  # Reproduce the teaching example without restarting the random-sample stream.
  had_seed <- exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  if (had_seed) old_seed <- get(".Random.seed", envir = .GlobalEnv)
  on.exit({
    if (had_seed) assign(".Random.seed", old_seed, envir = .GlobalEnv)
    else rm(".Random.seed", envir = .GlobalEnv)
  })
  set.seed(42)
  make_anova_draws()
}

make_anova_draws <- function(max_n = 1000L) {
  stopifnot(length(max_n) == 1L, is.finite(max_n), max_n >= 2, max_n == as.integer(max_n))
  list(z = matrix(stats::rnorm(max_n * 3L), nrow = max_n, ncol = 3L),
       jitter = matrix(stats::runif(max_n * 3L, -0.13, 0.13), nrow = max_n, ncol = 3L))
}

build_anova_data <- function(n_per_group, means, standard_deviations, draws = NULL) {
  stopifnot(
    length(n_per_group) == 1L,
    is.finite(n_per_group),
    n_per_group >= 2,
    n_per_group == as.integer(n_per_group),
    length(means) == 3L,
    length(standard_deviations) == 3L,
    all(is.finite(means)),
    all(is.finite(standard_deviations)),
    all(standard_deviations > 0)
  )

  n_per_group <- as.integer(n_per_group)
  if (is.null(draws)) draws <- make_anova_draws(n_per_group)
  stopifnot(is.matrix(draws$z), ncol(draws$z) == 3L, nrow(draws$z) >= n_per_group,
            identical(dim(draws$z), dim(draws$jitter)),
            all(is.finite(draws$z)), all(is.finite(draws$jitter)))
  selected <- seq_len(n_per_group)
  tibble::tibble(
    relief = as.vector(sweep(sweep(draws$z[selected, , drop = FALSE], 2L,
                                  standard_deviations, `*`), 2L, means, `+`)),
    pid = factor(sprintf("%s-%04d", rep(seq_len(3L), each = n_per_group), rep(selected, 3L))),
    plot_x = rep(seq_len(3L), each = n_per_group) + as.vector(draws$jitter[selected, , drop = FALSE]),
    dose = gl(
      3L,
      n_per_group,
      labels = c("placebo", "low dose", "high dose")
    )
  )
}

format_anova_p <- function(p) {
  if (!is.finite(p)) return("Unavailable")
  if (p < 0.001) return("< .001")
  sub("^0", "", sprintf("%.3f", p))
}

fit_one_way_anova <- function(data) {
  stopifnot(
    is.data.frame(data),
    all(c("relief", "dose") %in% names(data)),
    nlevels(data$dose) == 3L
  )
  stats::aov(relief ~ dose, data = data)
}
