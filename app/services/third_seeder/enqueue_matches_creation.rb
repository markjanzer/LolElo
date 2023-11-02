module ThirdSeeder
  class EnqueueMatchesCreation
    def initialize(tournament_id)
      @tournament_id = tournament_id
    end

    def self.call(*)
      new(*).call
    end

    def call
      fetch_matches(tournament_id)
        .each do |match|
          Seed::CreateMatchJob.perform_async(match["id"])
        end
    end

    private

    def fetch_matches(tournament_id)
      PandaScore.matches(tournament_id: tournament_id)
    end
  end
end