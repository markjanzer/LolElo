module NewSeeder
  class CreateGames
    def self.call
      new.call
    end

    def call
      PandaScore::Match.all.each do |match|
        fetch_games(match.panda_score_id).each do |game|
          game_data = game_data(game["id"])
          PandaScore::Game.find_or_initialize_by(panda_score_id: game["id"])
            .update(data: game_data)
        end
      end
    end

    private

    def fetch_games(match_id)
      PandaScoreAPI.games(match_id: match_id)
    end

    def fetch_game_data(game_id)
      PandaScoreAPI.game(id: game_id)
    end
  end
end