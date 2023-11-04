module PandaScoreAPISeeder
  class CreateTeams
    def initialize(tournament)
      @tournament = tournament
    end

    def call
      team_panda_score_ids = tournament.data["teams"].map { |t| t["id"] }
      panda_score_teams = PandaScore::Team.where(panda_score_id: team_panda_score_ids)

      panda_score_teams.each do |ps_team|
        team = Team.find_or_initialize_by(panda_score_id: ps_team.data["id"])
        team.assign_attributes({
          panda_score_id: team_data["id"],
          name: team_data["name"],
          acronym: team_data["acronym"],
          color: unique_team_color,
        })
      end
    end

    private

    attr_reader :tournament

    def remaining_colors
      Team::UNIQUE_COLORS - tournament.serie.teams.pluck(:color)
    end
  
    def unique_team_color
      remaining_colors.sample
    end
  end
end