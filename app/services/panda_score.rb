# frozen_string_literal: true

class PandaScore

  # TODO Refactor these methods. Probably un-abstract then re-abstract everything again.
  
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
    request(path: "series", params: { "filter[league_id]": league_id })
    # league(id: league_id)["series"]
  end

  def self.tournaments(serie_id:)
    request(path: "tournaments", params: { "filter[serie_id]": serie_id })
    # serie(id: serie_id)["tournaments"]
  end

  def self.teams(tournament_id:)
    request(path: "tournaments/#{tournament_id}/teams")
    # tournament(id: tournament_id)["teams"]

  end

  def self.matches(tournament_id:)
    request(path: "matches", params: { "filter[tournament_id]": tournament_id })
    # tournament(id: tournament_id)["matches"]
  end

  def self.games(match_id:)
    request(path: "games", params: { "filter[match_id]": match_id })
    # match(id: match_id)["games"]
  end

  # def self.get_data_for(object)
  #   path = object_path(object)
  #   get_data(path: path, id: object.panda_score_id)
  # end

  private

  # def self.object_path(object)
  #   object.class.name.downcase.pluralize
  # end

  # def self.get_data(path:, id:)
  #   params = { "filter[id]": id }
  #   response = request(path: path, params: params)
  #   response.first
  # end

  def self.request(path: '', params: {})
    PandaScore::Request.new(path: path, params: params).call
  end
end
