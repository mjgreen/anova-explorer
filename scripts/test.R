script <- normalizePath(sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1]), mustWork = TRUE)
root <- dirname(dirname(script))
source(file.path(root, "scripts", "library.R"))
library <- anova_use_library(root)
if (!requireNamespace("testthat", quietly = TRUE)) stop("Run Rscript --vanilla scripts/install.R --tests first.")
setwd(root)
for (check in c("smoke_startup", "smoke_statistics", "smoke_stable_samples", "smoke_server")) {
  # A new R process keeps random state and loaded namespaces independent.
  expression <- sprintf(".libPaths(c(%s, .Library), include.site=FALSE); source(%s)",
                        encodeString(library, quote = '"'), encodeString(file.path("tests", paste0(check, ".R")), quote = '"'))
  status <- system2(file.path(R.home("bin"), "Rscript"), c("--vanilla", "-e", shQuote(expression)))
  if (status != 0L) stop(paste(check, "failed with exit", status))
}
cat("All ANOVA distribution checks passed\n")
