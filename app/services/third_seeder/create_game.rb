module ThirdSeeder
  class CreateGame
    def initialize(game_id)
      @game_id = game_id
    end

    def self.call(*)
      new(*).call
    end

    def call
      PandaScore::Game.find_or_initialize_by(panda_score_id: game_id)
        .update(data: fetch_game_data)
    end

    private

    attr_reader :game_id

    def fetch_game_data
      PandaScore.game(id: game_id)
    end
  end
end