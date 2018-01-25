#' @importFrom gtable gtable gtable_add_grob
#' @importFrom grid unit
#' @importFrom ggplot2 zeroGrob
make_cell <- function() {
  widths <- unit(rep(0, 15), 'mm')
  widths[8] <- unit(1, 'null')
  heights <- unit(rep(0, 18), 'mm')
  heights[10] <- unit(1, 'null')
  table <- gtable(widths, heights)
  table <- gtable_add_grob(table, list(zeroGrob()), 10, 8, z = -Inf, name = 'panel_cell')
  class(table) <- c('cellgrob', class(table))
  cell <- ggplot()
  class(cell) <- c('assemble_cell', class(cell))
  attr(cell, 'table') <- table
  cell
}
is.assemble_cell <- function(x) inherits(x, 'assemble_cell')
is.cellgrob <- function(x) inherits(x, 'cellgrob')
cell_table <- function(x, grob = NULL) {
  table <- attr(x, 'table')
  if (is.null(grob)) grob <- ggplotGrob(x)
  table$widths[c(1, ncol(table))] <- grob$widths[c(1, ncol(grob))]
  table$heights[c(1, nrow(table))] <- grob$heights[c(1, nrow(grob))]
  gtable_add_grob(table, grob$grobs[grep('background', grob$layout$name)], 1, 1,
                  nrow(table), ncol(table), z = -Inf, clip = 'on',
                  name = 'background')
}
#' @export
cellGrob <- function(x) {
  UseMethod('cellGrob')
}
#' @export
cellGrob.assemble_cell <- function(x) cell_table(x)
#' @importFrom grid grid.newpage grid.draw seekViewport pushViewport upViewport
#' @export
print.assemble_cell <- function(x, newpage = is.null(vp), vp = NULL, ...) {
  if (newpage) grid.newpage()

  grDevices::recordGraphics(
    requireNamespace("patchwork", quietly = TRUE),
    list(),
    getNamespace("patchwork")
  )
  gt <- cellGrob(x)
  if (is.null(vp)) {
    grid.draw(gt)
  } else {
    if (is.character(vp)) {
      seekViewport(vp)
    } else {
      pushViewport(vp)
    }
    grid.draw(gt)
    upViewport()
  }
  invisible(x)
}
#' @export
plot.assemble_cell <- print.assemble_cell