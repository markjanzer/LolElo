class SerieFactory
  attr_reader :serie_external_id, :serie

  def initialize(serie_external_id)
    @serie_external_id = serie_external_id
  end

  def call
    create_serie
    create_teams
    create_games
  end

  def create_serie
    @serie = Serie.find_or_initialize_by(external_id: serie_external_id)
    @serie.league = League.find_by(external_id: serie_data["league_id"])
    @serie.year = serie_data["year"]
    @serie.begin_at = serie_data["begin_at"]
    @serie.full_name = serie_data["full_name"]
    @serie.save!
  end

  def create_teams
    team_data.each do |team_datum|
      team = Team.find_or_create_by(name: team_datum["name"], external_id: team_datum["id"], acronym: team_datum["acronym"])
      team.series << serie
      if team.color.nil?
        team.update!(color: unique_team_color)
      end
    end
  end

  def create_games
    matches_data.each do |match_datum|
      new_match = Match.find_or_initialize_by(external_id: match_datum["id"])
      new_match.end_at = match_datum["end_at"]
      new_match.serie_id = serie.id

      new_match.opponent_1 = serie.teams.find_by(external_id: opponents(match_datum).first["id"])
      new_match.opponent_2 = serie.teams.find_by(external_id: opponents(match_datum).second["id"])

      new_match.save!
    
      match_datum["games"].each do |game|
        new_game = Game.find_or_initialize_by(external_id: game["id"])
        new_game.match = new_match
        new_game.end_at = game["end_at"]
        new_game.winner = Team.find_by(external_id: game["winner"]["id"])
        new_game.save!
      end
    end
  end

  private

  def unique_team_color
    (unique_colors - serie.teams.pluck(:color)).sample
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

  def matches_data
    @matches_data ||= get_matches_data
  end

  def team_data
    matches_data.flat_map do |match_datum| 
      opponents(match_datum)
    end.uniq
  end

  def opponents(match_datum)
    match_datum["opponents"].map { |o| o["opponent"] }
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