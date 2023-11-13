module ApplicationSeeder
  class CreateOrUpdateTeam
    def initialize(ps_team:, tournament:)
      @ps_team = ps_team
      @tournament = tournament
    end

    def call
      team = Team.find_or_initialize_by(panda_score_id: ps_team.panda_score_id)

      team.update!(
        name: ps_team.data["name"],
        acronym: ps_team.data["acronym"],
        color: unique_team_color
      )

      TeamsTournament.find_or_create_by(
        team: team,
        tournament: tournament
      )
    end

    private

    attr_reader :ps_team, :tournament
  
    def unique_team_color
      remaining_colors = Team::UNIQUE_COLORS - tournament.serie.teams.pluck(:color)
      remaining_colors.sample
    end
  end
end