# This updater looks at PandaScore models that are not complete and then updates them 
# and their children.

# This will have to be paired with a service that updates the native models from the PandaScore models.
# How will I deal with PandaScore objects that haven't been created?
# Also how will this work if the API gets too many calls?

class Updater
  BUFFER = 1.hour

  def initialize(time_to_update_from=nil)
    @time_to_update_from = time_to_update_from || self.class.time_to_compare_against
  end

  attr_reader :time_to_update_from

  def self.call
    new(time_to_compare_against).call
  end

  def self.time_to_compare_against
    UpdateTracker.last_api_update - BUFFER
  end

  def call
    PandaScore::League.transaction do
      PandaScore::League.all.each do |ps_league|
        ps_league.update_from_api
        ps_league.create_series
      end

      unfinished_series.each do |ps_serie|
        ps_serie.update_from_api
        ps_serie.create_tournaments
      end

      unfinished_tournaments.each do |ps_tournament|
        ps_tournament.update_from_api
        ps_tournament.create_matches
      end

      unfinished_matches.each do |ps_match|
        ps_match.update_from_api
        ps_match.create_or_update_games
      end

      UpdateTracker.record_api_update
    end
  end

  def unfinished_series
    PandaScore::Serie
      .where("(data ->> 'end_at')::timestamp >= ?", time_to_update_from)
  end

  def unfinished_tournaments
    PandaScore::Tournament
      .where("(data ->> 'end_at')::timestamp >= ?", time_to_update_from)
  end

  def unfinished_matches
    PandaScore::Match
      .where("data ->> 'end_at' IS NULL")
      .where("data ->> 'status' = 'running' 
        OR data ->> 'status' = 'not_started'
        AND (data ->> 'scheduled_at')::timestamp < NOW()
        AND (data ->> 'scheduled_at')::timestamp >= ?", time_to_update_from)
  end
end