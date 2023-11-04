module ApplicationSeeder
  class EnqueueTeamsCreation
    def initialize(tournament_id)
      @tournament_id = tournament_id
    end

    def self.call(*)
      new(*).call
    end

    def call
      team_ids = fetch_teams.map { |team| [team["id"]] }
      ::Seed::CreateTeamJob.perform_bulk(team_ids)
    end

    private

    attr_reader :tournament_id

    def fetch_teams
      PandaScoreAPI.teams(tournament_id: tournament_id)
    end
  end
end