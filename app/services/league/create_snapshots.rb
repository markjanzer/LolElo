# frozen_string_literal: true

class League
  class CreateSnapshots
    def initialize(league)
      @league = league
    end

    def call
      raise "league not defined" unless league
      return "No snapshots to create" unless first_game_without_snapshots

      league.snapshots.where("date >= ?", create_snapshots_from).destroy_all

      league.reload.games.where("games.end_at >= ?", create_snapshots_from).order(end_at: :asc).each do |game|
        Game::CreateSnapshots.new(game).call
      end
    end

    private

    attr_reader :league

    def first_game_without_snapshots
      # SLQ REFACTOR
      league.games.order(end_at: :asc).find { |g| g.snapshots.count < 2 }
    end

    def create_snapshots_from
      first_game_without_snapshots.end_at
    end
  end
end