# frozen_string_literal: true

class PandaScoreAPI

  GENERAL_PATH = "http://api.pandascore.co/"
  LOL_PATH = "#{GENERAL_PATH}lol/"
  
  def self.league(id:)
    find_by_id(path: LOL_PATH + 'leagues', id: id)
  end

  def self.serie(id:)
    find_by_id(path: LOL_PATH + 'series', id: id)
  end

  def self.tournament(id:)
    find_by_id(path: LOL_PATH + 'tournaments', id: id)
  end

  def self.team(id:)
    find_by_id(path: LOL_PATH + 'teams', id: id)
  end

  def self.match(id:)
    find_by_id(path: LOL_PATH + 'matches', id: id)
  end

  def self.series(league_id:)
    request(path: LOL_PATH + "series", params: { "filter[league_id]": league_id })
  end

  def self.tournaments(serie_id:)
    request(path: LOL_PATH + "tournaments", params: { "filter[serie_id]": serie_id })
  end

  def self.teams(tournament_id:)
    request(path: GENERAL_PATH + "tournaments/#{tournament_id}/teams")
  end

  def self.matches(tournament_id:)
    request(path: LOL_PATH + "matches/past", params: { "filter[tournament_id]": tournament_id })
  end

  def self.games(match_id:)
    match(id: match_id)["games"]
  end

  private

  def self.find_by_id(path:, id:)
    params = { "filter[id]": id }
    response = request(path: path, params: params)
    response.first
  end

  def self.request(path: '', params: {})
    PandaScoreAPI::Request.new(path: path, params: params).call
  end
end
