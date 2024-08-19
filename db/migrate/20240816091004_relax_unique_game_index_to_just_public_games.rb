class RelaxUniqueGameIndexToJustPublicGames < ActiveRecord::Migration[7.1]
  def change
    add_index :games, :status, unique: true, where: "status = 0 AND owner_id IS NULL", name: :only_one_public_game
    remove_index :games, :status, unique: true, where: "status = 0", name: :index_games_on_status
  end
end
