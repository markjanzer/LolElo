# frozen_string_literal: true

# require "./app/services/chart_data.rb"

class ChartData
  attr_accessor :serie

  # Shouldn't we not be creating these matches?
  FILTERED_MATCH_NAMES = ['Promotion', 'Promotion relegation'].freeze

  def initialize(serie)
    @serie = serie
  end

  def call
    {
      data: elos_at_dates,
      teams: team_json,
      matches: match_data
    }
  end

  private

  def tournaments
    @tournaments ||= serie.tournaments.where.not(name: FILTERED_MATCH_NAMES)
  end

  def team_json
    teams.map(&:as_json)
  end

  def unique_dates
    past_matches.sort_by(&:end_at).map { |m| m.end_at.to_date }.uniq
  end

  def format_date(date)
    date.strftime('%b %-d')
  end

  def teams
    tournaments.flat_map(&:teams).uniq
  end

  def past_matches
    # Match.where(tournament: tournaments).where("end_at < ?", Time.now)
    Match.where(tournament: tournaments).select { |match| match.games.present? }
  end

  def match_data
    past_matches.sort_by(&:end_at).map do |match|
      match_datum(match)
    end
  end

  def match_datum(match)
    opponent_1 = teams.find { |t| t[:id] == match.opponent_1_id }
    opponent_2 = teams.find { |t| t[:id] == match.opponent_2_id }

    opponent_1_initial_elo = match.opponent_1.elo_before(match.games.first.end_at)
    opponent_2_initial_elo = match.opponent_2.elo_before(match.games.first.end_at)

    opponent_1_final_elo = match.opponent_1.elo_after(match.games.last.end_at)
    opponent_2_final_elo = match.opponent_2.elo_after(match.games.last.end_at)

    opponent_1_elo_change = opponent_1_final_elo - opponent_1_initial_elo
    opponent_2_elo_change = opponent_2_final_elo - opponent_2_initial_elo

    opponent_1_score = match.games.where(winner: opponent_1).count
    opponent_2_score = match.games.where(winner: opponent_2).count

    victor = nil
    if opponent_1_score > opponent_2_score
      victor = opponent_1
    elsif opponent_2_score > opponent_1_score
      victor = opponent_2
    end

    match_hash = {
      date: format_date(match.end_at),
      opponent_1: opponent_1,
      opponent_2: opponent_2,
      opponent_1_elo: opponent_1_initial_elo,
      opponent_2_elo: opponent_2_initial_elo,
      opponent_1_elo_change: opponent_1_elo_change,
      opponent_2_elo_change: opponent_2_elo_change,
      opponent_1_score: opponent_1_score,
      opponent_2_score: opponent_2_score,
      victor: victor
    }
  end

  def elos_at_dates
    # Time zone should be tied to the League
    Time.zone = serie.league.time_zone
    result = []

    start = { name: "Start of #{serie.full_name}" }

    teams.each do |team|
      start[team.acronym] = team.elo_at(serie.begin_at)
    end

    result << start

    unique_dates.each do |date|
      date_data = { name: format_date(date) }

      teams.each do |team|
        date_data[team.acronym] = team.elo_at(date.end_of_day)
      end
      result << date_data
    end

    result
  end
end
