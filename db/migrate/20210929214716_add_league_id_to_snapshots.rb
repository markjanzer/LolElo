class AddLeagueIdToSnapshots < ActiveRecord::Migration[6.0]
  def change
    add_reference :snapshots, :league, index: true, foreign_key: true
  end
end
