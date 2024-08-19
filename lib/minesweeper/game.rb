require_relative "board"

module Minesweeper
  class Game
    CELL_WITH_NO_ADJACENT_MINES = Board::Empty.new(0)
    END_STATUSES = %i[win lose].freeze

    class Marker
      def to_s = "🚩"
    end

    attr_reader :status

    def initialize(board)
      @cells = Array.new(board.height * board.width)
      @board = board
      @status = :play
    end

    def width = @board.width
    def height = @board.height
    def cell(coordinate) = @cells[cell_index(coordinate)]

    def mark(coordinate)
      @cells[cell_index(coordinate)] ||= Marker.new
    end

    def reveal(coordinate)
      return @status if END_STATUSES.include?(@status)
      @status = reveal_cell_and_flood(coordinate)
    end

    def mines_left
      @board.mines.size - @cells.count { |cell| cell.is_a? Marker }
    end

    private

    def reveal_cell_and_flood(coordinate)
      cell = cell(coordinate)

      if cell # cell is marked or revealed
        set_cell(coordinate, nil) if cell.is_a? Marker
        return :play
      end

      cell = set_cell(coordinate, @board.cell(coordinate))
      return :lose if cell.is_a?(Board::Mine)
      flood_from(coordinate) if cell == CELL_WITH_NO_ADJACENT_MINES

      is_game_won? ? :win : :play
    end

    def is_game_won?
      @cells.count { |cell| cell.nil? || cell.is_a?(Marker) } == @board.mines.size
    end

    def set_cell(coordinate, value)= @cells[cell_index(coordinate)] = value
    def cell_index(coordinate)= coordinate.y * @board.width + coordinate.x

    def flood_from(start_coordinate)
      flood_stack = [start_coordinate]

      while (coordinate = flood_stack.pop)
        coordinate.neighbours(width, height).each do |neighbour|
          cell = cell(neighbour)
          if cell.nil? || cell.is_a?(Marker)
            cell = set_cell(neighbour, @board.cell(neighbour))
            flood_stack.push(neighbour) if cell == CELL_WITH_NO_ADJACENT_MINES
          end
        end
      end
    end
  end
end
