class MatchesController < ApplicationController
  def show
    @match = Match.communal.find(params[:id])
  end
end
