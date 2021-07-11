class EloCalculator
  class Revert
    def initialize(elo)
      @elo = elo
    end
  
    def call
      elo - (difference_from_reset * EloCalculator::RATE_OF_REVERSION)
    end
  
    private

    attr_reader :elo

    def difference_from_reset
      elo - EloCalculator::RESET_ELO
    end
  end
end