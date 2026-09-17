#' Loads comparison data sets
#'
#' The function loads media composition of fully and partially defined commercial media
#'
#' @param df An optional dataframe containing sample metabolite composition to append the commercial media composition to for comparison.
#' @param medium An optional vector to only load one or more select media from a list of DMEM, aDMEM, DMEM.F12, aDMEM.F12, F12, F10, MEM, IMDM, RPMI, aRPMI, McCoy5A, NBM, StemPro, mTeSR, E6, E8, ECGM, EpiLife, N2B27, StemSpan, UC, PluriSTEM
#' @param defined If set to TRUE (by default), only fully defined commercial media are loaded
#'
#' @return A data frame with commercial media metabolite composition.
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
#' load_comparison(data, medium = c("aDMEM", "aRPMI", "F12"))
load_comparison <- function(df, medium, defined = TRUE) {

  # Check if input variable defined is valid
  if(!is.logical(defined)) {
    stop("The input variable 'defined' must be set to TRUE/FALSE.")
  }

  # Filter to select media
  if (defined == TRUE) {
    commercial_media <- commercial_media %>%
      dplyr::filter(Group == "Defined")
  }
  if (missing(medium)) {
    commercial_media <- commercial_media
  } else if (all(medium %in% unique(commercial_media$Medium))) {
    commercial_media <- commercial_media %>%
      dplyr::filter(Medium %in% medium)
  } else {
    stop("Please select one or more valid media from the provided list: DMEM, aDMEM, DMEM.F12, aDMEM.F12, F12, F10, MEM, IMDM, RPMI, aRPMI, McCoy5A, NBM, StemPro, mTeSR, E6, E8, ECGM, EpiLife, N2B27, StemSpan, UC, PluriSTEM.")
  }

  if((missing(df)) || (nrow(df) == 0 && ncol(df) == 0)) {
    df <- commercial_media
  } else {
    # Check if input dataframe is valid
    if (!all(c("Name", "Compound", "Concentration", "HMDB", "KEGG") %in% colnames(df))) {
      stop("Please ensure the input dataframe has been standardized")
    }

    # If sample dataframe doesn't contain medium name, set default name of sample
    if (!"Medium" %in% names(df)) {
      df$Medium <- "Sample"
    }
    if (!"Group" %in% names(df)) {
      df$Group <- "Sample"
    }

    # Combine datasets
    cols <- intersect(colnames(df), colnames(commercial_media))
    commercial_media <- commercial_media %>%
      dplyr::select(all_of(cols))
    df <- df %>%
      dplyr::select(all_of(cols))
    df <- rbind(df, commercial_media)
  }

  return(df)

}
