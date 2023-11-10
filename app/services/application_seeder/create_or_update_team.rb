module ApplicationSeeder
  class CreateOrUpdateTeam
    def initialize(panda_score_team)
      @panda_score_team = panda_score_team
    end

    def call
      team = Team.find_or_initialize_by(panda_score_id: panda_score_team.panda_score_id)
      team.update(
        name: panda_score_team.data["name"],
        acronym: panda_score_team.data["acronym"],
        color: unique_team_color
      )
    end

    private

    attr_reader :panda_score_team
  
    def unique_team_color
      remaining_colors = Team::UNIQUE_COLORS - panda_score_team.tournament.serie.teams.pluck(:color)
      remaining_colors.sample
    end
  end
end