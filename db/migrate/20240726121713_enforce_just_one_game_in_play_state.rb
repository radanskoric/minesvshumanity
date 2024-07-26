class EnforceJustOneGameInPlayState < ActiveRecord::Migration[7.1]
  def change
    add_index :games, :status, unique: true, where: "status = 0"
  end
end
