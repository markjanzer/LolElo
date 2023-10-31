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

    League.find_or_initialize_by(
      panda_score_id: league_data['id'],
      name: league_data['name'],
      time_zone: time_zone
    )
  end

  private

  attr_reader :league_data, :time_zone
end
