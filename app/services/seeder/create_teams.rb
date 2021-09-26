class Seeder
  class CreateTeams
    def initialize(tournament)
      @tournament = tournament
    end

    def call
      teams_data.each do |team_data|
        team = new_team(team_data)
        unless tournament.teams.include?(team)
          tournament.teams << team
        end
      end
    end

    private

    attr_reader :tournament

    delegate :serie, to: :tournament

    def teams_data
      @teams_data ||= PandaScore.teams(tournament_id: tournament.panda_score_id)
    end

    def new_tournament(tournament_data)
      TournamentFactory.new(tournament_data).call
    end

    def unique_team_color
      remaining_colors.sample
    end

    def new_team(team_data)
      TeamFactory.new(team_data: team_data, serie: serie).call
    end
  end
end