class RemoveTeamsTournamentsTeamsIndex < ActiveRecord::Migration[7.0]
  def change
    remove_index :teams_tournaments, :team_id
  end
end
