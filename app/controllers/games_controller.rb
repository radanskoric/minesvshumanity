class GamesController < ApplicationController
  def home
    # The game settings are the same as Expert level in Minesweeper
    # on Windows 3.1 to Windows XP , verified on https://www.minesweeper.info/wiki/Windows_Minesweeper
    @game = (Game.current || Game.start_new(30, 16, 99))
  rescue ActiveRecord::RecordNotUnique
    # We will hit this if another app server started the game
    # at the same time.
    retry
  end

  def index
    @games = Game.finished.ordered
  end

  def show
    @game = Game.find(params[:id])
  end

  def update
    x, y = params.require([:x, :y])
    mark_as_mine = params.fetch(:mark_as_mine, false)
    game = Game.find(params[:id])
    game_object = game.click!(x:, y:, mark_as_mine:)

    render partial: 'games/game', locals: { game: game, board: game_object }
  end
end
