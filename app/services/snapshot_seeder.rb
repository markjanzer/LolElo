# frozen_string_literal: true

class SnapshotSeeder
  def initialize(league)
    @league = league
  end

  def call
    raise "league not defined" unless league

    ordered_series.each do |serie|
      Serie::SetInitialElos.new(serie).call
      create_snapshots_from_matches(serie)
    end
  end

  def remove
    Snapshot.destroy_all
  end

  private

  attr_reader :league

  def create_snapshots_from_matches(serie)
    serie.matches.includes(:opponent_1, :opponent_2).order(:end_at).each do |match|
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
