# frozen_string_literal: true

class PandaScore

  # TODO Refactor these methods. Probably un-abstract then re-abstract everything again.

  GENERAL_PATH = "http://api.pandascore.co/"
  LOL_PATH = "#{GENERAL_PATH}lol/"
  
  def self.league(id:)
    get_data(path: LOL_PATH + 'leagues', id: id)
  end

  def self.serie(id:)
    get_data(path: LOL_PATH + 'series', id: id)
  end

  def self.tournament(id:)
    get_data(path: LOL_PATH + 'tournaments', id: id)
  end

  def self.team(id:)
    get_data(path: LOL_PATH + 'teams', id: id)
  end

  def self.match(id:)
    get_data(path: LOL_PATH + 'matches', id: id)
  end

  def self.series(league_id:)
    request(path: LOL_PATH + "series", params: { "filter[league_id]": league_id })
    # league(id: league_id)["series"]
  end

  def self.tournaments(serie_id:)
    request(path: LOL_PATH + "tournaments", params: { "filter[serie_id]": serie_id })
    # serie(id: serie_id)["tournaments"]
  end

  def self.teams(tournament_id:)
    request(path: GENERAL_PATH + "tournaments/#{tournament_id}/teams")
    # tournament(id: tournament_id)["teams"]
  end

  def self.matches(tournament_id:)
    request(path: LOL_PATH + "matches", params: { "filter[tournament_id]": tournament_id })
    # tournament(id: tournament_id)["matches"]
  end

  def self.games(match_id:)
    # Getting unauthorized error for this request
    # request(path: LOL_PATH + "matches/#{match_id}/games")
    match(id: match_id)["games"]
  end

  # def self.get_data_for(object)
  #   path = object_path(object)
  #   get_data(path: LOL_PATH + path, id: object.panda_score_id)
  # end

  private

  # def self.object_path(object)
  #   object.class.name.downcase.pluralize
  # end

  def self.get_data(path:, id:)
    params = { "filter[id]": id }
    response = request(path: path, params: params)
    response.first
  end

  def self.request(path: '', params: {})
    PandaScore::Request.new(path: path, params: params).call
  end
end
