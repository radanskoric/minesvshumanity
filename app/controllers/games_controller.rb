class GamesController < ApplicationController
  def index
    # The game settings are the same as Expert level in Minesweeper
    # on Windows 3.1 to Windows XP , verified on https://www.minesweeper.info/wiki/Windows_Minesweeper
    @game = (Game.current || Game.start_new(30, 16, 99))
  end

  def update
    @game = Game.find(params[:id])
    @game.clicks.create!(params.slice(:x, :y).permit!)

    redirect_to root_path
  end
end
