class AddOwnerIdToGames < ActiveRecord::Migration[7.1]
  def change
    add_reference :games, :owner, foreign_key: { to_table: :accounts }
  end
end
