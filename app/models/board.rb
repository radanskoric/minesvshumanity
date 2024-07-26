class Board < ApplicationRecord
  has_one :game
  has_many :mines, dependent: :delete_all

  def to_game_object
    Minesweeper::Board.new(width, height, mines.map(&:to_coordinate))
  end
end
