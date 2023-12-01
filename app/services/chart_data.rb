# frozen_string_literal: true

class ChartData
  def initialize(serie)
    @serie = serie

    @snapshots = serie.snapshots
    serie.teams.each do |team|
      @snapshots << team.snapshots.where("datetime < ?", serie.begin_at).order(datetime: :desc).first
    end
  end

  def call
    {
      data: elos_at_dates,
      teams: teams_json,
      matches: matches_data
    }
  end

  private

  attr_reader :serie

  delegate :tournaments, to: :serie

  def teams_json
    teams.map(&:as_json)
  end

  def format_date(date)
    date.strftime('%b %-d')
  end

  def teams
    serie.teams
  end

  def ordered_past_matches
    serie.matches.with_games.order(end_at: :asc)
  end

  def matches_data
    ordered_past_matches.includes(:games, :opponent1, :opponent2).map do |match|
      match_data(match)
    end
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

  def unique_dates
    ordered_past_matches.pluck(:end_at).map(&:to_date).uniq
  end

  def match_data(match)
    games = match.games.order(end_at: :asc)
    opponent1 = match.opponent1
    opponent2 = match.opponent2
    first_game_end_at = games.first.end_at
    last_game_end_at = games.last.end_at

    opponent1_initial_elo = opponent1.elo_before(first_game_end_at)
    opponent2_initial_elo = opponent2.elo_before(first_game_end_at)

    opponent1_final_elo = opponent1.elo_after(last_game_end_at)
    opponent2_final_elo = opponent2.elo_after(last_game_end_at)

    opponent1_elo_change = opponent1_final_elo - opponent1_initial_elo
    opponent2_elo_change = opponent2_final_elo - opponent2_initial_elo

    opponent1_score = games.where(winner: opponent1).count
    opponent2_score = games.where(winner: opponent2).count

    victor = opponent1_score > opponent2_score ? opponent1 : opponent2

    {
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
end
