# Run the main results and the supplementary sections included in this version.
# From the repository root:
#   Rscript code/run_all.R main  # Main results only
#   Rscript code/run_all.R       # Main results plus S1 and S2

library(here)

scripts <- c(
  "00_load_main_data.R",
  "02_table1.R",
  "03_figure1_balance.R",
  "04_figure2_sociograms.R",
  "05_figure3_cooperation.R",
  "06_numbers_in_text.R"
)

if (!"main" %in% commandArgs(trailingOnly = TRUE)) {
  scripts <- c(scripts, "si/S1_study_design.R", "si/S2_nomination_survey.R")
}

for (script in scripts) {
  message("Running ", script)
  source(here("code", script), local = new.env())
}

message("Done. Tables in output/tables, figures in output/figures.")
