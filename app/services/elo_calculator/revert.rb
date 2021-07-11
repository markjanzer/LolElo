class EloCalculator
  class Revert
    def initialize(elo)
      @elo = elo
    end
  
    def call
      elo - (difference_from_reset * EloVariables::RATE_OF_REVERSION)
    end
  
    private

    attr_reader :elo

    def difference_from_reset
      elo - EloVariables::RESET_ELO
    end
  end
end