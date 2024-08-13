# frozen_string_literal: true

class ChartData
  def initialize(serie)
    @serie = serie
    @snapshots = serie.snapshots | serie.initial_snapshots
  end

  def call
    if matches_data.empty?
      Rails.logger.warn "No matches found for serie #{serie.id}"
    end
    
    {
      data: elos_at_dates,
      teams: teams_json,
      matches: matches_data
    }
  end

  private

  attr_reader :serie, :snapshots

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
      start[team.acronym] = elo_before(team: team, datetime: serie.earliest_game_end)
    end

    result << start

    unique_dates.each do |date|
      date_data = { name: format_date(date) }
      
      teams.each do |team|
        date_data[team.acronym] = elo_at(team: team, datetime: date.end_of_day)
      end
      result << date_data
    end

    result
  end

  def unique_dates
    ordered_past_matches.pluck(:end_at).map(&:to_date).uniq
  end

  def match_data(match)
    games = match.games
    opponent1 = match.opponent1
    opponent2 = match.opponent2
    first_game_end_at = games.pluck(:end_at).min
    last_game_end_at =  games.pluck(:end_at).max

    opponent1_initial_elo = elo_before(team: opponent1, datetime: first_game_end_at)
    opponent2_initial_elo = elo_before(team: opponent2, datetime: first_game_end_at)

    # I could do last_game.snapshots here instead of a query
    opponent1_final_elo = elo_after(team: opponent1, datetime: last_game_end_at)
    opponent2_final_elo = elo_after(team: opponent2, datetime: last_game_end_at)

    opponent1_elo_change = opponent1_final_elo - opponent1_initial_elo
    opponent2_elo_change = opponent2_final_elo - opponent2_initial_elo

    opponent1_score = 0
    opponent2_score = 0
    games.each do |game| 
      game.winner_id == opponent1.id ? opponent1_score += 1 : opponent2_score += 1
    end

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

  def elo_at(team:, datetime:)
    _elo_at(snapshots: @snapshots, team: team, datetime: datetime, comparison: :at)
  end
  
  def elo_before(team:, datetime:)
    _elo_at(snapshots: @snapshots, team: team, datetime: datetime, comparison: :before)
  end
  
  def elo_after(team:, datetime:)
    _elo_at(snapshots: @snapshots, team: team, datetime: datetime, comparison: :after)
  end

  def _elo_at(snapshots:, team:, datetime:, comparison:)
    raise "datetime is required" if datetime.nil?

    closest_snapshot = case comparison
      when :at
        snapshots.select { |snapshot| snapshot.team_id == team.id && snapshot.datetime <= datetime }
          .sort_by(&:datetime)
          .last
      when :before
        snapshots.select { |snapshot| snapshot.team_id == team.id && snapshot.datetime < datetime }
          .sort_by(&:datetime)
          .last
      when :after
        snapshots.select { |snapshot| snapshot.team_id == team.id && snapshot.datetime >= datetime }
          .sort_by(&:datetime)
          .first
      else
        raise "comparison must be one of :at, :before, :after"
    end

    if closest_snapshot.nil?
      raise "No snapshot for team (id: #{team.id}) exists #{comparison.to_s} #{datetime}"
    end

    closest_snapshot.elo
  end
end
