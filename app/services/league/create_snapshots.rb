# frozen_string_literal: true

class League
  class CreateSnapshots
    def initialize(league)
      @league = league
    end

    def call
      raise "league not defined" unless league

      # Get the games without snapshots
      # Order them chronologically

      # Destroy all snapshots that occur after the first of these games
      # invalid_snapshots.destroy_all
      # Create a snapshot for each game

      ordered_games.each do |game|
        Game::CreateSnapshots.new(game).call
      end
    end

    private

    attr_reader :league

    def ordered_games_without_snapshots
      game_ids = league.games.pluck(:id)
      game_ids_with_snapshots = Snapshot.where(game_id: game_ids).pluck(:game_id)
      Game.where(id: game_ids - game_ids_with_snapshots).order(end_at: :asc)
    end

    def earliest_snapshot_creation
      ordered_games_without_snapshots.first.date
    end

    def invalid_snapshots
      League.snapshots.where("date >= ?", earliest_snapshot_creation)
    end

    def ordered_games
      league.games.order(end_at: :asc)
      # Game.joins(match: { tournament: { serie: :league }}).where(league: league).order(end_at: :asc)
    end
  end
end