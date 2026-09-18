#' Barplot to compare and cluster different cell culture media.
#'
#' The function generates a barplot using the ggplot2 package
#'
#' @param data A data frame containing metabolomics/composition data of different cell culture media.
#' @param category Optional vector to filter to specified metabolite categories.
#' @param n The number of characters to retain when displaying metabolite names. Set to 15 by default.
#'
#' @param x_var X axis variable. Set to `Compound` by default.
#' @param y_var Y axis variable. Set to `Concentration` by default.
#' @param fill_var Fill variable. Set to `Medium` by default.
#' @param x_lab X axis title. Set to the same value as x_var by default.
#' @param y_lab Y axis title. Set to the same value as y_var by default.
#' @param fill_lab Title for the fill legend. Set to the same value as fill_var by default.
#' @param legend Accepts the same values as ggplot. Set to `right` by default.
#' @param palette Color palette. Set to `Dark2` by default.
#'
#' @return A heatmap plot.
#'
#' @export
#'
plot_barplot <- function(data, category, n = 15, x_var = "Compound", y_var = "Concentration", fill_var = "Medium",
                         x_lab = x_var, y_lab = y_var, fill_lab = fill_var, legend = "right", palette = "Dark2"
) {


  d.plot <- data |>
    dplyr::filter(!is.na(Compound)) |>
    dplyr::filter(Concentration != "Present") |> # Get rid of strings to convert concentration back to type numeric
    dplyr::mutate(Concentration = as.numeric(Concentration)) |>
    dplyr::select(Compound, Category, Medium, Concentration) |>
    dplyr::distinct() |>
    dplyr::group_by(Compound, Category, Medium) |>
    dplyr::summarise(Concentration = sum(Concentration)) |> # In case two different names match to the same compound
    dplyr::ungroup() |>
    dplyr::distinct()

  # Filter to selected categories if applicable
  if(missing(category)) {
    d.plot <- d.plot
  } else {
    d.plot <- d.plot |>
      dplyr::filter(Category %in% category)
  }

  # Snip long metabolite names to n letters
  d.plot <- d.plot |>
    dplyr::mutate(Compound = truncate_to_n_letters(Compound, n))

  # Generate plot
  p <- ggplot2::ggplot(d.plot) +
    ggplot2::geom_bar(
      ggplot2::aes(
        x = .data[[x_var]],
        y = .data[[y_var]],
        fill = .data[[fill_var]]
      ),
      stat = "identity",
      position = "dodge") +
    ggplot2::scale_fill_brewer(fill_lab, palette = palette) +
    ggplot2::theme_classic() +
    ggplot2::theme(
      plot.margin = ggplot2::margin(0.2, 0.8, 0.2, 0.2, "cm"),
      legend.position = legend, legend.text = ggplot2::element_text(size = 13),
      axis.text.x = ggplot2::element_text(angle = -55, hjust = 0, vjust = 1),
      axis.text = ggplot2::element_text(size = 13),
      axis.title = ggplot2::element_text(size = 18)
    ) +
    ggplot2::ylab(y_lab) +
    ggplot2::xlab(x_lab)

  return(p)
}
