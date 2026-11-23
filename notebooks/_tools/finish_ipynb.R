# =============================================================================
# finish_ipynb.R
#
# Runs after `quarto render notebooks --profile ipynb --to ipynb`. Quarto writes the
# notebooks with a Python kernel by default; here we mark them as R
# notebooks (IRkernel), so GitHub shows R syntax and Jupyter opens them with
# R. The generated files are placed alongside their Quarto sources.
# =============================================================================

library(jsonlite)
library(here)

here::i_am("notebooks/_tools/finish_ipynb.R")
from <- here("notebooks", "_notebook-build")
notebooks <- list.files(from, pattern = "\\.ipynb$", recursive = TRUE)
if (length(notebooks) == 0L) stop("No rendered notebooks found in ", from)

written <- 0L
for (file in notebooks) {
  nb <- read_json(file.path(from, file), simplifyVector = FALSE)
  code_cells <- which(vapply(nb$cells, function(cell) cell$cell_type == "code", logical(1)))
  if (length(code_cells) == 0L) next
  nb$metadata$kernelspec    <- list(display_name = "R", language = "R", name = "ir")
  nb$metadata$language_info <- list(name = "R", file_extension = ".r",
                                    mimetype = "text/x-r-source")
  first_code <- code_cells[1]
  source_path <- paste0("notebooks/", sub("\\.ipynb$", ".qmd", file))
  root_setup <- paste0("here::i_am(", encodeString(source_path, quote = '"'), ")\n")
  nb$cells[[first_code]]$source <- c(list(root_setup), nb$cells[[first_code]]$source)

  # Link result pages to their notebooks and section indexes to the README.
  for (i in seq_along(nb$cells)) {
    if (nb$cells[[i]]$cell_type == "markdown") {
      source <- unlist(nb$cells[[i]]$source)
      source <- gsub("figure3_index.qmd#figure-3-summary-tables", "../../data/figure3_codebook.md#figure-3-summary-tables", source, fixed = TRUE)
      source <- gsub("figure3_index.qmd", "../README.md#figure-3", source, fixed = TRUE)
      source <- gsub("../si/index.qmd", "../README.md#supporting-information", source, fixed = TRUE)
      source <- gsub("../main/index.qmd", "../README.md#main-text", source, fixed = TRUE)
      section <- if (startsWith(file, "main/")) "main-text" else "supporting-information"
      source <- gsub("](index.qmd)", paste0("](../README.md#", section, ")"), source, fixed = TRUE)
      nb$cells[[i]]$source <- as.list(gsub("\\.qmd(?=[#)])", ".ipynb", source, perl = TRUE))
    }
  }
  destination <- here("notebooks", file)
  write_json(nb, destination, auto_unbox = TRUE, pretty = 1, null = "null")
  written <- written + 1L
}

unlink(from, recursive = TRUE)
cat("Notebooks written to notebooks/:", written, "\n")
