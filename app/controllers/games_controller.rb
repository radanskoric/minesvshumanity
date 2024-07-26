class GamesController < ApplicationController
  def index
    # The game settings are the same as Expert level in Minesweeper
    # on Windows 3.1 to Windows XP , verified on https://www.minesweeper.info/wiki/Windows_Minesweeper
    @game = (Game.current || Game.start_new(30, 16, 99))
  rescue ActiveRecord::RecordNotUnique
    # We will hit this if another app server started the game
    # at the same time.
    retry
  end

  def update
    x, y = params.require([:x, :y])
    @game = Game.find(params[:id])
    @game_object = @game.reveal!(x:, y:)

    render partial: 'games/board', locals: { model: @game, board: @game_object }
  end
end
