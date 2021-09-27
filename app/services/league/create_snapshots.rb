# frozen_string_literal: true

class League
  class CreateSnapshots
    def initialize(league)
      @league = league
    end

    def call
      raise "league not defined" unless league

      # ordered_games.each do |game|
      #   Game::CreateSnapshots.new(game).call
      # end

      ordered_series.each do |serie|
        set_initial_elo_for_teams(serie)
        create_snapshots_from_matches(serie)
      end
    end

    # This doesn't belong here
    def remove
      Snapshot.destroy_all
    end

    private

    attr_reader :league

    def set_initial_elo_for_teams(serie)
      serie.teams.each do |team|
        Team::SetInitialEloForSerie.new(team: team, serie: serie).call
      end
    end

    def create_snapshots_from_matches(serie)
      serie.matches.includes(:opponent1, :opponent2).order(:end_at).each do |match|
        create_snapshots_for_match(match)
      end
    end

    def create_snapshots_for_match(match)
      match.games.order(:end_at).each do |game|
        create_snapshots_for_game(game)
      end
    end

    def create_snapshots_for_game(game)
      Game::CreateSnapshots.new(game).call
    end

    def ordered_series
      league.series.order(:begin_at)
    end
  end
end