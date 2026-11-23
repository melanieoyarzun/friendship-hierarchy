# =============================================================================
# 05_figure3_cooperation.R
#
# Figure 3: cooperation across friendship contexts and social rank.
# Three rows (I non-friends, II mutual friends, III sender-declared one-sided
# friendships) and three panels per row:
#   A. heatmap of the tokens exchanged within each pair
#   B. mean tokens sent and received along the Social Rank GAP
#   C. Cooperation GAP along the Social Rank GAP (observed and null-model filtered)
#
# Save the nine individual panels and the complete assembly as PDF and PNG.
#
#   Input : data/generated/main/analysis_dyads.csv
#   Output: output/figures/figure3_{I,II,III}_{A,B,C}.(pdf|png)
#           output/figures/figure3_assembled_20261121.(pdf|png)
#           output/tables/figure3_heatmap_cells.csv
#           output/tables/figure3_children_summary.csv  (step 1 of panels B and C)
#           output/tables/figure3_binned_means.csv      (table of means by bin)
# =============================================================================

## ---- fig3-packages ----
library(tidyverse)
library(here)
source(here("code", "00_style.R"))

## ---- fig3-load ----
source(here("code", "00_load_main_data.R"), local = TRUE)
dyads <- analysis_dyads


## ---- heatmap-data ----
# Panel A. Every pair exchanges two numbers: what i sends to j and what j
# sends to i. The order does not matter for the heatmap (5 and 2 is the same
# pair as 2 and 5), so we keep the larger number on the x axis and the
# smaller on the y axis. That is why the heatmap is a triangle.
#
# One-sided friendships appear twice in the data (as "Sender declares" from
# one side and "Receiver declares" from the other), so for the heatmap we put
# both together in one "Asymmetric" group. Percentages are computed within
# each group.

heatmap_cells <- dyads %>%
  mutate(group = case_when(friendship == "Non-friends" ~ "Non-friends",
                           friendship == "Mutual"      ~ "Mutual friends",
                           TRUE                        ~ "Asymmetric"),
         high = pmax(tokens_sent, tokens_received),
         low  = pmin(tokens_sent, tokens_received)) %>%
  count(group, high, low) %>%
  group_by(group) %>%
  mutate(percent = 100 * n / sum(n)) %>%
  ungroup() %>%
  # add the combinations that never happened, with 0%
  complete(group, high = 0:10, low = 0:10, fill = list(n = 0, percent = 0)) %>%
  filter(low <= high)

# Three regions highlighted in the paper
heatmap_regions <- heatmap_cells %>%
  group_by(group) %>%
  summarise(
    low_cooperation  = sum(percent[high <= 1]),                 # both sent 0 or 1 (magenta)
    asymmetric       = sum(percent[high == 10 & low <= 5]),     # one sent 10, the other 5 or less (blue)
    full_cooperation = sum(percent[high == 10 & low == 10])     # both sent 10 (black)
  )

heatmap_regions


## ---- heatmap-percentages ----
heatmap_cells %>%
  group_by(group) %>%
  slice_max(percent, n = 5, with_ties = FALSE) %>%
  ungroup()


## ---- heatmap-example ----
# Draw the non-friend heatmap directly from the exchange-cell table.
non_friend_cells <- heatmap_cells %>% filter(group == "Non-friends")
non_friend_regions <- heatmap_regions %>% filter(group == "Non-friends")

heatmap_non_friends <- ggplot(non_friend_cells, aes(x = high, y = low, fill = percent)) +
  geom_tile(color = "white") +
  geom_text(aes(label = round(percent, 1)), size = 2) +
  # magenta: low or no cooperation
  annotate("rect", xmin = -0.5, xmax = 1.5, ymin = -0.5, ymax = 1.5,
           color = "#F000D0", fill = NA, linewidth = 0.8) +
  annotate("label", x = 0.5, y = 2, label = round(non_friend_regions$low_cooperation, 1),
           color = "#F000D0", size = 2.3, fontface = "bold") +
  # blue: highly asymmetric
  annotate("rect", xmin = 9.5, xmax = 10.5, ymin = -0.5, ymax = 5.5,
           color = "#173BFF", fill = NA, linewidth = 0.8) +
  annotate("label", x = 11, y = 5.5, label = round(non_friend_regions$asymmetric, 1),
           color = "#173BFF", size = 2.3, fontface = "bold") +
  # black: full mutual cooperation
  annotate("rect", xmin = 9.5, xmax = 10.5, ymin = 9.5, ymax = 10.5,
           color = "black", fill = NA, linewidth = 0.9) +
  scale_fill_gradientn(colours = c("#FFF4D6", "#F7E08A", "#E7B56A", "#D9874C", "#C95A3A", "#A51C1C"),
                       values = scales::rescale(c(0, 2, 5, 10, 15, 20)),
                       limits = c(0, 20), oob = scales::squish, name = "%") +
  scale_x_continuous(breaks = 0:10, expand = c(0, 0)) +
  scale_y_continuous(breaks = 0:10, expand = c(0, 0)) +
  coord_fixed(clip = "off") +
  labs(x = "Tokens i to j", y = "Tokens j to i", title = "Non-friends") +
  theme_paper(base_size = 9) +
  theme(panel.border = element_blank(), legend.position = "right")


