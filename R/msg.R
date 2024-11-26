#' @param text The message to be displayed
#' @param is_me Should this look like the sender or the receiver?
#' @param max_char_width Number of characters until wrapping
#' @param font_size The font size, in points
#' @param theme Either a character representing one of the themes in
#'   "get_theme", or a list (usually created from make_theme)
#' @return A grid::gTree
#' @export
#'
#' @examples
#' msgGrob("Hello!") |>
#'   grid::grid.draw()
msgGrob <- function(text,
                    is_me = TRUE,
                    max_char_width = 80,
                    font_size = 12,
                    theme = "light") {
  if (!is.list(theme)) {
    theme <- get_theme(theme)
  }
  h_pad <- grid::stringWidth("MM")
  v_pad <- grid::stringHeight("\n") * 0.6

  fill_col <- ifelse(is_me, theme$fill_me, theme$fill_you)
  text_col <- ifelse(is_me, theme$text_me, theme$text_you)
  bg <- theme$bg

  label <- str_wrap(text, width = max_char_width)
  # FIXME there's gotta be a better way to do this
  vpname <- paste0(text, round(runif(1), 5))

  # Message viewport
  child_vp <- grid::viewport(
    name = vpname,
    x = ifelse(is_me, 0.95, 0.05),
    y = 0.5,
    width = grid::stringWidth(label) + h_pad,
    height = grid::stringHeight(label) + v_pad,
    just = ifelse(is_me, "right", "left")
  )

  body <- grid::roundrectGrob(
    vp = vpname,
    r = grid::unit(0.5, units = "snpc"),
    gp = grid::gpar(fill = fill_col, col = NA),
  )

  tail_x <- grid::unit(ifelse(is_me, 1, 0), units = "npc")
  xh <- grid::stringHeight("x") * 0.75
  tail <- grid::circleGrob(
    vp = vpname,
    x = tail_x, y = xh, r = xh,
    gp = grid::gpar(fill = fill_col, col = NA)
  )
  tail_top_negative <- grid::circleGrob(
    vp = vpname,
    x = tail_x + xh / (2 * ifelse(is_me, 1, -1)), y = xh / 2, r = xh / 2,
    gp = grid::gpar(fill = bg, col = NA)
  )
  tail_side_negative <- grid::rectGrob(
    vp = vpname,
    x = tail_x + xh / (2 * ifelse(is_me, 1, -1)),
    y = grid::unit(0.5, units = "npc") + xh / 2,
    width = xh, height = 1,
    gp = grid::gpar(fill = bg, col = NA)
  )

  text <- grid::textGrob(
    vp = vpname,
    label = label, just = "left", x = h_pad / 2,
    gp = grid::gpar(fontsize = font_size, col = text_col)
  )

  msg_list <- grid::gList(
    body, tail, tail_top_negative, tail_side_negative, text
  )

  grid::gTree(label = text, children = msg_list, childrenvp = child_vp)
}
