repo_url <- "https://cloud.r-project.org/"
packages_db <- as.data.frame(available.packages(paste0(repo_url, "src/contrib/")), stringsAsFactors = FALSE)
package_names <- packages_db$Package
description_urls <- paste0(repo_url, "web/packages/", package_names, "/DESCRIPTION")

# Create temporary directory for downloads
temp_dir <- tempfile()
dir.create(temp_dir)
description_files <- file.path(temp_dir, package_names)

# Download DESCRIPTION files in batches
curl::multi_set(total_con = 10)
batch_size <- 1000
num_batches <- ceiling(length(description_urls) / batch_size)

for (i in seq_len(num_batches)) {
  start_idx <- ((i - 1) * batch_size) + 1
  end_idx <- min(i * batch_size, length(description_urls))

  batch_urls <- description_urls[start_idx:end_idx]
  batch_files <- description_files[start_idx:end_idx]

  invisible(curl::multi_download(batch_urls, destfiles = batch_files, progress = FALSE))

  # Sleep between batches (except after the last batch)
  if (i < num_batches) {
    Sys.sleep(5)
  }
}

# Parse DESCRIPTION files
package_descriptions <- vector("list", length(package_names))
for (i in seq_along(description_files)) {
  con <- file(description_files[i], "r")
  package_descriptions[[i]] <- as.list(read.dcf(
    file = con,
    fields = c("Title", "SystemRequirements")
  ))
  close(con)
}

# Extract titles and system requirements
package_titles <- sapply(package_descriptions, "[[", 1)
system_requirements <- sapply(package_descriptions, "[[", 2)

# Filter packages with "Cargo" in system requirements
rust_packages_idx <- grepl(x = system_requirements, pattern = "Cargo", ignore.case = TRUE)

# Extract package details
rust_packages <- package_names[rust_packages_idx]
rust_packages_urls <- paste0("https://cran.r-project.org/package=", rust_packages)
rust_packages_titles <- package_titles[rust_packages_idx]

# Replace newlines in title with spaces
rust_packages_titles <- gsub("\n", " ", rust_packages_titles)

# Organize packages alphabetically for Markdown output
# Get the first letter of each package name
first_letters <- toupper(substr(rust_packages, 1, 1))

# Create a data frame to organize everything
pkg_data <- data.frame(
  name = rust_packages,
  link = rust_packages_urls,
  title = rust_packages_titles,
  first_letter = first_letters,
  stringsAsFactors = FALSE
)

# Sort the data frame by first letter
pkg_data <- pkg_data[order(pkg_data$first_letter, pkg_data$name), ]

# Get unique first letters
unique_letters <- unique(pkg_data$first_letter)

# Generate the markdown content
markdown_output <- ""
for (letter in unique_letters) {
  # Add section header for this letter
  markdown_output <- paste0(markdown_output, "## ", letter, "\n\n")

  # Get packages for this letter
  letter_pkgs <- pkg_data[pkg_data$first_letter == letter, ]

  # Add each package as a list item
  for (i in seq_len(nrow(letter_pkgs))) {
    pkg_line <- paste0(
      "- [", letter_pkgs$name[i], "](", letter_pkgs$link[i], ") - ",
      letter_pkgs$title[i], "\n"
    )
    markdown_output <- paste0(markdown_output, pkg_line)
  }

  # Add extra newline between sections
  markdown_output <- paste0(markdown_output, "\n")
}

# Output the Markdown content
cat(markdown_output)
