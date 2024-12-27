#' Create a figure of a text conversation
#' @param data Expects a data.frame with columns "message_date", "text",
#'   "sender_name"
#' @param me Who should be the person on the right? Should be a person in
#'   data$sender_name
#' @param max_char_width How long the message be allowed to get (in characters)
#'   before wrapping
#' @param font_size The font size, in points
#' @param theme Either a list (usually made by make_theme()) or a name of a
#'   theme
#' @return An image
#' @examples
#'
#' conversation |>
#'   chat(me = "Alice")
#' @export
chat <- function(data,
                 me,
                 max_char_width = 80,
                 font_size = 12,
                 theme = "dark") {
  if (!is.list(theme)) {
    theme <- get_theme(theme)
  }
  stopifnot(me %in% data$sender_name)
  data <- data[order(data$message_date), ]
  # strwidth only deals in inches
  # Color should depend on service -- iMessage should be blue, SMS should be
  # green
  # 'me' will determine who's on the right
  grid::grid.rect(gp = grid::gpar(fill = theme$bg, col = theme$bg))

  grobs <- mapply(
    msgGrob,
    text = data$text,
    is_me = data$sender_name == me,
    MoreArgs = list(
      theme = theme,
      font_size = font_size
    ),
    SIMPLIFY = FALSE
  )

  grob_heights <- lapply(grobs, grid::grobHeight)
  layout <- grid::grid.layout(nrow(data), 1, widths = 1, heights = 1)
  fg <- grid::frameGrob(layout = layout)
  for (i in seq_len(nrow(data))) {
    fg <- grid::placeGrob(fg, grobs[[i]], row = i)
    grid::grid.draw(fg)
  }
}
