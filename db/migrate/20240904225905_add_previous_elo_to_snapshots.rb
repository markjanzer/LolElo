class AddPreviousEloToSnapshots < ActiveRecord::Migration[7.0]
  def change
    add_column :snapshots, :previous_elo, :integer
  end
end
