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