## ---- heatmap-function ----
plot_heatmap <- function(this_group) {
  cells   <- heatmap_cells   %>% filter(group == this_group)
  regions <- heatmap_regions %>% filter(group == this_group)

  ggplot(cells, aes(x = high, y = low, fill = percent)) +
    geom_tile(color = "white") +
    geom_text(aes(label = round(percent, 1)), size = 2) +
    # magenta: low or no cooperation
    annotate("rect", xmin = -0.5, xmax = 1.5, ymin = -0.5, ymax = 1.5,
             color = "#F000D0", fill = NA, linewidth = 0.8) +
    annotate("label", x = 0.5, y = 2, label = round(regions$low_cooperation, 1),
             color = "#F000D0", size = 2.3, fontface = "bold") +
    # blue: highly asymmetric
    annotate("rect", xmin = 9.5, xmax = 10.5, ymin = -0.5, ymax = 5.5,
             color = "#173BFF", fill = NA, linewidth = 0.8) +
    annotate("label", x = 11, y = 5.5, label = round(regions$asymmetric, 1),
             color = "#173BFF", size = 2.3, fontface = "bold") +
    # black: full mutual cooperation
    annotate("rect", xmin = 9.5, xmax = 10.5, ymin = 9.5, ymax = 10.5,
             color = "black", fill = NA, linewidth = 0.9) +
    scale_fill_gradientn(colours = c("#FFF4D6", "#F7E08A", "#E7B56A", "#D9874C", "#C95A3A", "#A51C1C"),
                         values = scales::rescale(c(0, 2, 5, 10, 15, 20)),
                         limits = c(0, 20), oob = scales::squish, name = "%") +
    scale_x_continuous(breaks = 0:10, expand = c(0, 0)) +
    scale_y_continuous(breaks = 0:10, expand = c(0, 0)) +
    coord_fixed(clip = "off") +
    labs(x = "Tokens i to j", y = "Tokens j to i", title = this_group) +
    theme_paper(base_size = 9) +
    theme(panel.border = element_blank(), legend.position = "right")
}


## ---- heatmap-plot ----
plot_heatmap("Non-friends")


## ---- heatmap-mutual ----
heatmap_mutual <- plot_heatmap("Mutual friends")


## ---- heatmap-asymmetric ----
heatmap_asymmetric <- plot_heatmap("Asymmetric")


## ---- binned-data ----
# Panels B and C summarize transfers in two aggregation stages:
#
#   1. Summary by child. For each child (sender) and friendship group: her
#      mean tokens sent, her mean tokens received, her Cooperation GAP as the
#      difference between those two means (received - sent), and the median
#      Social Rank GAP of those partners. With observed transfers, panel C
#      equals the distance between the two mean curves of panel B.
#   2. Bins. The median rank gaps of the group are split into 7 intervals of
#      equal width ("round_gap"). The bins use all the children of the group,
#      so the observed and the filtered versions share the same bins.
#   3. Table of means by bin. Across the children of each bin: the mean and
#      SD of each measure, the position of the bin (mean of the children's
#      median gaps) and a 95% interval, mean +/- 1.96 * SD / sqrt(n), with n
#      the number of children in the bin.
#   4. The panels draw that table.
#
# Filtered version: a transfer dropped by the null-model filter is NA.
# Each direction keeps all of its retained transfers:
# the child's mean filtered tokens received minus her mean filtered tokens
# sent. (The filtered regressions, instead, use only pairs with both
# directions retained.) Children with nothing retained in one of the two
# directions have no filtered GAP; they stay in the total bin count n, and
# `n_with_value` counts finite child GAPs. The filtered sent, received, and GAP
# means can use different valid-child sets, so their bin-level difference
# need not equal the filtered GAP curve.

