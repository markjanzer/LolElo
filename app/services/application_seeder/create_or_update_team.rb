module ApplicationSeeder
  class CreateOrUpdateTeam
    def initialize(panda_score_tournament)
      @panda_score_tournament = panda_score_tournament
    end

    def call
      team = Team.find_or_initialize_by(panda_score_id: panda_score_team.data["id"])
      team.update(
        panda_score_id: team_data["id"],
        name: team_data["name"],
        acronym: team_data["acronym"],
        color: unique_team_color
      )
    end

    private

    attr_reader :tournament

    def tournament
      Tournament.find_by(panda_score_id: panda_score_team.data["tournament_id"])
    end

    def remaining_colors
      Team::UNIQUE_COLORS - tournament.serie.teams.pluck(:color)
    end
  
    def unique_team_color
      remaining_colors.sample
    end
  end
end