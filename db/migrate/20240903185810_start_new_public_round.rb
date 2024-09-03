class StartNewPublicRound < ActiveRecord::Migration[7.1]
  def up
    Match.communal.active.first.update!(finished: true)
    new_match = Match.create!(name: "Fair Start Expert Mode")
    NewGame.create(fair_start: true, match: new_match)
  end

  def down
    new_match = Match.communal.active.first
    new_match.games.destroy_all
    new_match.destroy!
    Match.communal.last.update!(finished: false)
  end
end
