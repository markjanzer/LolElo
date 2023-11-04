module PandaScoreAPISeeder
  class EnqueueMatchesCreation
    def initialize(tournament_id)
      @tournament_id = tournament_id
    end

    def self.call(*)
      new(*).call
    end

    def call
      match_ids = fetch_matches.map { |match| [match["id"]] }
      ::Seed::CreateMatchAndGamesJob.perform_bulk(match_ids)
    end

    private

    attr_reader :tournament_id

    def fetch_matches
      PandaScoreAPI.matches(tournament_id: tournament_id)
    end
  end
end