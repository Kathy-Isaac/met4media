#' Standardize names in metabolomics data sets.
#'
#' The function matches the input name with a standardized name, HMDB ID and KEGG ID.
#' The function is a wrapper that uses MetaboAnalyst API.
#'
#' @param df A data frame containing a `Name` column.
#'
#' @return A standardized data frame with columns `Compound`, `HMDB` and `KEGG`.
#'
#' @export
#'
#' @examples
#' data <-  data.frame(
#' Name = c("Glucose", "Tyrosine", "Valine"),
#' Concentration = c(4500, 3000, 2000)
#' )
#'
#' standardize(data)
standardize <- function(df) {

  # Check if input is valid
  if (!"Name" %in% colnames(df)) {
    stop("The input dataframe must have a column named 'Name' containing metabolite names")
  }

  # Generate a query list containing compound names separated by a semicolon
  names <- paste(df$Name, collapse = ";")
  body = list(queryList = names, inputType = "name")

  # Send the request to the MetaboAnalyst API
  url <- "https://rest.xialab.ca/api/mapcompounds"
  response <- httr::POST(url, body = body, encode = "json")

  # Check if the request is successful
  if (httr::status_code(response) == 200) {
    # Parse the JSON content
    analysis_result <- rjson::fromJSON(httr::content(response, "text", encoding = "UTF-8"), simplify = TRUE)
    # Clean up the response: un-nest nested lists; convert to proper NA characters
    analysis_result <- lapply(analysis_result, function(x) {
      if (is.list(x)) {
        x <- lapply(x, function(y) {
          if (is.null(y) || length(y) == 0) {
            NA_character_
          } else {
            y <- as.character(y)
            y[y == "NA"] <- NA_character_
            y[1]
          }
        })
        unlist(x)
      } else {
        x <- as.character(x)
        x[x == "NA"] <- NA_character_
        x
      }
    })
    analysis_result <- as.data.frame(analysis_result)
    analysis_result <- analysis_result |>
      dplyr::rename(Name = Query,
             Compound = Match) |>
      dplyr::select(Name, Compound, HMDB, KEGG)

    # Isolate and clean up names that didn't match to a compound and resend request
    if (anyNA(analysis_result$Compound)) {
      unmatched <- analysis_result |>
        dplyr::filter(is.na(Compound)) |>
        dplyr::mutate(
          # Remove prefixes and suffixes that interfere with name matching
          Name.mod = gsub("^(DL-|DL |D-|D |L-|L )|[ .]?HCL$|[ .]?hydrochloride$|[ .]?dihydrochloride$|[ .]?phosphate$", "", Name, ignore.case = TRUE)
        ) |>
        dplyr::select(Name, Name.mod)

      # Generate query list with modified names of unmatched compounds
      names <- paste(unmatched$Name.mod, collapse = ";")
      body = list(queryList = names, inputType = "name")

      # Resend API request
      response <- httr::POST(url, body = body, encode = "json")

      # Check response
      if (httr::status_code(response) == 200) {
        # Parse the JSON content
        analysis_result2 <- rjson::fromJSON(content(response, "text", encoding = "UTF-8"), simplify = TRUE)
        # Clean up content as before
        analysis_result2 <- lapply(analysis_result2, function(x) {
          if (is.list(x)) {
            x <- lapply(x, function(y) {
              if (is.null(y) || length(y) == 0) {
                NA_character_
              } else {
                y <- as.character(y)
                y[y == "NA"] <- NA_character_
                y[1]
              }
            })
            unlist(x)
          } else {
            x <- as.character(x)
            x[x == "NA"] <- NA_character_
            x
          }
        })
        analysis_result2 <- as.data.frame(analysis_result2)
        analysis_result2 <- analysis_result2 |>
          dplyr::rename(Name.mod = Query,
                 Compound = Match) |>
          dplyr::select(Name.mod, Compound, HMDB, KEGG)

        # Revert to original names in the second request
        analysis_result2 <- merge(unmatched, analysis_result2, by = "Name.mod")
        analysis_result2 <- analysis_result2 |>
          dplyr::select(-Name.mod)
        # Remove unmatched compounds from first request
        analysis_result <- analysis_result |>
          dplyr::filter(!is.na(Compound))
        # Combine the first and second responses
        analysis_result <- rbind(analysis_result, analysis_result2)
      }
      else {
        stop(paste("Error:", status_code(response),
                   "Unable to fetch data from MetaboAnalyst server"))
      }
    }

    # Merge results with input dataframe and return
    df <- merge(df, analysis_result, by = "Name", all.x = TRUE)
    return(df)
  } else {
    stop(paste("Error:", status_code(response),
               "Unable to fetch data from MetaboAnalyst server"))
  }
}
