module HasCoordinate
  def to_coordinate
    Minesweeper::Coordinate.new(x, y)
  end
end
