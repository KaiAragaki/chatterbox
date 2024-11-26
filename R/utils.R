# Stripped down version of stringr::str_wrap
# Trying to keep this pkg dependency light
# If it turns out I need more functionality though I'm ok with taking on a dep
# Do NOT export this function
str_wrap <- function(string, width) {
  strings <- strsplit(string, "\n")
  sapply(strings, .str_wrap, width = width, simplify = FALSE)[[1]] |>
    paste0(collapse = "\n")
}

.str_wrap <- function(string, width) {
  out <- stringi::stri_wrap(
    string,
    width = width, whitespace_only = TRUE, simplify = FALSE
  )
  vapply(out, paste0, collapse = "\n", character(1))
}
