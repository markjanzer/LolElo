# require "./app/services/chart_data.rb"

class ChartData
  def call
    { 
      data: data,
      teams: team_json 
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
      d = { name: date }

      # Play matches
      games = Game.all.select { |g| g.date.strftime("%F") == date }

      games.each do |game|
        # teams_in_game = teams.filter { |t| t[:id] == game.opponent_1_id || t[:id] == game.opponent_2_id }
        opponent_1 = teams.find { |t| t[:id] == game.opponent_1_id }
        opponent_2 = teams.find { |t| t[:id] == game.opponent_2_id }

        opponent_1_win_expectancy = team_1_win_expectancy(opponent_1[:elo], opponent_2[:elo])
        opponent_2_win_expectancy = (1 - opponent_1_win_expectancy) * -1

        if game.winner.id == opponent_1[:id]
          change_in_rating = rating_change(1, opponent_1_win_expectancy)
          opponent_1[:elo] = (opponent_1[:elo] + change_in_rating).to_i
          opponent_2[:elo] = (opponent_2[:elo] - change_in_rating).to_i
        else
          change_in_rating = rating_change(1, opponent_2_win_expectancy)
          opponent_1[:elo] = (opponent_1[:elo] - change_in_rating).to_i
          opponent_2[:elo] = (opponent_2[:elo] + change_in_rating).to_i
        end
      end

      teams.each do |team|
        d[team[:acronym]] = team[:elo]
      end
      result << d
    end

    result
  end

  def team_1_win_expectancy(team_1_elo, team_2_elo)
    return 1 / (10**((team_2_elo - team_1_elo) / 400.to_f) + 1)
  end

  def rating_change(result, expectancy)
    k * (result - expectancy)
  end

  # This is some elo calculation shit
  def k
    32
  end
end