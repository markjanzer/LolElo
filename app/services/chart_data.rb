# require "./app/services/chart_data.rb"

class ChartData
  attr_accessor :match_data
  
  def initialize
    @match_data = []
  end
  
  def call
    { 
      data: data,
      teams: team_json,
      matches: match_data,
    }
  end

  private

  def team_json
    Team.all.map do |team|
      team.as_json
    end
  end

  def dates
    Match.all.order(:date).pluck(:date).map { |d| d.strftime("%F") }.uniq
  end

  def data
    Time.zone = "US/Pacific"
    result = []
    teams = Team.all.map do |team|
      { acronym: team.acronym, elo: 1500, id: team.id, color: team.color }
    end
    
    start = { name: "Start of Spring Split" }
    teams.each do |team|
      start[team[:acronym]] = team[:elo]
    end

    result << start
    
    dates.each do |date|
      date_data = { name: date }

      matches = Match.all.includes(:opponent_1, :opponent_2).select { |g| g.date.strftime("%F") == date }

      matches.each do |match|
        opponent_1 = teams.find { |t| t[:id] == match.opponent_1_id }
        opponent_2 = teams.find { |t| t[:id] == match.opponent_2_id }

        match_opponent_1 = opponent_1.clone
        match_opponent_1[:score] = 0
        match_opponent_1[:elo_change] = 0
        match_opponent_2 = opponent_2.clone
        match_opponent_2[:score] = 0
        match_opponent_2[:elo_change] = 0

        match_hash = {
          date: date,
          opponent_2: match_opponent_2,
          opponent_1: match_opponent_1,
          victor: nil,
        }
        
        match.games.order(:begin_at).each do |game|
          opponent_1_win_expectancy = team_1_win_expectancy(opponent_1[:elo], opponent_2[:elo])
          opponent_2_win_expectancy = team_1_win_expectancy(opponent_2[:elo], opponent_1[:elo])

          if game.winner.id == opponent_1[:id]
            change_in_rating = rating_change(opponent_1_win_expectancy).round
            match_hash[:opponent_1][:elo_change] += change_in_rating
            match_hash[:opponent_2][:elo_change] -= change_in_rating
            opponent_1[:elo] += change_in_rating
            opponent_2[:elo] -= change_in_rating
            match_hash[:opponent_1][:score] += 1
          else
            change_in_rating = rating_change(opponent_2_win_expectancy).round
            match_hash[:opponent_1][:elo_change] -= change_in_rating
            match_hash[:opponent_2][:elo_change] += change_in_rating
            opponent_1[:elo] -= change_in_rating
            opponent_2[:elo] += change_in_rating
            match_hash[:opponent_2][:score] += 1
          end

        end

        if match_opponent_1[:score] > match_opponent_2[:score]
          match_hash[:victor] = 1
        elsif match_opponent_2[:score] > match_opponent_1[:score]
          match_hash[:victor] = 2
        else
          byebug
        end

        opponent_1[:elo] += match[:opponent_1_elo_change].to_i
        opponent_2[:elo] += match[:opponent_2_elo_change].to_i
        
        match_data << match_hash
      end


      teams.each do |team|
        date_data[team[:acronym]] = team[:elo]
      end
      result << date_data
    end

    result
  end

  def team_1_win_expectancy(team_1_elo, team_2_elo)
    return 1 / (10**((team_2_elo - team_1_elo) / 400.to_f) + 1)
  end

  def rating_change(expectancy)
    k * (1 - expectancy)
  end

  # This is some elo calculation shit
  def k
    32
  end
end