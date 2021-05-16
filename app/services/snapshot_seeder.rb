# frozen_string_literal: true

class SnapshotSeeder

  K = 32
  NEW_TEAM_ELO = 1500
  RESET_ELO = 1500
  # This should be 1 / 3, or something like that correct?
  RATE_OF_REVERSION = 3

  attr_reader :league

  def initialize(league)
    @league = league
  end

  def call
    ordered_series.each_with_index do |serie, index|
      if index.zero?
        serie.teams.each do |team|
          Snapshot.create!(team: team, elo: NEW_TEAM_ELO, date: serie.begin_at)
        end
      else
        serie.teams.each do |team|
          if previous_serie(index).teams.include?(team)
            if previous_serie(index).year != serie.year
              Snapshot.create!(team: team, elo: reset(team.elo), date: first_of_year(serie.year))
            end
          else
            Snapshot.create!(team: team, elo: NEW_TEAM_ELO, date: serie.begin_at)
          end
        end
      end

      serie.matches.includes(:opponent_1, :opponent_2).order(:end_at).each do |match|
        opponent_1 = match.opponent_1
        opponent_2 = match.opponent_2

        match.games.each do |game|
          if game.winner == opponent_1
            opponent_1_win_expectancy = team_1_win_expectancy(opponent_1.elo, opponent_2.elo)
            change_in_rating = rating_change(opponent_1_win_expectancy).round
            Snapshot.create!(
              team: opponent_1,
              game: game,
              date: game.end_at,
              elo: opponent_1.elo + change_in_rating
            )
            Snapshot.create!(
              team: opponent_2,
              game: game,
              date: game.end_at,
              elo: opponent_2.elo - change_in_rating
            )
          elsif game.winner == opponent_2
            opponent_2_win_expectancy = team_1_win_expectancy(opponent_2.elo, opponent_1.elo)
            change_in_rating = rating_change(opponent_2_win_expectancy).round
            Snapshot.create!(
              team: opponent_1,
              game: game,
              date: game.end_at,
              elo: opponent_1.elo - change_in_rating
            )
            Snapshot.create!(
              team: opponent_2,
              game: game,
              date: game.end_at,
              elo: opponent_2.elo + change_in_rating
            )
          end
        end
      end
    end
  end

  def remove
    Snapshot.destroy_all
  end

  private

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

  def reset(elo)
    elo - ((elo - RESET_ELO) / RATE_OF_REVERSION)
  end

  def team_1_win_expectancy(team_1_elo, team_2_elo)
    1 / (10**((team_2_elo - team_1_elo) / 400.to_f) + 1)
  end

  def rating_change(expectancy)
    K * (1 - expectancy)
  end
end
