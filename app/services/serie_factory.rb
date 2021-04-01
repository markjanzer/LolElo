# frozen_string_literal: true

class SerieFactory
  attr_reader :serie_external_id, :serie

  def initialize(serie_external_id)
    @serie_external_id = serie_external_id
  end

  def call
    create_serie
    create_tournaments
  end

  private

  def create_serie
    @serie = Serie.find_or_initialize_by(external_id: serie_external_id)
    @serie.league = League.find_by(external_id: serie_data['league_id'])
    @serie.year = serie_data['year']
    @serie.begin_at = serie_data['begin_at']
    @serie.full_name = serie_data['full_name']
    @serie.save!
  end

  def create_tournaments
    tournaments_data.each do |tournament_data|
      create_tournament(tournament_data)
    end
  end

  def create_tournament(tournament_data)
    TournamentFactory.new(tournament_data: tournament_data, serie: serie).create
  end

  def get_data(path: '', params: {})
    response = HTTParty.get(
      "http://api.pandascore.co#{path}",
      query: params.merge({ 'token' => ENV['panda_score_key'] })
    )
    JSON.parse(response.body)
  end

  def tournaments_data
    @tournaments_data ||= get_data(path: '/lol/tournaments', params: { "filter[serie_id]": serie_external_id })
  end

  def serie_data
    @serie_data ||= get_data(path: '/lol/series', params: { "filter[id]": serie_external_id }).first
  end
end
