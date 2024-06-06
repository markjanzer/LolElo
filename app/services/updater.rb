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

    PandaScore::Match.all.each do |ps_match|
      next if ps_match.data["end_at"].present?

      create_new_games(ps_match)
      ps_match.update(PandaScoreAPI.match(id: ps_match.panda_score_id))
    end

    PandaScore::Game.all.each do |ps_game|
      next if ps_game.data["end_at"].present?

      ps_game.update(PandaScoreAPI.game(id: ps_game.panda_score_id))
    end
  end

  private

  # For each match that isn’t complete, check if there are any new games
  def create_new_games(ps_match)
    existing_game_ids = ps_match.panda_score_games.pluck(:panda_score_id)
    fetched_games = PandaScoreAPI.games(match_id: ps_match.panda_score_id)
    
    fetched_games.each do |game|
      next if existing_game_ids.include?(game["id"])

      PandaScore::Game.new(panda_score_id: game["id"], data: game).save!
    end
  end
end