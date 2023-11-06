module ApplicationSeeder
  class CreateOrUpdateGame
    def initialize(panda_score_game)
      @panda_score_game = panda_score_game
    end

    def call
      return if forfeit?

      game = Game.find_or_initialize_by(panda_score_id: ps_game.data["id"])
      game.update(
        end_at: pand_score_game.data["end_at"],
        winner: winner,
        match: match
      )
    end

    private

    attr_reader :panda_score_game

    def forfeit?
      panda_score_game.data["forfeit"]
    end

    def winner
      Team.find_by(panda_score_id: panda_score_game.data["winner"]["id"])
    end

    def match
      Match.find_by(panda_score_id: panda_score_game.data["match_id"])
    end

    # There is at least one game without an end at that timestamp that wasn"t forfeited.
    # This should probably be fixed with the invalid matches corrector instead
    # def end_at(game_data)
    #   if game_data["end_at"].nil?
    #     DateTime.parse(game_data["begin_at"]) + game_data["length"].seconds
    #   else
    #     game_data["end_at"]
    #   end
    # end
  end
end