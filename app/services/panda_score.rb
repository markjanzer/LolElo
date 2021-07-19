# frozen_string_literal: true

class PandaScore

  def self.league(id:)
    get_data(path: 'leagues', id: id)
  end

  def self.serie(id:)
    get_data(path: 'series', id: id)
  end

  def self.tournament(id:)
    get_data(path: 'tournaments', id: id)
  end

  def self.match(id:)
    get_data(path: 'matches', id: id)
  end

  def self.series(league_id:)
    league(id: league_id)["series"]
  end

  def self.tournaments(serie_id:)
    serie(id: serie_id)["tournaments"]
  end

  def self.teams(tournament_id:)
    tournament(id: tournament_id)["teams"]
  end

  def self.matches(tournament_id:)
    tournament(id: tournament_id)["matches"]
  end

  def self.games(match_id:)
    match(id: match_id)["games"]
  end

  def self.get_data_for(object)
    path = object_path(object)
    get_data(path: path, id: object.panda_score_id)
  end

  private

  def self.object_path(object)
    object.class.name.downcase.pluralize
  end

  def self.get_data(path:, id:)
    params = { "filter[id]": id }
    response = request(path: path, params: params)
    response.first
  end

  def self.request(path: '', params: {})
    response = HTTParty.get(
      "http://api.pandascore.co/lol/#{path}",
      query: params.merge({ 'token' => ENV['panda_score_key'] })
    )
    JSON.parse(response.body)
  end
end
