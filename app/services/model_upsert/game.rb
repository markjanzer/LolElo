module ModelUpsert
  class Game
    def self.call(panda_score_game)
      new(panda_score_game).call
    end
    
    def initialize(panda_score_game)
      @panda_score_game = panda_score_game
    end

    def call
      return false if panda_score_game.match.nil? || panda_score_game.winner.nil?
      return if filter?

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
    
    def filter?
      panda_score_game.data["forfeit"] || panda_score_game.data["status"] == "not_started"
    end

    # There is at least one game (ps_id: 149787) without an end_at that wasn't forfeited.
    def transform_data(attributes)
      return attributes if attributes[:end_at].present?

      # Not sure if we want to have a game end at be the same time as a tournament. 
      if data["begin_at"] && data["length"]
        attributes[:end_at] = DateTime.parse(data["begin_at"]) + data["length"].seconds
      elsif panda_score_game.panda_score_match.data["end_at"]
        raise "do we really need to do this? panda_score_game.panda_score_id: #{panda_score_game.panda_score_id}"
        # attributes[:end_at] = panda_score_game.panda_score_match.data["end_at"]
      elsif panda_score_game.panda_score_match.panda_score_tournament.data["end_at"]
        raise "do we really need to do this? panda_score_game.panda_score_id: #{panda_score_game.panda_score_id}"
        # attributes[:end_at] = panda_score_game.panda_score_match.panda_score_tournament.data["end_at"]
      else
        raise "no end_at, begin_at, length, match end_at, or tournament end_at for game with panda_score_id: #{panda_score_game.panda_score_id}"
      end 

      attributes
    end
  end
end