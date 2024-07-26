module GamesHelper
  def cell_to_character(cell)
    if cell.is_a? Minesweeper::Board::Mine
      "&#9673;".html_safe
    elsif !cell.neighbour_mines.zero?
      cell.neighbour_mines
    end
  end
end
