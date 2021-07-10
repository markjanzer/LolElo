# frozen_string_literal: true

class SnapshotSeeder

  K = 32
  NEW_TEAM_ELO = 1500
  RESET_ELO = 1500
  RATE_OF_REVERSION = 1 / 3.0

  def initialize(league)
    @league = league
  end

  def call
    raise "league not defined" unless league

    ordered_series.reduce(nil) do |previous_serie, serie|
      set_or_revert_elos(serie: serie, previous_serie: previous_serie)
      create_snapshots_from_matches(serie)
      serie
    end
  end

  def remove
    Snapshot.destroy_all
  end

  private

  attr_reader :league

  def set_or_revert_elos(serie:, previous_serie:)
    Serie::SetInitialElos.new(serie: serie, previous_serie: previous_serie).call
  end

  def create_snapshots_from_matches(serie)
    serie.matches.includes(:opponent_1, :opponent_2).order(:end_at).each do |match|
      create_snapshots_for_match(match)
    end
  end

  def create_snapshots_for_match(match)
    match.games.each do |game|
      create_snapshots_for_game(game)
    end
  end

  def create_snapshots_for_game(game)
    Game::CreateSnapshots.new(game).call
  end

  def ordered_series
    league.series.order(:begin_at)
  end

  def previous_serie(index)
    return nil if index.zero?

    ordered_series[index - 1]
  end
end
