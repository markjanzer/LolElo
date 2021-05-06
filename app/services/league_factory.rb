# frozen_string_literal: true

class LeagueFactory
  def initialize(league_data:, time_zone:)
    @league_data = league_data
    @time_zone = time_zone
  end

  def call
    if league_data.nil?
      raise 'league_data is required'
    end

    if time_zone.nil?
      raise 'time_zone is required'
    end

    initialize_league
  end

  private

  attr_reader :league_data, :time_zone

  def initialize_league
    League.find_or_initialize_by(
      external_id: league_data['id'],
      name: league_data['name'],
      time_zone: time_zone
    )
  end

  # def create_series
  #   filtered_series_ids.each do |series_id|
  #     SerieFactory.new(series_id).call
  #   end
  # end

  # def filtered_series
  #   league_data['series'].filter do |series|
  #     series['full_name'].split.first.match?('Spring|Summer')
  #   end
  # end

  # def filtered_series_ids
  #   filtered_series.pluck('id')
  # end
end
