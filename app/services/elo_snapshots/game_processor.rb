module EloSnapshots
  class GameProcessor
    def initialize(game)
      @game = game
    end

    def call
      EloSnapshots::SerieTeamInitializer.new(team: winner, serie: serie).call
      EloSnapshots::SerieTeamInitializer.new(team: loser, serie: serie).call

      new_winner_elo, new_loser_elo = EloCalculator::GameResults.new(winner_elo: winner.elo, loser_elo: loser.elo).new_elos
      create_snapshot(team: winner, elo: new_winner_elo)
      create_snapshot(team: loser, elo: new_loser_elo)
    end

    private

    attr_reader :game

    delegate :winner, :loser, to: :game

    def serie
      game.match.tournament.serie
    end

    def create_snapshot(team:, elo:)
      Snapshot.create!(
        team: team,
        game: game,
        serie: serie,
        datetime: game.end_at,
        elo: elo
      )
    end
  end
end