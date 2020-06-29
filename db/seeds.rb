class LeagueCreator
  attr_reader :league_data

  def initialize(league_id)
    @league_data = get_league_data(league_id)
  end

  def create_games
    league_data.each do |match_data|
      new_match = Match.find_or_initialize_by(external_id: match_data["id"])
      new_match.date = match_data["scheduled_at"]

      teams = []
      match_data["opponents"].each do |opponent|
        team_data = opponent["opponent"]
        team = Team.find_or_create_by(name: team_data["name"], external_id: team_data["id"], acronym: team_data["acronym"], color: team_colors[team_data["acronym"]])
        teams << team
      end
      new_match.opponent_1 = teams.first
      new_match.opponent_2 = teams.second

      new_match.save!
    
      match_data["games"].each do |game|
        new_game = Game.find_or_initialize_by(external_id: game["id"])
        new_game.match = new_match
        new_game.end_at = game["end_at"]
        new_game.winner = Team.find_by(external_id: game["winner"]["id"])
        new_game.save!
      end
    end
  end

  private

  def get_data(path: "", params: {})
    response = HTTParty.get(
      'http://api.pandascore.co' + path, 
      query: params.merge({ "token" => ENV["panda_score_key"] })
    )
    JSON.parse(response.body)
  end

  def team_colors
    {"TSM"=>"#231f20", "C9"=>"#229bd6", "100"=>"#eb3131", "CLG"=>"#00b4e5", "IMT"=>"#00b1a9", "GG"=>"#d3a755", "FLY"=>"#14542b", "DIG"=>"#ffde01", "EG"=>"#3b415d", "TL"=>"#2d4a72"}
  end

  def get_league_data(league_id)
    data = []

    page_number = 1
    response = get_data(path: "/lol/matches", params: { "filter[serie_id]": league_id, "page": page_number })
    while !response.empty?
      response.each do |game|
        data << game
      end
      page_number += 1
      response = get_data(path: "/lol/matches", params: { "filter[serie_id]": league_id, "page": page_number})
    end

    data
  end
end

lcs_2020_spring = LeagueCreator.new(2347).create_games



class SnapshotCreator
  def call
    Team.all.each do |team|
      Snapshot.create(team: team, elo: 1500, date: "2020-01-01")
    end

    Match.order(:date).each do |match|
      opponent_1 = match.opponent_1
      opponent_2 = match.opponent_2
      
      match.games.each do |game|
        if game.winner == opponent_1
          opponent_1_win_expectancy = team_1_win_expectancy(opponent_1.elo, opponent_2.elo)
          change_in_rating = rating_change(opponent_1_win_expectancy).round
          Snapshot.create(
            team: opponent_1,
            game: game,
            # I want to change this to end_at
            date: game.end_at,
            elo: opponent_1.elo + change_in_rating
          )
          Snapshot.create(
            team: opponent_2,
            game: game,
            # I want to change this to end_at
            date: game.end_at,
            elo: opponent_2.elo - change_in_rating
          )
        elsif game.winner == opponent_2
          opponent_2_win_expectancy = team_1_win_expectancy(opponent_2.elo, opponent_1.elo)
          change_in_rating = rating_change(opponent_2_win_expectancy).round
          Snapshot.create(
            team: opponent_1,
            game: game,
            # I want to change this to end_at
            date: game.end_at,
            elo: opponent_1.elo - change_in_rating
          )
          Snapshot.create(
            team: opponent_2,
            game: game,
            # I want to change this to end_at
            date: game.end_at,
            elo: opponent_2.elo + change_in_rating
          )
        end
      end
    end
  end


  private


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

Snapshot.transaction do
  SnapshotCreator.new.call
end



# File.write("./db/lcs_2020_spring_regular_season.json", lcs_spring_2020_game_data.as_json)

# https://medium.com/@ethanryan/split-your-rails-seeds-file-into-separate-files-in-different-folders-3c57be765818