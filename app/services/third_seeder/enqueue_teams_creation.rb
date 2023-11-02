module ThirdSeeder
  class EnqueueTeamsCreation
    def initialize(tournament_id)
      @tournament_id = tournament_id
    end

    def self.call(*)
      new(*).call
    end

    def call
      fetch_teams.each do |team|
        ::Seed::CreateTeamJob.perform_async(team["id"])
      end
    end

    private

    attr_reader :tournament_id

    def fetch_teams
      PandaScore.teams(tournament_id: tournament_id)
    end
  end
end