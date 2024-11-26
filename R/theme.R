#' Return a theme by its name
#' @param theme Character
#' @return A list, containing all necessary components of a theme
#' @export
get_theme <- function(theme = c("dark", "light")) {
  theme <- rlang::arg_match(theme)
  if (theme == "dark") {
    theme <- list(
      text_me = "white",
      text_you = "white",
      fill_me = "#218aff",
      fill_you = "gray20",
      bg = "#1C1C1C"
    )
    return(theme)
  }
  if (theme == "light") {
    theme <- list(
      text_me = "white",
      text_you = "black",
      fill_me = "#218aff",
      fill_you = "gray80",
      bg = "white"
    )
    return(theme)
  }
}

#' Make a custom message theme
#' @param text_me The color of text of the person on the right
#' @param text_you The color of the text of the person on the left
#' @param fill_me The color of the bubble of the person on the right
#' @param fill_you The color of the bubble of the person on the left
#' @param bg The color of the background
#' @return A list
#' @export
make_theme <- function(text_me = "white",
                       text_you = "black",
                       fill_me = "#218aff",
                       fill_you = "gray80",
                       bg = "white") {
  stopifnot(all(are_colors(c(text_me, text_you, fill_me, fill_you, bg))))

  list(
    text_me = text_me,
    text_you = text_you,
    fill_me = fill_me,
    fill_you = fill_you,
    bg = bg
  )
}

# shamefully stolen from https://stackoverflow.com/a/13290832
are_colors <- function(colors) {
  vapply(colors, function(x) {
    tryCatch(is.matrix(col2rgb(x)),
      error = function(e) FALSE
    )
  }, TRUE)
}
