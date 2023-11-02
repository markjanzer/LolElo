module ThirdSeeder
  class EnqueueTeamsCreation
    def initialize(tournament_id)
      @tournament_id = tournament_id
    end

    def self.call(*)
      new(*).call
    end

    def call
      fetch_teams(tournament_id)
        .each do |team|
          Seed::CreateTeamJob.perform_async(team["id"])
        end
    end

    private

    def fetch_teams(tournament_id)
      PandaScore.teams(tournament_id: tournament_id)
    end
  end
end