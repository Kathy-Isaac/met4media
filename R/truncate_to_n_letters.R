truncate_to_n_letters <- Vectorize(function(text, n) {
  if (nchar(text) > n) {
    paste0(substr(text, 1, n), "...")
  } else {
    text
  }
})
