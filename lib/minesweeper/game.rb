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
      index = cell_index(coordinate)
      if @cells[index].is_a? Marker
        @cells[index] = nil
        return :play
      end

      return :play if @cells[index]

      (@cells[index] = @board.cell(coordinate)).tap do |cell|
        return :lose if cell.is_a?(Board::Mine)
        reveal_neighbours(coordinate) if cell == CELL_WITH_NO_ADJACENT_MINES
      end
      @cells.count { |cell| cell.nil? || cell.is_a?(Marker) } == @board.mines.size ? :win : :play
    end

    def cell_index(coordinate)= coordinate.y * @board.width + coordinate.x

    def reveal_neighbours(coordinate)
      coordinate.neighbours(width, height).each { |n| reveal(n) }
    end
  end
end
