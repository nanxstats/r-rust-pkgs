# Build a synthetic monorepo of the Rust-powered R packages listed in README.md.
# The latest CRAN source tarballs are extracted into vendor/ for use as
# AI coding agent references.
#
# Run from the repository root with:
# Rscript scripts/monorepo.R

package_pattern <- paste0("^- \\[([^]]+)\\]", "\\(https://cran\\.r-project\\.org/package=[^)]+\\).*$")

package_lines <- grep(package_pattern, readLines("README.md"), value = TRUE)
packages <- sub(package_pattern, "\\1", package_lines)

cran <- "https://cloud.r-project.org"
available <- available.packages(repos = cran, type = "source")
versions <- available[packages, "Version"]

dir.create("vendor", showWarnings = FALSE)

message(sprintf("%d packages to download and extract.", length(packages)))

for (i in seq_along(packages)) {
  package <- packages[[i]]
  version <- versions[[package]]
  archive_url <- sprintf("%s/src/contrib/%s_%s.tar.gz", cran, package, version)
  archive <- tempfile(fileext = ".tar.gz")

  message(sprintf("[%d/%d] Downloading %s %s", i, length(packages), package, version))
  curl::curl_download(archive_url, archive)
  message(sprintf("[%d/%d] Extracting %s", i, length(packages), package))
  untar(archive, exdir = "vendor")
  unlink(archive)
}
