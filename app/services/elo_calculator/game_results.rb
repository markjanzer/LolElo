# This should probably be a module
class EloCalculator
  class GameResults
    def initialize(winner_elo:, loser_elo:)
      @winner_elo = winner_elo
      @loser_elo = loser_elo
    end
  
    def new_elos
      [new_winner_elo, new_loser_elo]
    end
  
    def new_winner_elo
      winner_elo + rounded_rating_change
    end
    
    def new_loser_elo
      loser_elo - rounded_rating_change
    end
  
    private
  
    attr_reader :winner_elo, :loser_elo
  
    def rounded_rating_change
      rating_change.round
    end
  
    def result_expectancy
      1 / (10**((loser_elo - winner_elo) / 400.to_f) + 1)
    end
  
    def rating_change
      K * (1 - result_expectancy)
    end
  end
end