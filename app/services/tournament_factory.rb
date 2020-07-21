class TournamentFactory
  attr_reader :serie, :tournament_data, :tournament
  
  def initialize(serie:, tournament_data:)
    @serie = serie
    @tournament_data = tournament_data
  end

  def create
    create_tournament
    create_teams
    create_matches
  end

  private

  def create_tournament
    @tournament = Tournament.find_or_initialize_by(external_id: tournament_data["id"])
    @tournament.serie = serie
    @tournament.name = tournament_data["name"]
    @tournament.save!
  end

  def create_matches
    matches_data.each do |match_datum|
      create_match(match_datum)
    end
  end

  def create_match(match_datum)
    MatchFactory.new(match_data: match_datum, tournament: tournament).create
  end

  def matches_data
    @matches_data ||= get_matches_data
  end

  def get_matches_data
    data = []

    page_number = 1
    response = get_data(path: "/lol/matches/past", params: { "filter[tournament_id]": tournament.external_id, "page": page_number })
    while !response.empty?
      response.each do |game|
        data << game
      end
      page_number += 1
      response = get_data(path: "/lol/matches/past", params: { "filter[tournament_id]": tournament.external_id, "page": page_number})
    end

    data
  end

  def get_data(path: "", params: {})
    response = HTTParty.get(
      'http://api.pandascore.co' + path, 
      query: params.merge({ "token" => ENV["panda_score_key"] })
    )
    JSON.parse(response.body)
  end

  def create_teams
    teams_data.each do |team_data|
      create_team(team_data)
    end
  end

  def create_team(team_data)
    team = Team.find_or_create_by(name: team_data["name"], external_id: team_data["id"], acronym: team_data["acronym"])
    team.tournaments << tournament
    if team.color.nil?
      team.update!(color: unique_team_color)
    end
  end

  def unique_team_color
    (unique_colors - serie.teams.pluck(:color)).sample
  end

  def unique_colors
    ['#e6194B', '#3cb44b', '#ffe119', '#4363d8', '#f58231', '#911eb4', '#42d4f4', '#f032e6', '#bfef45', '#fabed4', '#469990', '#dcbeff', '#9A6324', '#fffac8', '#800000', '#aaffc3', '#808000', '#ffd8b1', '#000075', '#a9a9a9', '#000000']
  end

  def teams_data
    matches_data.flat_map do |match_data| 
      opponents(match_data)
    end.uniq
  end

  def opponents(match_data)
    match_data["opponents"].map { |o| o["opponent"] }
  end
end


# def team_colors
#   {"TSM"=>"#231f20", "C9"=>"#229bd6", "100"=>"#eb3131", "CLG"=>"#00b4e5", "IMT"=>"#00b1a9", "GG"=>"#d3a755", "FLY"=>"#14542b", "DIG"=>"#ffde01", "EG"=>"#3b415d", "TL"=>"#2d4a72"}
# end