# This updater looks at PandaScore models that are not complete and then updates them 
# and their children.

# This will have to be paired with a service that updates the native models from the PandaScore models.
# How will I deal with PandaScore objects that haven't been created?
# Also how will this work if the API gets too many calls?

class Updater
  def call
    League.all.each do |league|
      league.create_series
    end

    PandaScore::Serie.incomplete.each do |ps_serie|
      ps_serie.create_tournaments
      ps_serie.update_from_api
    end

    PandaScore::Tournament.incomplete.each do |ps_tournament|
      ps_tournament.create_matches
      ps_tournament.update_from_api
    end

    PandaScore::Match.incomplete.each do |ps_match|
      ps_match.create_games
      ps_match.update_from_api
    end 

    PandaScore::Game.all.each do |ps_game|
      next if ps_game.data["end_at"].present?

      ps_game.update(PandaScoreAPI.game(id: ps_game.panda_score_id))
    end
  end
end