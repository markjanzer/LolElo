module ApplicationSeeder
  class CreateOrUpdateGame
    def initialize(panda_score_game)
      @panda_score_game = panda_score_game
    end

    def call
      return if forfeit?

      game = Game.find_or_initialize_by(panda_score_id: panda_score_game.panda_score_id)
      game.update!(
        end_at: panda_score_game.data["end_at"],
        winner: panda_score_game.winner,
        match: panda_score_game.match
      )
    end

    private

    attr_reader :panda_score_game

    def forfeit?
      panda_score_game.data["forfeit"]
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