class AddFairStartFlagToGames < ActiveRecord::Migration[7.1]
  def change
    add_column :games, :fair_start, :boolean, null: false, default: false
  end
end
