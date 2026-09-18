#' Categorizes metabolites to categories
#'
#' The function matches the HMDB ID of a metabolite to HMDB classes and sub-classes and a manually curated category.
#' It is recommended that the dataframe is first standardized using the `standardize` function.
#'
#' @param df A data frame containing a `HMDB` column.
#'
#' @return A data frame with columns `Class`, `SubClass` and `Category`.
#'
#' @export
#'
#' @examples
#' data <-  data.frame(
#' Name = c("Glucose", "Tyrosine", "Valine"),
#' Compound = c("D-Glucose", "L-Tyrosine", "L-Valine"),
#' HMDB = c("HMDB0000122", "HMDB0000158", "HMDB0000883"),
#' KEGG = c("C00031", "C00082", "C00183"),
#' Concentration = c(4500, 3000, 2000)
#' )
#'
#' categorize(data)
categorize <- function(df) {
  # Check if input is valid
  if (!"HMDB" %in% colnames(df)) {
    stop("The input dataframe must have a column named HMDB with HMDB IDs")
  }
  # Load the HMDB database
  # Name,	HMDB,	Class and	SubClass were obtained from https://www.hmdb.ca/downloads (All metabolites released on 2021-11-17)
  # Category was manually curated
  cols <- c(colnames(df), "Class",  "SubClass", "Category")
  df <- merge(df, metabolite_categories, by = "HMDB", all.x = TRUE) |>
    dplyr::select(all_of(cols)) |>
    dplyr::mutate(Category = ifelse(is.na(Category), "Other", Category))
  return(df)
}
