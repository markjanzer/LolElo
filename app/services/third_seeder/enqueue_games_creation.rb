module ThirdSeeder
  class EnqueueGamesCreation
    def initialize(match_id)
      @match_id = match_id
    end

    def self.call(*)
      new(*).call
    end

    def call
      fetch_games.each do |game|
        ::Seed::CreateGameJob.perform_async(game["id"])
      end
    end

    private

    attr_reader :match_id
    
    def fetch_games
      PandaScore.games(match_id: match_id)
    end
  end
end