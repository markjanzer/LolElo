module PandaScoreAPISeeder
  class CreateMatchAndGames
    def initialize(match_id)
      @match_id = match_id
    end

    def self.call(*)
      new(*).call
    end

    def call
      match = PandaScore::Match.find_or_initialize_by(panda_score_id: match_id)
      match.update(data: fetch_match_data)

      match.data["games"].each do |game|
        PandaScore::Game.find_or_initialize_by(panda_score_id: game["id"])
          .update(data: game)
      end
    end

    private

    attr_reader :match_id

    def fetch_match_data
      PandaScoreAPI.match(id: match_id)
    end
  end
end