# require "./app/services/chart_data.rb"

class ChartData
  attr_accessor :game_data
  
  def initialize
    @game_data = []
  end
  
  def call
    { 
      data: data,
      teams: team_json,
      games: game_data,
    }
  end

  private

  def team_json
    Team.all.map do |team|
      team.as_json
    end
  end

  def dates
    Game.all.order(:date).pluck(:date).map { |d| d.strftime("%F") }.uniq
  end

  # def teams
  #   Team.all
  # end

  def data
    Time.zone = "US/Pacific"
    result = []
    teams = Team.all.map do |team|
      { acronym: team.acronym, elo: 1500, id: team.id }
    end
    
    start = { name: "Start of Spring Split" }
    teams.each do |team|
      start[team[:acronym]] = team[:elo]
    end

    result << start
    
    dates.each do |date|
      date_data = { name: date }

      # Play matches
      games = Game.all.includes(:opponent_1, :opponent_2).select { |g| g.date.strftime("%F") == date }

      games.each do |game|
        opponent_1 = teams.find { |t| t[:id] == game.opponent_1_id }
        opponent_2 = teams.find { |t| t[:id] == game.opponent_2_id }

        opponent_1_win_expectancy = team_1_win_expectancy(opponent_1[:elo], opponent_2[:elo])
        opponent_2_win_expectancy = (1 - opponent_1_win_expectancy).abs

        if game.winner.id == opponent_1[:id]
          victor = 1
          change_in_rating = rating_change(opponent_1_win_expectancy).round
          opponent_1_elo_change = change_in_rating
          opponent_2_elo_change = change_in_rating * -1
        else
          victor = 2
          change_in_rating = rating_change(opponent_2_win_expectancy).round
          opponent_1_elo_change = change_in_rating * -1
          opponent_2_elo_change = change_in_rating
        end

        game_data << {
          opponent_1: opponent_1[:acronym],
          opponent_1_elo: opponent_1[:elo],
          opponent_1_elo_change: opponent_1_elo_change,
          opponent_2: opponent_2[:acronym],
          opponent_2_elo: opponent_2[:elo],
          opponent_2_elo_change: opponent_2_elo_change,
          victor: victor,
          date: date
        }

        opponent_1[:elo] = (opponent_1[:elo] + opponent_1_elo_change).to_i
        opponent_2[:elo] = (opponent_2[:elo] + opponent_2_elo_change).to_i
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