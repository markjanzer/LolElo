module ApplicationSeeder
  class CreateOrUpdateTeam
    def initialize(ps_team:, tournament:)
      @ps_team = ps_team
      @tournament = tournament
    end

    def call
      team = Team.find_or_initialize_by(panda_score_id: ps_team.panda_score_id)

      if team.color.nil?
        team.color = unique_team_color
      end

      team.update!(
        name: ps_team.data["name"],
        acronym: ps_team.data["acronym"],
      )

      TeamsTournament.find_or_create_by(
        team: team,
        tournament: tournament
      )
    end

    private

    attr_reader :ps_team, :tournament
  
    def remaining_colors
      (Team::UNIQUE_COLORS - taken_colors)
    end
    
    def unique_team_color
      if remaining_colors.empty?
        return Team::UNIQUE_COLORS.sample
      end
      
      remaining_colors.sample
    end

    def taken_colors
      tournament.serie.teams.pluck(:color)
    end
  end
end