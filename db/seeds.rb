# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# class CreateGames
#   include HTTParty
#   base_uri 'api.pandascore.co'

#   # def call
#   #   self.class.get
#   # end
# end


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


# File.write("./db/lcs_2020_spring_regular_season.json", lcs_spring_2020_game_data.as_json)

# https://medium.com/@ethanryan/split-your-rails-seeds-file-into-separate-files-in-different-folders-3c57be765818