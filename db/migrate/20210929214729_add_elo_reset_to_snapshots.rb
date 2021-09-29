class AddEloResetToSnapshots < ActiveRecord::Migration[6.0]
  def change
    add_column :snapshots, :elo_reset, :boolean, default: false, null: false
  end
end
