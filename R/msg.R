#' Create a single msg graphical object
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
  label <- str_wrap(text, width = max_char_width)

  # THEMING ----------------------------
  if (!is.list(theme)) theme <- get_theme(theme)
  fill_col <- ifelse(is_me, theme$fill_me, theme$fill_you)
  text_col <- ifelse(is_me, theme$text_me, theme$text_you)


  # DIMS -------------------------------
  h_pad <- grid::grobWidth(
    grid::textGrob("MM", gp = grid::gpar(fontsize = font_size))
  )
  v_pad <- grid::grobHeight(
    grid::textGrob("\n", gp = grid::gpar(fontsize = font_size))
  ) * 0.6
  label_width <- grid::grobWidth(
    grid::textGrob(label, gp = grid::gpar(fontsize = font_size))
  )
  label_height <- grid::grobHeight(
    grid::textGrob(label, gp = grid::gpar(fontsize = font_size))
  )
  xh <- grid::grobWidth(
    grid::textGrob("x", gp = grid::gpar(fontsize = font_size))
  )
  outer_radius <- xh * 2
  f <- 0.3
  has_newline <- grepl("\n", label)
  r <- ifelse(has_newline, 1.5, 1.7)

  # FIXME there's gotta be a better way to do this
  vpname <- paste0(text, round(stats::runif(1), 5))
  # Message viewpor
  msg_vp <- grid::viewport(
    name = paste0(vpname, ".msgvp"),
    x = ifelse(is_me, 0.95, 0.05),
    y = 0.5,
    width = label_width + h_pad,
    height = label_height + v_pad,
    just = ifelse(is_me, "right", "left"),
    gp = grid::gpar(col = NA, fill = fill_col)
  )

  body <- grid::roundrectGrob(
    r = r * xh, vp = msg_vp, name = paste0(vpname, "body")
  )
  text <- grid::textGrob(
    vp = msg_vp,
    label = label, just = "left", x = h_pad / 2,
    gp = grid::gpar(fontsize = font_size, col = text_col)
  )
  tail_vp <- grid::viewport(
    name = paste0(vpname, ".tailvp"),
    x = ifelse(is_me, 1, 0),
    y = outer_radius / 2,
    width = outer_radius,
    height = outer_radius,
    just = ifelse(is_me, c("right", "bottom"), c("left", "bottom"))
  )

  tail_points <- tail_path(f)
  if (is_me) {
    tail_points$x <- (-tail_points$x + 1 + f)
  } else {
    tail_points$x <- tail_points$x - f
  }
  tail <- grid::polygonGrob(
    tail_points$x, tail_points$y,
    vp = tail_vp, name = paste0(vpname, "tail")
  )
  tail_tree <- grid::gTree(
    vp = msg_vp, childrenvp = tail_vp, children = grid::gList(tail)
  )
  grid::gTree(
    childrenvp = msg_vp, children = grid::gList(tail_tree, body, text)
  )
}

# f is the factor the outer radius gets multiplied by to become the inner radius
# Since the outer radius is 1, f is actually just the inner radius
#
# h is the ADDITIONAL height added to the tops of the tail, usually for cases
# when the message has more than one line
#
# n is the number of points the tail should be composed of
tail_path <- function(f, n = 100, h = 0) {
  i <- inner_radius(f)
  o <- inner_radius(1, dir = "out") # outer just special case of inner
  ie <- inner_edge(f, h)
  oe <- outer_edge(h)

  all <- list(oe, o, i, ie)
  # The distribution of points isn't set: if the tail is taller, more should go
  # to the edges
  # Thus, the length of each segment needs to be calculated per-tail.
  total_path_len <- sum(sapply(all, \(x) x$path_len))
  seg_len <- total_path_len / n

  Reduce(rbind, lapply(all, \(x) x$points(seg_len)))
}

inner_radius <- function(f, dir = "in") {
  path_len <- (pi / 2) * f
  list(
    points = \(seg_len) {
      n <- ceiling(path_len / seg_len)
      # We clip off one at the end in order to chain points together without
      # duplicates

      # This adjustment keeps the number accurate
      n <- n + 1
      theta <- seq(-pi / 2, 0, length.out = n)
      x <- f * cos(theta)
      y <- f * sin(theta) + f
      if (dir == "out") {
        x <- rev(x)
        y <- rev(y)
      }
      out <- data.frame(x = x, y = y)
      out[-nrow(out), ]
    },
    path_len = path_len
  )
}

inner_edge <- function(f, h) {
  path_len <- 1 - f + h
  list(
    points = \(seg_len) {
      # Inner edge, being the final stroke drawn, does not have its tail clipped
      n <- ceiling(path_len / seg_len)
      x <- rep(f, n)
      y <- seq(f, 1 + h, length.out = n)
      data.frame(x = x, y = y)
    },
    path_len = path_len
  )
}

outer_edge <- function(h) {
  path_len <- h
  list(
    points = \(seg_len) {
      n <- ceiling(path_len / seg_len)
      x <- rep(1, n)
      # Stroke direction matters
      y <- seq(1 + h, 1, length.out = n)
      data.frame(x = x, y = y)
    },
    path_len = path_len
  )
}

clip_tail <- function(vec, n = 1) {
  vec[seq_len(length(vec) - n)]
}
