module ApplicationSeeder
  class CreateOrUpdateGame
    include Memery
    
    def initialize(panda_score_game)
      @panda_score_game = panda_score_game
    end

    def call
      return if forfeit?

      Game.transaction do
        if serie_begins_after_game?
          set_serie_begin_at_before_game_end_at
        end

        panda_score_game.upsert_model
      end
    end

    private

    attr_reader :panda_score_game

    def forfeit?
      panda_score_game.data["forfeit"]
    end

    memoize def serie
      panda_score_game.match.tournament.serie
    end

    def serie_begins_after_game?
      serie.begin_at && end_at < serie.begin_at
    end

    def set_serie_begin_at_before_game_end_at
      serie.update!(begin_at: DateTime.parse(end_at) - 1.minute)
    end
  end
end