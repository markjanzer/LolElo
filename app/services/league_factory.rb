# frozen_string_literal: true

class LeagueFactory
  def initialize(league_id:, time_zone:)
    @league_id = league_id
    @time_zone = time_zone
  end

  def call
    create_league
    create_series
  end

  private

  attr_reader :league_id, :time_zone

  def league_data
    @league_data ||= PandaScore.league_data(league_id)
  end

  def league
    @league ||= League.find_or_initialize_by(external_id: league_id)
  end

  def create_league
    league.name = league_data['name']
    league.time_zone = time_zone
    league.save!
  end

  def create_series
    filtered_series_ids.each do |series_id|
      SerieFactory.new(series_id).call
    end
  end

  def filtered_series
    league_data['series'].filter do |series|
      series['full_name'].split.first.match?('Spring|Summer')
    end
  end

  def filtered_series_ids
    filtered_series.pluck('id')
  end
end
