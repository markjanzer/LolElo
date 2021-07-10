class Game
  class CreateSnapshots
    def initialize(game)
      @game = game
    end

    def call
      if game.winner == game.match.opponent_1
        winner = game.match.opponent_1
        loser = game.match.opponent_2
      elsif game.winner == game.match.opponent_2
        winner = game.match.opponent_2
        loser = game.match.opponent_1
      end
  
      result_expectancy = win_expectancy(winner.elo, loser.elo)
      change_in_rating = rating_change(result_expectancy).round
  
      Snapshot.create!(
        team: winner,
        game: game,
        date: game.end_at,
        elo: winner.elo + change_in_rating
      )
      Snapshot.create!(
        team: loser,
        game: game,
        date: game.end_at,
        elo: loser.elo - change_in_rating
      )
    end

    private

    attr_reader :game

    def win_expectancy(primary_elo, other_elo)
      1 / (10**((other_elo - primary_elo) / 400.to_f) + 1)
    end
  
    def rating_change(expectancy)
      EloVariables::K * (1 - expectancy)
    end
  end
end