# This updater looks at PandaScore models that are not complete and then updates them 
# and their children.

# This will have to be paired with a service that updates the native models from the PandaScore models.
# How will I deal with PandaScore objects that haven't been created?
# Also how will this work if the API gets too many calls?

class Updater
  def self.call
    new.call
  end

  def call
    PandaScore::League.transaction do
      PandaScore::League.all.each do |ps_league|
        ps_league.create_series
        ps_league.update_from_api
      end

      unfinished_series.each do |ps_serie|
        ps_serie.create_tournaments
        ps_serie.update_from_api
      end

      unfinished_tournaments.each do |ps_tournament|
        ps_tournament.create_matches
        ps_tournament.update_from_api
      end

      unfinished_matches.each do |ps_match|
        ps_match.create_or_update_games
        ps_match.update_from_api
      end

      byebug
      
      puts "before end"
    end
  end

  def unfinished_series
    PandaScore::Serie
      .where("(data ->> 'end_at')::timestamp >= NOW()")
  end

  def unfinished_tournaments
    PandaScore::Tournament
      .where("(data ->> 'end_at')::timestamp >= NOW()")
  end

  def unfinished_matches
    PandaScore::Match
      .where("data ->> 'end_at' IS NULL")
      .where("data ->> 'status' = 'running' 
        OR data ->> 'status' = 'not_started' 
        AND (data ->> 'scheduled_at')::timestamp <= NOW()")
  end
end