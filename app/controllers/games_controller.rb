class GamesController < ApplicationController
  def home
    @first_public = Match.communal.finished.first
    @match = Match.current
    @game = @match.current_game! if @match
  end

  def index
    @match = Match.current
    @previous = Match.communal.finished
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
    @new_game = NewGame.new
  end

  def create
    rodauth.require_account
    @new_game = NewGame.new(
      owner: current_account,
      **game_params.to_h.symbolize_keys
    )

    if (game = @new_game.save)
      redirect_to game
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    x, y = params.require([:x, :y])
    mark_as_mine = params[:mark_as_mine]
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
