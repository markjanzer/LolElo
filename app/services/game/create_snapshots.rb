class Game
  class CreateSnapshots
    def initialize(game)
      @game = game
    end

    def call
      create_winner_snapshot
      create_loser_snapshot
    end

    private

    attr_reader :game

    delegate :winner, :loser, to: :game

    def create_winner_snapshot
      Snapshot.create!(
        team: winner,
        game: game,
        date: game.end_at,
        elo: winner.elo + change_in_rating
      )
    end

    def create_loser_snapshot
      Snapshot.create!(
        team: loser,
        game: game,
        date: game.end_at,
        elo: loser.elo - change_in_rating
      )
    end

    def change_in_rating
      @change_in_rating ||= rating_change(result_expectancy).round
    end

    def result_expectancy
      win_expectancy(winner.elo, loser.elo)
    end

    def win_expectancy(primary_elo, other_elo)
      1 / (10**((other_elo - primary_elo) / 400.to_f) + 1)
    end
  
    def rating_change(expectancy)
      EloVariables::K * (1 - expectancy)
    end
  end
end