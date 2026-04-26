library(ggplot2)
library(patchwork)
library(rlang)
library(ggsignif)

make_p_labels <- function(data, value, group, comparisons) {
  sapply(comparisons, function(comp) {
    sub_data <- data[data[[group]] %in% comp, ]
    p <- t.test(sub_data[[value]] ~ sub_data[[group]])$p.value
    paste0("p = ", signif(p, 3))
  })
}

ggMarginalSignif <- function(
  data, x, y, group,
  point_alpha = 0.6,
  point_size = 2,
  top_comparisons = NULL,
  top_annotations = NULL,
  top_y_position = NULL,
  right_comparisons = NULL,
  right_annotations = NULL,
  right_y_position = NULL
) {
  x_var <- rlang::ensym(x)
  y_var <- rlang::ensym(y)
  group_var <- rlang::ensym(group)

  main_plot <- ggplot2::ggplot(
    data,
    ggplot2::aes(x = !!x_var, y = !!y_var, color = !!group_var)
  ) +
    ggplot2::geom_point(alpha = point_alpha, size = point_size) +
    ggplot2::theme_classic() +
    ggplot2::theme(legend.position = "none")

  built_main <- ggplot2::ggplot_build(main_plot)

  x_breaks <- built_main$layout$panel_scales_x[[1]]$get_breaks()
  x_breaks <- x_breaks[is.finite(x_breaks)]
  x_limits <- built_main$layout$panel_scales_x[[1]]$get_limits()

  y_breaks <- built_main$layout$panel_scales_y[[1]]$get_breaks()
  y_breaks <- y_breaks[is.finite(y_breaks)]
  y_limits <- built_main$layout$panel_scales_y[[1]]$get_limits()
  if (!is.null(top_comparisons) && is.null(top_annotations)) {
    top_annotations <- make_p_labels(
      data = data,
      value = rlang::as_string(y_var),
      group = rlang::as_string(group_var),
      comparisons = top_comparisons
    )
  }

  if (!is.null(right_comparisons) && is.null(right_annotations)) {
    right_annotations <- make_p_labels(
      data = data,
      value = rlang::as_string(x_var),
      group = rlang::as_string(group_var),
      comparisons = right_comparisons
    )
  }
  # ── TOP violin ──────────────────────────────────────────────────────────────
  # Görselde: x = grup (factor), y = hwy → yatay uzanan violinler
  # group_var olarak y_var'ı (hwy) eksende, x ekseninde group olmalı
  top_plot <- ggplot2::ggplot(
    data,
    ggplot2::aes(
      x = !!group_var,
      y = !!y_var,          # <── değişti: y_var (hwy), yatay violin
      fill = !!group_var,
      color = !!group_var
    )
  ) +
    ggplot2::geom_violin(alpha = 0.5, trim = FALSE) +
    ggplot2::scale_y_continuous(
      breaks = y_breaks,
      limits = y_limits
    ) +
    ggplot2::coord_flip() +  # <── yatay violin için
    ggplot2::theme_classic() +
    ggplot2::theme(
      axis.title.x  = ggplot2::element_blank(),
      axis.title.y  = ggplot2::element_blank(),
      axis.text.x   = ggplot2::element_blank(),
      axis.ticks.x  = ggplot2::element_blank(),
      axis.text.y   = ggplot2::element_blank(),
      axis.ticks.y  = ggplot2::element_blank(),
      legend.position = "none"
    )

  if (!is.null(top_comparisons)) {
    top_plot <- top_plot + ggsignif::geom_signif(
      comparisons  = top_comparisons,
      annotations  = top_annotations,
      y_position   = top_y_position,
      tip_length   = 0.02
    )
  }

  # ── RIGHT violin ─────────────────────────────────────────────────────────────
  # Görselde: x = displ (grup/factor), y ekseni dikey — violinler dikey duruyor
  right_plot <- ggplot2::ggplot(
    data,
    ggplot2::aes(
      x = !!group_var,
      y = !!x_var,          # <── değişti: x_var (displ)
      fill = !!group_var,
      color = !!group_var
    )
  ) +
    ggplot2::geom_violin(alpha = 0.5, trim = FALSE) +
    ggplot2::scale_y_continuous(
      breaks = x_breaks,
      limits = x_limits
    ) +
    # coord_flip YOK → violinler dikey kalıyor
    ggplot2::theme_classic() +
    ggplot2::theme(
      axis.title.x  = ggplot2::element_blank(),
      axis.title.y  = ggplot2::element_blank(),
      axis.text.x   = ggplot2::element_blank(),
      axis.ticks.x  = ggplot2::element_blank(),
      axis.text.y   = ggplot2::element_blank(),
      axis.ticks.y  = ggplot2::element_blank(),
      legend.position = "none"
    )

  if (!is.null(right_comparisons)) {
    right_plot <- right_plot + ggsignif::geom_signif(
      comparisons  = right_comparisons,
      annotations  = right_annotations,
      y_position   = right_y_position,
      tip_length   = 0.02
    )
  }

  spacer <- patchwork::plot_spacer()

  # ── Layout ────────────────────────────────────────────────────────────────────
  # Görseldeki düzen:
  #   [ top_plot  ] [ spacer     ]   ← üst satır
  #   [ main_plot ] [ right_plot ]   ← alt satır
  final_plot <- (top_plot | spacer) / (main_plot | right_plot) +
    patchwork::plot_layout(
      widths  = c(4, 1.8),
      heights = c(1.8, 4)
    )

  final_plot
}