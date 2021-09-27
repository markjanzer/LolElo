# frozen_string_literal: true

class League
  class CreateSnapshots
    def initialize(league)
      @league = league
    end

    def call
      raise "league not defined" unless league

      ordered_games.each do |game|
        Game::CreateSnapshots.new(game).call
      end
    end

    # This doesn't belong here
    def remove
      Snapshot.destroy_all
    end

    private

    attr_reader :league

    def ordered_games
      league.games.order(end_at: :asc)
      # Game.joins(match: { tournament: { serie: :league }}).where(league: league).order(end_at: :asc)
    end
  end
end