summary_by_child <- function(data, sent, received) {
  data %>%
    group_by(sender_id) %>%
    summarise(gap      = median(rank_gap),
              sent     = mean({{ sent }}, na.rm = TRUE),
              received = mean({{ received }}, na.rm = TRUE),
              .groups  = "drop") %>%
    mutate(dif_coop = received - sent)
}

summary_by_bin <- function(children, coef = 1.96, n_bins = 7) {
  children %>%
    mutate(round_gap = cut_interval(gap, n_bins, dig.lab = 1)) %>%
    group_by(round_gap) %>%
    summarise(median_gap    = mean(gap),     # position of the bin on the x axis
              n             = n(),
              n_with_value  = sum(is.finite(dif_coop)),
              mean_sent     = mean(sent, na.rm = TRUE),
              sd_sent       = sd(sent, na.rm = TRUE),
              mean_reci     = mean(received, na.rm = TRUE),
              sd_reci       = sd(received, na.rm = TRUE),
              mean_dif_coop = mean(dif_coop, na.rm = TRUE),
              sd_dif_coop   = sd(dif_coop, na.rm = TRUE),
              .groups = "drop") %>%
    mutate(se_sent     = coef * sd_sent / sqrt(n),
           se_reci     = coef * sd_reci / sqrt(n),
           se_dif_coop = coef * sd_dif_coop / sqrt(n))
}

rank_groups <- c("Non-friends", "Mutual", "Sender declares")


## ---- child-summary ----
# Step 1, for every friendship group, with observed and with filtered tokens
children <- map_dfr(rank_groups, function(this_group) {
  group_data <- dyads %>% filter(friendship == this_group)
  bind_rows(
    summary_by_child(group_data, tokens_sent, tokens_received) %>% mutate(version = "Observed"),
    summary_by_child(group_data, tokens_sent_filtered, tokens_received_filtered) %>% mutate(version = "Filtered")
  ) %>%
    mutate(group = this_group)
})

# a few children of the non-friends group, filtered tokens
children %>% filter(group == "Non-friends", version == "Filtered") %>% head()


## ---- bin-table ----
# Steps 2 and 3: the table of means by bin that the panels draw
binned <- children %>%
  group_by(group, version) %>%
  group_modify(~ summary_by_bin(.x)) %>%
  ungroup()

# Panel C, non-friends: Cooperation GAP by bin, observed and filtered
binned %>%
  filter(group == "Non-friends") %>%
  select(version, round_gap, median_gap, n, n_with_value, mean_dif_coop, se_dif_coop) %>%
  mutate(across(where(is.double), ~ round(.x, 2)))


## ---- observed-bins ----
binned %>%
  filter(version == "Observed") %>%
  select(group, round_gap, median_gap, n, mean_sent, mean_reci,
         se_sent, se_reci)


## ---- filtered-support ----
children %>%
  filter(version == "Filtered") %>%
  group_by(group) %>%
  summarise(n_children = n(),
            n_valid_sent = sum(is.finite(sent)),
            n_valid_received = sum(is.finite(received)),
            n_valid_coop_gap = sum(is.finite(dif_coop)),
            .groups = "drop")


## ---- gap-support-by-bin ----
binned %>%
  select(group, version, round_gap, median_gap, n, n_with_value,
         mean_dif_coop, se_dif_coop)


## ---- panel-b-example ----
# Draw the observed non-friend panel directly from its seven plotting rows.
mean_tokens <- mean(dyads$tokens_sent)
non_friend_bins <- binned %>%
  filter(group == "Non-friends", version == "Observed")

