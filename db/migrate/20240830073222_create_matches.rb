class CreateMatches < ActiveRecord::Migration[7.1]
  def change
    create_table :matches do |t|
      t.belongs_to :owner, foreign_key: { to_table: :accounts }
      t.string :name
      t.boolean :finished, null: false, default: false

      t.timestamps
    end

    add_reference :games, :match, foreign_key: true
    add_index :matches, :finished, unique: true, where: "NOT finished AND owner_id IS NULL", name: :only_one_public_match
  end
end
