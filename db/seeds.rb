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


def get_data(path: "", params: {})
  response = HTTParty.get(
    'http://api.pandascore.co' + path, 
    query: params.merge({ "token" => ENV["panda_score_key"] })
  )
  JSON.parse(response.body)
end

lcs_spring_2020_id = 2347
lcs_spring_2020_game_data = []
# game_ids = []
page_number = 1
response = get_data(path: "/lol/matches", params: { "filter[serie_id]": 2347, "page": page_number })
while !response.empty?
  response.each do |game|
    lcs_spring_2020_game_data << game
  end
  page_number += 1
  response = get_data(path: "/lol/matches", params: { "filter[serie_id]": 2347, "page": page_number})
end

matches = lcs_spring_2020_game_data

matches.each do |match|
  teams = []
  match["opponents"].each do |opponent|
    teams << Team.find_or_create_by(name: opponent["opponent"]["name"], external_id: opponent["opponent"]["id"])
  end

  match["games"].each do |game|
    new_game = Game.find_or_create_by(external_id: game["id"])
    # This isn't getting the right date
    new_game.date = game["begin_at"]
    new_game.opponent_1 = teams.first
    new_game.opponent_2 = teams.second
    new_game.winner = Team.find_by(external_id: game["winner"]["id"])
    new_game.save!
  end
end

# File.write("./db/lcs_2020_spring_regular_season.json", lcs_spring_2020_game_data.as_json)

