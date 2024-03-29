module ApplicationSeeder
  class CreateOrUpdateGame
    include Memery
    
    def initialize(panda_score_game)
      @panda_score_game = panda_score_game
    end

    def call
      return if forfeit?

      Game.transaction do
        game = Game.find_or_initialize_by(panda_score_id: panda_score_game.panda_score_id)

        if serie_begins_after_game?
          set_serie_begin_at_before_game_end_at
        end

        game.update!(
          end_at: end_at,
          winner: panda_score_game.winner,
          match: panda_score_game.match
        )
      end
    end

    private

    attr_reader :panda_score_game

    def forfeit?
      panda_score_game.data["forfeit"]
    end

    # There is at least one game (ps_id: 149787) without an end_at that wasn't forfeited.
    memoize def end_at
      return panda_score_game.data["end_at"] unless panda_score_game.data["end_at"].nil?

      # Not sure if I want this. Maybe I want things to break?
      return nil if panda_score_game.data["begin_at"].nil? || panda_score_game.data["length"].nil?

      DateTime.parse(panda_score_game.data["begin_at"]) + panda_score_game.data["length"].seconds
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