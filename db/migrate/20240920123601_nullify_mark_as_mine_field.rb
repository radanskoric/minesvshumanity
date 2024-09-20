class NullifyMarkAsMineField < ActiveRecord::Migration[7.1]
  def change
    change_column_null :clicks, :mark_as_mine, true
    change_column_default :clicks, :mark_as_mine, from: false, to: nil

    reversible do |dir|
      dir.up { Click.where(mark_as_mine: false).update_all(mark_as_mine: nil) }
      dir.down { Click.where(mark_as_mine: nil).update_all(mark_as_mine: false) }
    end
  end
end
