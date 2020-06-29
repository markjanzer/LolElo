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
    # teams.map(&:as_json)
    Team.all.map do |team|
      team.as_json
    end
  end

  def dates
    Match.all.order(:date).pluck(:date).map { |d| d.strftime("%F") }.uniq
  end

  def teams
    Team.all
  end

  def data
    # Time zone should be tied to the League
    Time.zone = "US/Pacific"
    result = []
    # teams = Team.all.map do |team|
    #   { acronym: team.acronym, elo: 1500, id: team.id, color: team.color }
    # end
    
    start = { name: "Start of Spring Split" }
    teams.each do |team|
      start[team.acronym] = 1500
    end

    result << start
    
    dates.each do |date|
      date_data = { name: date }

      matches = Match.all.includes(:opponent_1, :opponent_2).select { |g| g.date.strftime("%F") == date }

      matches.each do |match|
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
          date: date,
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
        
        match_data << match_hash
      end


      teams.each do |team|
        date_data[team.acronym] = team.elo_at(Date.parse(date).end_of_day)
      end
      result << date_data
    end

    result
  end
end