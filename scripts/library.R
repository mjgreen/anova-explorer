anova_library <- function(root) {
  file.path(root, ".library", paste0("R-", R.version$major, ".", strsplit(R.version$minor, ".", fixed = TRUE)[[1]][1]))
}

anova_use_library <- function(root) {
  library <- anova_library(root)
  if (!dir.exists(library)) stop("Run Rscript --vanilla scripts/install.R first.", call. = FALSE)
  .libPaths(c(library, .Library), include.site = FALSE)
  invisible(library)
}

anova_script_path <- function() {
  files <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
  if (length(files) != 1L) stop("Run this file with Rscript --vanilla.", call. = FALSE)
  normalizePath(sub("^--file=", "", files), mustWork = TRUE)
}
