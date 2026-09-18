#' Heatmap to compare and cluster different cell culture media.
#'
#' The function generates a clustered heatmap using the pheatmap package
#'
#' @param data A data frame containing metabolomics/composition data of different cell culture media.
#' @param category Optional vector to filter to specified metabolite categories.
#' @param n The number of characters to retain when displaying metabolite names. Set to 15 by default.
#' @param display_numbers Argument to display numbers in heatmap. Set to FALSE by default.
#' @param clustering_method Accepts the same values as pheatmap. Set to `complete` by default.
#' @param cluster_cols Accepts the same values as pheatmap. Set to TRUE by default.
#' @param cluster_rows Accepts the same values as pheatmap. Set to FALSE by default.
#' @param scale Accepts the same values as pheatmap. Set to `row` by default.
#' @param fontsize_row Accepts the same values as pheatmap. Set to 8 by default.
#' @param fontsize_column Accepts the same values as pheatmap. Set to 8 by default.
#' @param ann_col List of colors for each category.
#'
#' @return A heatmap plot.
#'
#' @export
#'
plot_heatmap <- function(data, category, n = 15, display_numbers = FALSE, clustering_method = "complete",
                         cluster_rows = FALSE, cluster_cols = TRUE, scale = "row",
                         fontsize_row = 8, fontsize_col = 8,
                         ann_col = list(Category = c( "Vitamins" = "#8DEEEE",
                                                      "Carbohydrates" = "#FFABA9",
                                                      "Amino Acids" = "#007FFF",
                                                      "Amino Acid Analogues and Peptides" = "#ee6363",
                                                      "Metallic Compounds" = "#FFA54F",
                                                      "Lipids" = "#AB82FF",
                                                      "Other" = "#EEAEEE"
                         ))) {

  # Get names of all media to use later
  cols <- unique(data$Medium)

  d.plot <- data |>
    dplyr::filter(!is.na(Compound)) |>
    dplyr::filter(Concentration != "Present") |> # Get rid of strings to convert concentration back to type numeric
    dplyr::mutate(Concentration = as.numeric(Concentration)) |>
    dplyr::filter(Concentration > 0) |>
    dplyr::select(Compound, Category, Medium, Concentration) |>
    dplyr::distinct() |>
    dplyr::group_by(Compound, Category, Medium) |>
    dplyr::summarise(Concentration = sum(Concentration)) |> # In case two different names match to the same compound
    dplyr::ungroup() |>
    tidyr::pivot_wider(
      names_from = Medium,
      values_from = Concentration,
      values_fill = 0
    ) |>
    dplyr::arrange(Category)

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

  # Format for heatmap
  d.int <- d.plot[, c(-2)]
  m.int <- as.matrix(d.int[, -1])
  m.int[is.na(m.int)] <- 0
  rownames(m.int) <- t(d.int[, 1])
  colnames(m.int) <- gsub("\\.", "-", colnames(m.int))

  # Annotation for heatmap
  ann <- d.plot |>
    dplyr::select(Category) |>
    as.data.frame()
  rownames(ann) <- rownames(m.int)

  # Generate heatmap
  p <- pheatmap::pheatmap(m.int,
                color = colorRampPalette(c("blue", "white", "red"))(100),
                na_col = "grey90",
                scale = scale, # Scaling rows by default
                clustering_method = clustering_method,  # Complete = hierarchical clustering method by default
                cluster_rows = cluster_rows, # FALSE by default
                cluster_cols = cluster_cols, # TRUE by default
                display_numbers = display_numbers,  # Display numeric values in cells is FALSE by default
                fontsize_row = fontsize_row,
                fontsize_col = fontsize_col,
                annotation_row = ann,
                annotation_colors = ann_col,
                main = ""
  )

  return(p)
}
