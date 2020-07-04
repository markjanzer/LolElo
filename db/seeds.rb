class SerieCreator
  attr_reader :serie_external_id, :serie

  def initialize(serie_external_id)
    @serie_external_id = serie_external_id
  end

  def call
    create_serie
    create_games
  end

  def create_games
    matches_data.each do |match_data|
      new_match = Match.find_or_initialize_by(external_id: match_data["id"])
      new_match.date = match_data["scheduled_at"]
      new_match.serie_id = serie.id

      teams = []
      match_data["opponents"].each do |opponent|
        team_data = opponent["opponent"]
        team = Team.find_or_create_by(name: team_data["name"], external_id: team_data["id"], acronym: team_data["acronym"])
        if team.color.nil?
          team.update(color: unique_team_color(serie))
        end
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

  def unique_team_color(serie)
    (unique_colors - serie.reload.teams.pluck(:color)).sample
  end

  def unique_colors
    ['#e6194B', '#3cb44b', '#ffe119', '#4363d8', '#f58231', '#911eb4', '#42d4f4', '#f032e6', '#bfef45', '#fabed4', '#469990', '#dcbeff', '#9A6324', '#fffac8', '#800000', '#aaffc3', '#808000', '#ffd8b1', '#000075', '#a9a9a9', '#000000']
  end

  def get_data(path: "", params: {})
    response = HTTParty.get(
      'http://api.pandascore.co' + path, 
      query: params.merge({ "token" => ENV["panda_score_key"] })
    )
    JSON.parse(response.body)
  end

  # def team_colors
  #   {"TSM"=>"#231f20", "C9"=>"#229bd6", "100"=>"#eb3131", "CLG"=>"#00b4e5", "IMT"=>"#00b1a9", "GG"=>"#d3a755", "FLY"=>"#14542b", "DIG"=>"#ffde01", "EG"=>"#3b415d", "TL"=>"#2d4a72"}
  # end

  def serie_data
    @serie_data ||= get_data(path: "/lol/series", params: { "filter[id]": serie_external_id }).first
  end

  def create_serie
    @serie = Serie.find_or_initialize_by(external_id: serie_external_id)
    @serie.year = serie_data["year"]
    @serie.begin_at = serie_data["begin_at"]
    @serie.full_name = serie_data["full_name"]
    @serie.save!
  end

  def matches_data
    @matches_data ||= get_matches_data
  end

  def get_matches_data
    data = []

    page_number = 1
    response = get_data(path: "/lol/matches", params: { "filter[serie_id]": serie_external_id, "page": page_number })
    while !response.empty?
      response.each do |game|
        data << game
      end
      page_number += 1
      response = get_data(path: "/lol/matches", params: { "filter[serie_id]": serie_external_id, "page": page_number})
    end

    data
  end
end

lcs_2019_spring = SerieCreator.new(1705).call
lcs_2019_summer = SerieCreator.new(1795).call
lcs_2020_spring = SerieCreator.new(2347).call
lcs_2020_summer = SerieCreator.new(2372).call


Snapshot.transaction do
  SnapshotCreator.new.call
end



# File.write("./db/lcs_2020_spring_regular_season.json", lcs_spring_2020_game_data.as_json)

# https://medium.com/@ethanryan/split-your-rails-seeds-file-into-separate-files-in-different-folders-3c57be765818