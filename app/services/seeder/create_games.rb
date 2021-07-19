class Seeder
  class CreateGames
    def initialize(match)
      @match = match
    end

    def call
      completed_games_data.each do |game_data|
        match.games << new_game(game_data)
      end
    end

    private

    attr_reader :match

    def games_data
      @games_data ||= PandaScore.games(match_id: match.panda_score_id)
    end

    def completed_games_data
      completed_games_data = games_data.reject { |game| game['forfeit'] }
    end

    def new_game(game_data)
      GameFactory.new(game_data).call
    end
  end
end