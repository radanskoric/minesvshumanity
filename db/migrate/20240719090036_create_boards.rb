class CreateBoards < ActiveRecord::Migration[7.1]
  def change
    create_table :boards do |t|
      t.integer :width
      t.integer :height

      t.timestamps
    end
  end
end
