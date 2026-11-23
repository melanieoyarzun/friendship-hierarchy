# ====================================================================
# Title: theme_hierarchy() — unified figure style
# Description: House ggplot2 theme, semantic color roles, scales and a
#              class-based export helper for all manuscript / SI figures.
# Usage: source(here::here("code", "theme_hierarchy_20261121.R"))
#        ggplot(df, aes(x, y)) + geom_point() + theme_hierarchy(16)
# Created by: Melanie Oyarzun
# Version: 1 (style finalized June 2026)
# ====================================================================

# --- Color roles ------------------------------------------------------
# Friendship category (primary categorical channel; 4 levels)
pal_category <- c(
  "Mutual"         = "#00A388",  # teal (signature)
  "Non Friends"    = "#543287",  # purple
  "Ego declares"   = "#00B6EB",  # cyan
  "Alter declares" = "#E6A700"   # gold
)

ink         <- "#383838"   # dark axes, reference lines, ink
ink_point   <- "#4D4D4D"   # neutral scatter points ("all", no category)
ink_annot   <- "#222222"   # in-plot stat labels (R, p)
edge_light  <- "#BFBFBF"   # top / right closing edges of the panel
accent      <- "#C95A3A"   # attention / focus: trend lines, highlights

# Sequential / intensity (heatmaps): low -> high
ramp_seq <- c("#F7E08A", "#E7B56A", "#D9874C", "#C95A3A")

# Divergent / signed (balance): navy <- neutral -> brick
ramp_div <- c("#163E5C", "#4A7CA0", "#F2F2EE", "#E0A66A", "#C95A3A")

# Sex (universal, non-stereotyped)
pal_sex <- c("#6A4A63", "#9CB380")  # aubergine / sage

# Observed vs random/filtered: SAME hue, vary alpha (never two hues)
alpha_obs <- c(Observed = 0.35, Filtered = 1)

# --- House theme ------------------------------------------------------
# base_size: canonical per figure class (main 30, heatmap 24, SI 16,
#            dense facet grid 12). Axis numbers = base - 8 (large).
# grid:      "none" (default) or "h" (faint horizontal gridlines).
theme_hierarchy <- function(base_size = 30, grid = c("none", "h")) {
  grid <- match.arg(grid)
  ax_w <- base_size / 30 * 1.6  # axis weight scales gently with base_size

  t <- ggplot2::theme(
    text             = ggplot2::element_text(size = base_size),
    plot.title       = ggplot2::element_text(size = base_size, face = "bold",
                                              lineheight = .8),
    plot.title.position = "plot",
    strip.text       = ggplot2::element_text(face = "bold", colour = "white"),
    axis.title       = ggplot2::element_text(size = base_size - 10),
    axis.text        = ggplot2::element_text(size = max(base_size - 8, 8),
                                             colour = ink),
    legend.title     = ggplot2::element_text(size = base_size - 16),
    legend.text      = ggplot2::element_text(size = base_size - 16),
    legend.position  = "none",
    axis.ticks       = ggplot2::element_blank(),
    panel.grid       = ggplot2::element_blank(),
    panel.background = ggplot2::element_rect(fill = "white", colour = NA),
    # light-gray closing box on all four sides ...
    panel.border     = ggplot2::element_rect(colour = edge_light, fill = NA,
                                             linewidth = 0.6),
    # ... then dark over-draw on bottom + left only (the real X / Y axes)
    axis.line.x.bottom = ggplot2::element_line(colour = ink, linewidth = ax_w),
    axis.line.y.left   = ggplot2::element_line(colour = ink, linewidth = ax_w)
  )

  if (grid == "h") {
    t <- t + ggplot2::theme(
      panel.grid.major.y = ggplot2::element_line(colour = "#ECECEC",
                                                 linewidth = 0.4)
    )
  }
  t
}

# --- Scales -----------------------------------------------------------
scale_color_category <- function(...) ggplot2::scale_color_manual(values = pal_category, ...)
scale_fill_category  <- function(...) ggplot2::scale_fill_manual(values = pal_category, ...)
scale_color_sex      <- function(...) ggplot2::scale_color_manual(values = pal_sex, ...)
scale_fill_sex       <- function(...) ggplot2::scale_fill_manual(values = pal_sex, ...)
scale_alpha_obs      <- function(...) ggplot2::scale_alpha_manual(values = alpha_obs, ...)

scale_fill_intensity <- function(values = c(0, 5, 10, 15), ...) {
  ggplot2::scale_fill_gradientn(colours = ramp_seq,
                                values = scales::rescale(values), ...)
}

scale_fill_divergent <- function(limits = NULL, midpoint = 0, ...) {
  ggplot2::scale_fill_gradientn(colours = ramp_div, limits = limits, ...)
}

# For lettered panel tags in combined figures:
#   patchwork::wrap_plots(p1, p2, p3) +
#     patchwork::plot_annotation(tag_levels = "A")

# --- Standardized export ----------------------------------------------
fig_dims <- list(
  main_dual       = c(13,  6),
  main_heatmap    = c(13, 12),
  si_single       = c(8.5, 5),
  si_row3         = c(13,  4.5),
  si_grid_2x2plus = c(16,  9),
  si_grid_2x3     = c(15,  9),
  si_stack        = c(12,  9),
  si_wide         = c(12,  5.5),
  si_facet_dense  = c(13, 10)
)

# Always writes both a vector PDF (for LaTeX) and a raster PNG, dpi = 320.
save_fig <- function(plot, file_stub, class = "si_single", dpi = 320) {
  d <- fig_dims[[class]]
  if (is.null(d)) stop("save_fig(): unknown class '", class, "'.")
  dir.create(dirname(file_stub), showWarnings = FALSE, recursive = TRUE)
  ggplot2::ggsave(paste0(file_stub, ".pdf"), plot, width = d[1], height = d[2])
  ggplot2::ggsave(paste0(file_stub, ".png"), plot, width = d[1], height = d[2], dpi = dpi)
  invisible(file_stub)
}
