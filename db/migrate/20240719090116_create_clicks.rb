class CreateClicks < ActiveRecord::Migration[7.1]
  def change
    create_table :clicks do |t|
      t.references :game, null: false, foreign_key: true
      t.integer :x, null: false
      t.integer :y, null: false
      t.datetime :created_at, null: false
    end
  end
end
