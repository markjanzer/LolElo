module ThirdSeeder
  class EnqueueGamesCreation
    def initialize(match_id)
      @match_id = match_id
    end

    def self.call(*)
      new(*).call
    end

    def call
      fetch_games(match_id)
        .each do |match|
          Seed::CreateGameJob.perform_async(match["id"])
        end
    end

    private

    def fetch_games(match_id)
      PandaScore.games(match_id: match_id)
    end
  end
end