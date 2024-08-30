class GamesController < ApplicationController
  def home
    # The game settings are the same as Expert level in Minesweeper
    # on Windows 3.1 to Windows XP , verified on https://www.minesweeper.info/wiki/Windows_Minesweeper
    @game = (Game.current || Game.start_new(width: 30, height: 16, mines: 99))
  rescue ActiveRecord::RecordNotUnique
    # We will hit this if another app server started the game
    # at the same time.
    retry
  end

  def index
    @games = Game.communal.finished
  end

  def my
    rodauth.require_account
    @games = current_account.games.reverse_by_creation
  end

  def show
    @game = Game.find(params[:id])
    if @game.private?
      rodauth.require_account
      head :not_found unless @game.owner == current_account
    end
  end

  def new
    rodauth.require_account
    @game = Game.new
  end

  def create
    rodauth.require_account
    game = Game.start_new(
      owner: current_account,
      **game_params.to_h.symbolize_keys
    )
    redirect_to game
  end

  def update
    x, y = params.require([:x, :y])
    mark_as_mine = params.fetch(:mark_as_mine, false)
    game = Game.find(params[:id])
    game_object = game.click!(x:, y:, mark_as_mine:)

    action = turbo_stream.versioned_replace game, partial: "games/game", locals: { game: game, board: game_object, just_finished: game.finished? }
    Turbo::Streams::BroadcastStreamJob.perform_later game, content: action

    respond_to do |format|
      format.turbo_stream { render turbo_stream: action }
      format.html { redirect_to game }
    end
  end

  def replay
    rodauth.require_account
    game = Game.find(params[:id])
    if game.finished?
      redirect_to game.replay_for(current_account)
    else
      head :forbidden
    end
  end

  private

  def game_params
    params.require(:game).permit(:width, :height, :mines, :fair_start)
  end
end
