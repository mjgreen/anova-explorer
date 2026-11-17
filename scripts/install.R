script <- normalizePath(sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1]), mustWork = TRUE)
root <- dirname(dirname(script))
source(file.path(root, "scripts", "library.R"))
args <- commandArgs(trailingOnly = TRUE)
if (any(!args %in% "--tests")) stop("Usage: Rscript --vanilla scripts/install.R [--tests]", call. = FALSE)
if (getRversion() != "4.5.1") warning("The lockfiles and accepted runtime use R 4.5.1; this R version is unverified.")
library <- anova_library(root)
dir.create(library, recursive = TRUE, showWarnings = FALSE)
anova_use_library(root)
Sys.setenv(RENV_PATHS_ROOT = file.path(root, ".renv"))
options(repos = c(CRAN = "https://cloud.r-project.org"), timeout = max(300, getOption("timeout")))
version <- "1.1.5"
if (!requireNamespace("renv", quietly = TRUE) || as.character(packageVersion("renv")) != version) {
  utils::install.packages(paste0("https://cran.r-project.org/src/contrib/Archive/renv/renv_", version, ".tar.gz"),
                          repos = NULL, type = "source", lib = library)
}
stopifnot(as.character(packageVersion("renv")) == version)
renv::restore(project = root, lockfile = file.path(root, "renv.lock"), library = library, prompt = FALSE)
if ("--tests" %in% args) {
  renv::restore(project = root, lockfile = file.path(root, "tests", "renv.lock"), library = library, prompt = FALSE)
}
cat("Installed locked dependencies in", library, "\nNext: Rscript --vanilla run.R\n")
