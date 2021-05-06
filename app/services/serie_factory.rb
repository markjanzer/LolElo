# frozen_string_literal: true

class SerieFactory
  def initialize(serie_data:)
    @serie_data = serie_data
  end
  
  def call
    if serie_data.nil?
      raise "serie_data is required"
    end

    initialize_serie
    serie
  end
  
  private
  
  attr_reader :serie_data

  def initialize_serie
    serie.assign_attributes({
      year: serie_data['year'],
      begin_at: serie_data['begin_at'],
      full_name: serie_data['full_name'],
    })
  end

  def serie
    @serie ||= Serie.find_or_initialize_by(external_id: serie_data["id"])
  end

  # def create_tournaments
  #   tournaments_data.each do |tournament_data|
  #     create_tournament(tournament_data)
  #   end
  # end

  # def create_tournament(tournament_data)
  #   TournamentFactory.new(tournament_data: tournament_data, serie: serie).create
  # end

  # def get_data(path: '', params: {})
  #   response = HTTParty.get(
  #     "http://api.pandascore.co#{path}",
  #     query: params.merge({ 'token' => ENV['panda_score_key'] })
  #   )
  #   JSON.parse(response.body)
  # end

  # def tournaments_data
  #   @tournaments_data ||= get_data(path: '/lol/tournaments', params: { "filter[serie_id]": serie_external_id })
  # end

  # def serie_data
  #   @serie_data ||= get_data(path: '/lol/series', params: { "filter[id]": serie_external_id }).first
  # end
end
