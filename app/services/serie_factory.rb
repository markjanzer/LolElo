class SerieFactory
  attr_reader :serie_external_id, :serie

  def initialize(serie_external_id)
    @serie_external_id = serie_external_id
  end

  def call
    create_serie
    # create_teams
    create_tournaments
  end

  def create_serie
    @serie = Serie.find_or_initialize_by(external_id: serie_external_id)
    @serie.league = League.find_by(external_id: serie_data["league_id"])
    @serie.year = serie_data["year"]
    @serie.begin_at = serie_data["begin_at"]
    @serie.full_name = serie_data["full_name"]
    @serie.save!
  end

  # def create_teams
  #   team_data.each do |team_datum|
  #     create_team(team_datum)
  #   end
  # end

  def create_tournaments
    tournaments_data.each do |tournament_data|
      create_tournament(tournament_data)
    end
  end

  # def create_matches
  #   matches_data.each do |match_datum|
  #     create_match(match_datum)
  #   end
  # end

  private

  # def create_match(match_datum)
  #   MatchFactory.new(match_data: match_datum, serie: serie).create
  # end

  def create_tournament(tournament_data)
    TournamentFactory.new(tournament_data: tournament_data, serie: serie).create
  end


  # def team_colors
  #   {"TSM"=>"#231f20", "C9"=>"#229bd6", "100"=>"#eb3131", "CLG"=>"#00b4e5", "IMT"=>"#00b1a9", "GG"=>"#d3a755", "FLY"=>"#14542b", "DIG"=>"#ffde01", "EG"=>"#3b415d", "TL"=>"#2d4a72"}
  # end

  def get_data(path: "", params: {})
    response = HTTParty.get(
      'http://api.pandascore.co' + path, 
      query: params.merge({ "token" => ENV["panda_score_key"] })
    )
    JSON.parse(response.body)
  end

  # def get_matches_data
  #   data = []

  #   page_number = 1
  #   response = get_data(path: "/lol/matches/past", params: { "filter[serie_id]": serie_external_id, "page": page_number })
  #   while !response.empty?
  #     response.each do |game|
  #       data << game
  #     end
  #     page_number += 1
  #     response = get_data(path: "/lol/matches/past", params: { "filter[serie_id]": serie_external_id, "page": page_number})
  #   end

  #   data
  # end

  def tournaments_data
    @tournaments_data ||= get_data(path: "/lol/tournaments", params: { "filter[serie_id]": serie_external_id })
  end

  # def opponents(match_datum)
  #   match_datum["opponents"].map { |o| o["opponent"] }
  # end

  def serie_data
    @serie_data ||= get_data(path: "/lol/series", params: { "filter[id]": serie_external_id }).first
  end

  # def matches_data
  #   @matches_data ||= get_matches_data
  # end

  # def team_data
  #   matches_data.flat_map do |match_datum| 
  #     opponents(match_datum)
  #   end.uniq
  # end
end