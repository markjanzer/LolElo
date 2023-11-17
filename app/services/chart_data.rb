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
      teams: teams_json,
      matches: match_data
    }
  end

  private

  def tournaments
    @tournaments ||= serie.tournaments.where.not(name: FILTERED_MATCH_NAMES)
  end

  def teams_json
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

  # I should probably make his more efficient
  def match_datum(match)
    opponent1 = teams.find { |t| t[:id] == match.opponent1_id }
    opponent2 = teams.find { |t| t[:id] == match.opponent2_id }

    opponent1_initial_elo = match.opponent1.elo_before(match.games.first.end_at)
    opponent2_initial_elo = match.opponent2.elo_before(match.games.first.end_at)

    opponent1_final_elo = match.opponent1.elo_after(match.games.last.end_at)
    opponent2_final_elo = match.opponent2.elo_after(match.games.last.end_at)

    opponent1_elo_change = opponent1_final_elo - opponent1_initial_elo
    opponent2_elo_change = opponent2_final_elo - opponent2_initial_elo

    opponent1_score = match.games.where(winner: opponent1).count
    opponent2_score = match.games.where(winner: opponent2).count

    victor = nil
    if opponent1_score > opponent2_score
      victor = opponent1
    elsif opponent2_score > opponent1_score
      victor = opponent2
    end

    match_hash = {
      date: format_date(match.end_at),
      opponent1: opponent1,
      opponent2: opponent2,
      opponent1_elo: opponent1_initial_elo,
      opponent2_elo: opponent2_initial_elo,
      opponent1_elo_change: opponent1_elo_change,
      opponent2_elo_change: opponent2_elo_change,
      opponent1_score: opponent1_score,
      opponent2_score: opponent2_score,
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
