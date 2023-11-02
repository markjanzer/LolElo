module ThirdSeeder
  class EnqueueMatchesCreation
    def initialize(tournament_id)
      @tournament_id = tournament_id
    end

    def self.call(*)
      new(*).call
    end

    def call
      fetch_matches.each do |match|
        ::Seed::CreateMatchAndGamesJob.perform_async(match["id"])
      end
    end

    private

    attr_reader :tournament_id

    def fetch_matches
      PandaScore.matches(tournament_id: tournament_id)
    end
  end
end