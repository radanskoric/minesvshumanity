class AddMarkAsMineToClick < ActiveRecord::Migration[7.1]
  def change
    add_column :clicks, :mark_as_mine, :boolean, default: false, null: false
  end
end
