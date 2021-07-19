# frozen_string_literal: true

class SerieFactory
  def initialize(serie_data)
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
    @serie ||= Serie.find_or_initialize_by(panda_score_id: serie_data["id"])
  end
end
