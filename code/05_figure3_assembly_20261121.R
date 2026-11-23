# =============================================================================
# Figure 3 assembly: reusable layout functions for the nine data panels.
# =============================================================================

## ---- figure3-assembly-style ----
library(patchwork)
source(here::here("code", "theme_hierarchy_20261121.R"))


## ---- figure3-assembly-functions ----
figure3_row_header <- function(roman, label, color) {
  ggplot() +
    annotate("rect", xmin = 0, xmax = 1, ymin = 0, ymax = 1,
             fill = color, color = NA) +
    annotate("text", x = 0.02, y = 0.5, label = roman, hjust = 0,
             color = "white", fontface = "bold", size = 5) +
    annotate("text", x = 0.52, y = 0.5, label = label,
             color = "white", fontface = "bold", size = 5) +
    scale_x_continuous(limits = c(0, 1), expand = c(0, 0)) +
    scale_y_continuous(limits = c(0, 1), expand = c(0, 0)) +
    theme_hierarchy(base_size = 16) +
    theme(axis.title = element_blank(), axis.text = element_blank(),
          axis.line = element_blank(), axis.line.x.bottom = element_blank(),
          axis.line.y.left = element_blank(), panel.border = element_blank(),
          plot.margin = margin(0, 0, 0, 0))
}

assemble_figure3 <- function(heatmap, tokens, cooperation_gap) {
  tag_panel <- function(plot, letter) {
    plot + labs(title = paste0(letter, ".")) +
      theme(plot.title = theme_hierarchy(base_size = 14)$plot.title)
  }

  row_non_friends <-
    tag_panel(heatmap("Non-friends"), "A") |
    tag_panel(tokens("Non-friends", pal_category[["Non Friends"]]), "B") |
    tag_panel(cooperation_gap("Non-friends", pal_category[["Non Friends"]]), "C")

  row_mutual <-
    tag_panel(heatmap("Mutual friends"), "A") |
    tag_panel(tokens("Mutual", pal_category[["Mutual"]]), "B") |
    tag_panel(cooperation_gap("Mutual", pal_category[["Mutual"]]), "C")

  row_one_sided <-
    tag_panel(heatmap("Asymmetric"), "A") |
    tag_panel(tokens("Sender declares", pal_category[["Ego declares"]]), "B") |
    tag_panel(cooperation_gap("Sender declares", pal_category[["Ego declares"]],
                             y_limits = c(-8.5, 6)), "C")

  figure3_row_header("I", "Non-friends", pal_category[["Non Friends"]]) /
    row_non_friends /
    figure3_row_header("II", "Mutual friends", pal_category[["Mutual"]]) /
    row_mutual /
    figure3_row_header("III", "Sender-declared one-sided friendships",
                       pal_category[["Ego declares"]]) /
    row_one_sided +
    plot_layout(heights = c(0.13, 1, 0.13, 1, 0.13, 1))
}
