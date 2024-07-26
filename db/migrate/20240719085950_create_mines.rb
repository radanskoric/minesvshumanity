class CreateMines < ActiveRecord::Migration[7.1]
  def change
    create_table :mines do |t|
      t.references :board, null: false, foreign_key: true
      t.integer :x, null: false
      t.integer :y, null: false
    end
  end
end
