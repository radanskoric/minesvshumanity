require_relative "coordinate"

module Minesweeper
  class Board < Data.define(:width, :height, :mines)
    class Mine; end;
    Empty = Data.define(:neighbour_mines)

    def self.generate_random(width, height, mines_count, fair_start:)
      full_board = Enumerator.product(width.times, height.times).map { |x, y| Coordinate.new(x, y) }

      first_reveal = nil
      if fair_start
        first_reveal = Coordinate.new(rand(width), rand(height))
        full_board -= [first_reveal, *first_reveal.neighbours(width, height)]
      end

      [
        self.new(width, height, full_board.sample(mines_count)),
        first_reveal
      ]
    end

    def cell(coordinate)
      mines.include?(coordinate) ? Mine.new : Empty.new(count_neighbours(coordinate))
    end

    private

    def count_neighbours(coordinate)
      mines.count { |mine| mine.neighbour?(coordinate) }
    end
  end
end
