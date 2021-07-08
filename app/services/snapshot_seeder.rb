# frozen_string_literal: true

class SnapshotSeeder

  K = 32
  NEW_TEAM_ELO = 1500
  RESET_ELO = 1500
  RATE_OF_REVERSION = 1 / 3.0

  attr_reader :league

  def initialize(league)
    @league = league
  end

  def call
    raise "league not defined" unless league

    ordered_series.each_with_index do |serie, index|
      if index.zero?
        serie.teams.each do |team|
          Snapshot.create!(team: team, elo: NEW_TEAM_ELO, date: serie.begin_at)
        end
      else
        serie.teams.each do |team|
          if previous_serie(index).teams.include?(team)
            if previous_serie(index).year != serie.year
              Snapshot.create!(team: team, elo: revert(team.elo), date: first_of_year(serie.year))
            end
          else
            Snapshot.create!(team: team, elo: NEW_TEAM_ELO, date: serie.begin_at)
          end
        end
      end

      serie.matches.includes(:opponent_1, :opponent_2).order(:end_at).each do |match|
        create_snapshots_for_match(match)
      end
    end
  end

  def remove
    Snapshot.destroy_all
  end

  private

  def create_snapshots_for_match(match)
    match.games.each do |game|
      create_snapshots_for_game(game)
    end
  end

  def create_snapshots_for_game(game)
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

  def ordered_series
    league.series.order(:begin_at)
  end

  def previous_serie(index)
    return nil if index.zero?

    ordered_series[index - 1]
  end

  def first_of_year(year)
    Date.new(year, 1, 1)
  end

  def revert(elo)
    elo - ((elo - RESET_ELO) * RATE_OF_REVERSION)
  end

  def win_expectancy(primary_elo, other_elo)
    1 / (10**((other_elo - primary_elo) / 400.to_f) + 1)
  end

  def rating_change(expectancy)
    K * (1 - expectancy)
  end
end
