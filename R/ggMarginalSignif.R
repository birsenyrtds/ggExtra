#' Scatter plot with top/right violin plots and significance annotations
#'
#' A custom alternative to ggMarginal that keeps a scatter plot in the center
#' and adds violin plots on the top and right, with optional ggsignif
#' annotations on the violin plots.
#'
#' @param data A data.frame.
#' @param x Name of x variable for scatter plot.
#' @param y Name of y variable for scatter plot.
#' @param group Name of grouping variable.
#' @param point_alpha Alpha for scatter points.
#' @param point_size Size for scatter points.
#' @param top_comparisons List of comparisons for top violin.
#' @param top_annotations Character vector of annotations for top violin.
#' @param top_y_position Numeric vector of y positions for top violin.
#' @param right_comparisons List of comparisons for right violin.
#' @param right_annotations Character vector of annotations for right violin.
#' @param right_y_position Numeric vector of y positions for right violin.
#'
#' @return A patchwork plot.
#' @export
ggMarginalSignif <- function(
  data,
  x,
  y,
  group,
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
    ggplot2::theme(
      legend.position = "bottom"
    )

  built_main <- ggplot2::ggplot_build(main_plot)

  x_breaks <- built_main$layout$panel_scales_x[[1]]$get_breaks()
  x_breaks <- x_breaks[is.finite(x_breaks)]
  x_limits <- built_main$layout$panel_scales_x[[1]]$get_limits()

  y_breaks <- built_main$layout$panel_scales_y[[1]]$get_breaks()
  y_breaks <- y_breaks[is.finite(y_breaks)]
  y_limits <- built_main$layout$panel_scales_y[[1]]$get_limits()

  top_plot <- ggplot2::ggplot(
    data,
    ggplot2::aes(
      x = !!group_var,
      y = !!x_var,
      fill = !!group_var,
      color = !!group_var
    )
  ) +
    ggplot2::geom_violin(alpha = 0.5, trim = FALSE) +
    ggplot2::scale_y_continuous(
      limits = x_limits,
      breaks = x_breaks
    ) +
    ggplot2::theme_classic() +
    ggplot2::theme(
      axis.title.x = ggplot2::element_blank(),
      axis.title.y = ggplot2::element_blank(),
      axis.text.x = ggplot2::element_blank(),
      axis.ticks.x = ggplot2::element_blank(),
      legend.position = "none"
    )

  if (!is.null(top_comparisons)) {
    top_plot <- top_plot +
      ggsignif::geom_signif(
        comparisons = top_comparisons,
        annotations = top_annotations,
        y_position = top_y_position,
        step_increase = 0.12,
        tip_length = 0.02
      )
  }

  right_plot <- ggplot2::ggplot(
    data,
    ggplot2::aes(
      x = !!group_var,
      y = !!y_var,
      fill = !!group_var,
      color = !!group_var
    )
  ) +
    ggplot2::geom_violin(alpha = 0.5, trim = FALSE) +
    ggplot2::scale_y_continuous(
      limits = y_limits,
      breaks = y_breaks
    ) +
    ggplot2::coord_flip() +
    ggplot2::theme_classic() +
    ggplot2::theme(
      axis.title.x = ggplot2::element_blank(),
      axis.title.y = ggplot2::element_blank(),
      axis.text.y = ggplot2::element_blank(),
      axis.ticks.y = ggplot2::element_blank(),
      legend.position = "none"
    )

  if (!is.null(right_comparisons)) {
    right_plot <- right_plot +
      ggsignif::geom_signif(
        comparisons = right_comparisons,
        annotations = right_annotations,
        y_position = right_y_position,
        step_increase = 0.12,
        tip_length = 0.02
      )
  }

  spacer <- patchwork::plot_spacer()

  final_plot <-
    (top_plot | spacer) /
    (main_plot | right_plot) +
    patchwork::plot_layout(
      widths = c(4, 1.8),
      heights = c(1.8, 4)
    )

  final_plot
}