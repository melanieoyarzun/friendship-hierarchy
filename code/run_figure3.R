# Reproduce Figure 3 from the prepared dyad data.
# Run from the repository root: Rscript code/run_figure3.R

here::i_am("code/run_figure3.R")

source(here::here("code", "05_figure3_cooperation.R"), local = new.env())

message("Figure 3 complete: output/figures/figure3_assembled_20261121.pdf and .png")
