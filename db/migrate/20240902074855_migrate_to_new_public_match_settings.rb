class MigrateToNewPublicMatchSettings < ActiveRecord::Migration[7.1]
  def up
    public_match = Match.create(name: "Original Expert Mode")
    Game.where(owner_id: nil).update_all(match_id: public_match.id)
    add_index :games, [:status, :match_id], unique: true, where: "status = 0 AND match_id IS NOT NULL", name: :only_one_active_game_per_match
    remove_index :games, name: :only_one_public_game
    add_check_constraint :games, "owner_id IS NOT NULL OR match_id IS NOT NULL", name: :games_owner_or_match_id_must_be_set
  end

  def down
    remove_check_constraint :games, name: :games_owner_or_match_id_must_be_set
    add_index :games, :status, unique: true, where: "status = 0 AND owner_id IS NULL", name: :only_one_public_game
    remove_index :games, name: :only_one_active_game_per_match
    Game.where(owner_id: nil).update_all(match_id: nil)
    Match.destroy_all
  end
end