tokens_non_friends <- ggplot(non_friend_bins, aes(x = median_gap)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey40") +
  geom_hline(yintercept = mean_tokens, linetype = "dashed", color = "grey50") +
  geom_ribbon(aes(ymin = mean_reci, ymax = mean_sent), fill = "#F0E5A8", alpha = 0.7) +
  geom_line(aes(y = mean_sent), color = color_non_friends, linewidth = 0.9) +
  geom_errorbar(aes(ymin = mean_sent - se_sent, ymax = mean_sent + se_sent),
                color = color_non_friends, width = 0.04) +
  geom_point(aes(y = mean_sent), color = color_non_friends, shape = 18, size = 3) +
  geom_line(aes(y = mean_reci), color = color_non_friends, linewidth = 0.9) +
  geom_errorbar(aes(ymin = mean_reci - se_reci, ymax = mean_reci + se_reci),
                color = color_non_friends, width = 0.04) +
  geom_point(aes(y = mean_reci), color = color_non_friends, shape = 15, size = 2.5) +
  annotate("text", x = c(-0.55, 0.55), y = 0.4, size = 2.3, fontface = "bold",
           label = c("Receiver higher rank", "Sender higher rank")) +
  scale_x_continuous(limits = c(-1.1, 1.1), breaks = seq(-1, 1, 0.5)) +
  scale_y_continuous(limits = c(0, 11), breaks = c(0, 5, 10)) +
  labs(x = "Social Rank GAP", y = "Tokens") +
  theme_paper(base_size = 9)


## ---- panel-b-function ----
mean_tokens <- mean(dyads$tokens_sent)

# Reuse this plotting specification for any relationship group.
plot_tokens <- function(this_group, color, version = "Observed") {
  bins <- binned %>% filter(group == this_group, version == !!version)

  ggplot(bins, aes(x = median_gap)) +
    geom_vline(xintercept = 0, linetype = "dashed", color = "grey40") +
    geom_hline(yintercept = mean_tokens, linetype = "dashed", color = "grey50") +
    # yellow area between the two mean curves (the observed Cooperation GAP)
    geom_ribbon(aes(ymin = mean_reci, ymax = mean_sent), fill = "#F0E5A8", alpha = 0.7) +
    # sent: rhombi
    geom_line(aes(y = mean_sent), color = color, linewidth = 0.9) +
    geom_errorbar(aes(ymin = mean_sent - se_sent, ymax = mean_sent + se_sent),
                  color = color, width = 0.04) +
    geom_point(aes(y = mean_sent), color = color, shape = 18, size = 3) +
    # received: squares
    geom_line(aes(y = mean_reci), color = color, linewidth = 0.9) +
    geom_errorbar(aes(ymin = mean_reci - se_reci, ymax = mean_reci + se_reci),
                  color = color, width = 0.04) +
    geom_point(aes(y = mean_reci), color = color, shape = 15, size = 2.5) +
    annotate("text", x = c(-0.55, 0.55), y = 0.4, size = 2.3, fontface = "bold",
             label = c("Receiver higher rank", "Sender higher rank")) +
    scale_x_continuous(limits = c(-1.1, 1.1), breaks = seq(-1, 1, 0.5)) +
    scale_y_continuous(limits = c(0, 11), breaks = c(0, 5, 10)) +
    labs(x = "Social Rank GAP", y = "Tokens") +
    theme_paper(base_size = 9)
}


## ---- panel-b-plot ----
plot_tokens("Non-friends", color_non_friends)


## ---- tokens-mutual ----
tokens_mutual <- plot_tokens("Mutual", color_mutual)


## ---- tokens-asymmetric ----
tokens_asymmetric <- plot_tokens("Sender declares", color_asymmetric)


## ---- panel-c-example ----
# Draw the non-friend observed and filtered GAP curves without a plotting function.
non_friend_gap_bins <- binned %>%
  filter(group == "Non-friends", is.finite(mean_dif_coop))

gap_non_friends <- ggplot(non_friend_gap_bins,
       aes(x = median_gap, y = mean_dif_coop, alpha = version)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey40") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_line(color = color_non_friends, linewidth = 0.9) +
  geom_errorbar(aes(ymin = mean_dif_coop - se_dif_coop,
                    ymax = mean_dif_coop + se_dif_coop),
                color = color_non_friends, width = 0.04) +
  geom_point(color = color_non_friends, size = 2.8) +
  scale_alpha_manual(values = c(Observed = 1, Filtered = 0.4)) +
  annotate("text", x = c(-0.55, 0.55), y = -5.6, size = 2.3, fontface = "bold",
           label = c("Receiver higher rank", "Sender higher rank")) +
  annotate("text", x = 1.05, y = c(5.7, 4.9), hjust = 1, size = 2.5,
           fontface = "bold", color = color_non_friends, alpha = c(1, 0.4),
           label = c("Observed data", "Null-model filtered")) +
  scale_x_continuous(limits = c(-1.1, 1.1), breaks = seq(-1, 1, 0.5)) +
  scale_y_continuous(limits = c(-6, 6), breaks = seq(-7.5, 5, 2.5)) +
  labs(x = "Social Rank GAP", y = "Cooperation GAP\n[Received - Sent]") +
  theme_paper(base_size = 9)


## ---- panel-c-function ----
# Reuse the same specification, with optional emphasis and limits.
plot_coop_gap <- function(this_group, color, y_limits = c(-6, 6), main = "Observed",
                          short_labels = FALSE) {
  bins <- binned %>% filter(group == this_group, is.finite(mean_dif_coop))
  back <- setdiff(c("Observed", "Filtered"), main)
  curve_labels <- c(Observed = "Observed data", Filtered = "Null-model filtered")

  ggplot(bins, aes(x = median_gap, y = mean_dif_coop, alpha = version)) +
    geom_vline(xintercept = 0, linetype = "dashed", color = "grey40") +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
    geom_line(color = color, linewidth = 0.9) +
    geom_errorbar(aes(ymin = mean_dif_coop - se_dif_coop, ymax = mean_dif_coop + se_dif_coop),
                  color = color, width = 0.04) +
    geom_point(color = color, size = 2.8) +
    scale_alpha_manual(values = setNames(c(1, 0.4), c(main, back))) +
    annotate("text", x = c(-0.55, 0.55), y = y_limits[1] + 0.4, size = 2.3, fontface = "bold",
             label = c("Receiver higher rank", "Sender higher rank")) +
    {if (short_labels)
      annotate("text", x = c(0.42, 1.08), y = y_limits[1] + 1.4, hjust = 1, size = 2.2,
               fontface = "bold", color = color, alpha = c(1, 0.5), label = c(main, back))
     else
      annotate("text", x = 1.05, y = y_limits[2] - c(0.3, 1.1), hjust = 1, size = 2.5,
               fontface = "bold", color = color, alpha = c(1, 0.4),
               label = curve_labels[c(main, back)])} +
    scale_x_continuous(limits = c(-1.1, 1.1), breaks = seq(-1, 1, 0.5)) +
    scale_y_continuous(limits = y_limits, breaks = seq(-7.5, 5, 2.5)) +
    labs(x = "Social Rank GAP", y = "Cooperation GAP\n[Received - Sent]") +
    theme_paper(base_size = 9)
}


## ---- panel-c-plot ----
plot_coop_gap("Non-friends", color_non_friends)


## ---- gap-mutual ----
gap_mutual <- plot_coop_gap("Mutual", color_mutual)


## ---- gap-asymmetric ----
gap_asymmetric <- plot_coop_gap("Sender declares", color_asymmetric, c(-8.5, 6))


## ---- all-panels ----
rows <- tribble(
  ~row,  ~heatmap_group,   ~rank_group,       ~color,            ~y_min,
  "I",   "Non-friends",    "Non-friends",     color_non_friends, -6,
  "II",  "Mutual friends", "Mutual",          color_mutual,      -6,
  "III", "Asymmetric",     "Sender declares", color_asymmetric,  -8.5
)

for (k in seq_len(nrow(rows))) {
  r <- rows[k, ]
  save_figure(plot_heatmap(r$heatmap_group),
              paste0("figure3_", r$row, "_A_heatmap"), width = 3.6, height = 3.2)
  save_figure(plot_tokens(r$rank_group, r$color),
              paste0("figure3_", r$row, "_B_tokens"), width = 3.2, height = 3)
  save_figure(plot_coop_gap(r$rank_group, r$color, y_limits = c(r$y_min, 6)),
              paste0("figure3_", r$row, "_C_coop_gap"), width = 3.2, height = 3)
}


## ---- fig3-save ----
write_csv(heatmap_cells, here("output", "tables", "figure3_heatmap_cells.csv"))
write_csv(children,      here("output", "tables", "figure3_children_summary.csv"))
write_csv(binned,        here("output", "tables", "figure3_binned_means.csv"))


## ---- figure3-assembly-render ----
source(here("code", "05_figure3_assembly_20261121.R"))
figure3_assembled <- assemble_figure3(plot_heatmap, plot_tokens, plot_coop_gap)
figure3_assembled


## ---- figure3-assembly-save ----
save_fig(figure3_assembled,
         here("output", "figures", "figure3_assembled_20261121"),
         class = "main_heatmap")
