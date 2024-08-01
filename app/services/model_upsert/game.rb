module ModelUpsert
  class Game
    def initialize(panda_score_game)
      @panda_score_game = panda_score_game
    end

    def call
      return if forfeit?

      attributes = {
        end_at: data["end_at"],
        winner: panda_score_game.winner,
        match: panda_score_game.match
      }

      attributes = transform_data(attributes)

      ::Game.find_or_initialize_by(panda_score_id: panda_score_game.panda_score_id)
        .update!(attributes)      
    end
    
    private
    
    attr_reader :panda_score_game

    def data
      panda_score_game.data
    end
    
    def forfeit?
      panda_score_game.data["forfeit"]
    end

    # There is at least one game (ps_id: 149787) without an end_at that wasn't forfeited.
    def transform_data(attributes)
      return attributes if attributes[:end_at].present?

      raise if data["begin_at"].nil? || data["length"].nil?

      attributes[:end_at] = DateTime.parse(data["begin_at"]) + data["length"].seconds
      attributes
    end
  end
end