class AddUniquenessIndexToTeamsTournaments < ActiveRecord::Migration[6.0]
  def change
    add_index :teams_tournaments, [:team_id, :tournament_id], :unique => true
  end
end
