module ApplicationSeeder
  class CreateGames
    def initialize(match)
      @match = match
    end

    def call
      game_ids = match.data["games"].map { |g| g["id"] }
      panda_score_games = PandaScore::Game.where(panda_score_id: game_ids)
      completed_panda_score_games = panda_score_games.where("data ->> 'forfeit' = ?", "false")

      completed_panda_score_games.each do |ps_game|
        game = Game.find_or_initialize_by(panda_score_id: ps_game.data["id"])
        game.assign_attributes({
          end_at: end_at(ps_game.data),
          winner: winner(ps_game.data),
        })
        match.games << game
      end
    end

    private

    attr_reader :match

    # There is at least one game without an end at that timestamp that wasn't forfeited.
    # This should probably be fixed with the invalid matches corrector instead
    def end_at(game_data)
      if game_data['end_at'].nil?
        DateTime.parse(game_data['begin_at']) + game_data['length'].seconds
      else
        game_data['end_at']
      end
    end

    def winner(game_data)
      Team.find_by(panda_score_id: game_data['winner']['id'])
    end

    def completed_games_data
      completed_games_data = games_data.reject { |game| game['forfeit'] }
    end
  end
end