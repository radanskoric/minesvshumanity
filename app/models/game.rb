class Game < ApplicationRecord
  belongs_to :board
  has_many :clicks, dependent: :delete_all

  enum status: %i[play win lose]

  broadcasts_refreshes

  def self.current
    find_by(status: :play)
  end

  # @param [Integer] width
  # @param [Integer] height
  # @param [Integer] mines
  def self.start_new(width, height, mines)
    game_board = Minesweeper::Board.generate_random(width, height, mines)
    board = Board.create!(
      width: game_board.width,
      height: game_board.height,
      mines: game_board.mines.map { |mine| Mine.new(x: mine.x, y: mine.y) }
    )
    self.create!(board: board)
  end

  def to_game_object
    Minesweeper::Game.new(board.to_game_object).tap do |game|
      clicks.each { |click| game.reveal(click.to_coordinate) }
    end
  end

  def reveal!(x:, y:)
    clicks.create!(x:, y:)
    to_game_object.tap do |new_game_object|
      update!(status: new_game_object.status)
    end
  end
end
