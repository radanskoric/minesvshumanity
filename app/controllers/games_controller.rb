class GamesController < ApplicationController
  def index
    @game = Minesweeper::Game.new(Minesweeper::Board.generate_random(20, 10, 20))
    @game.reveal(Minesweeper::Coordinate.new(5, 5))
  end

  def update
  end
end
