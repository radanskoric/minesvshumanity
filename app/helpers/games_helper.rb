module GamesHelper

  def render_cell(cell)
    if cell
      content_tag :td, cell_value(cell)
    else
      content_tag :td, nil, class: "cell-hidden"
    end
  end

  private

  def cell_value(cell)
    if cell.is_a? Minesweeper::Board::Mine
      "&#9673;".html_safe
    elsif !cell.neighbour_mines.zero?
      cell.neighbour_mines
    end
  end
end
