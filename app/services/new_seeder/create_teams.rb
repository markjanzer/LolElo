module NewSeeder
  class CreateTeams
    def self.call
      new.call
    end

    def call
      PandaScore::Tournament.all.each do |tournament|
        fetch_teams(tournament.panda_score_id).each do |team|
          team_data = team_data(team["id"])
          PandaScore::Team.find_or_initialize_by(panda_score_id: team["id"])
            .update(data: team_data)
        end
      end
    end

    private

    def fetch_teams(tournament_id)
      PandaScoreAPI.teams(tournament_id: tournament_id)
    end

    def fetch_team_data(team_id)
      PandaScoreAPI.team(id: team_id)
    end
  end
end