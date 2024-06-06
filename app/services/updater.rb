# This updater looks at PandaScore models that are not complete and then updates them 
# and their children.

# This will have to be paired with a service that updates the native models from the PandaScore models.
# How will I deal with PandaScore objects that haven't been created?
# Also how will this work if the API gets too many calls?

class Updater
  def call
    League.all.each do |league|
      league.create_new_series
    end

    PandaScore::Serie.incomplete.each do |ps_serie|
      ps_serie.create_tournaments
      ps_serie.update_from_api
    end

    PandaScore::Tournament.all.each do |ps_tournament|
      next if ps_tournament.data["end_at"].present?

      create_new_matches(ps_tournament)
      ps_tournament.update(PandaScoreAPI.tournament(id: ps_tournament.panda_score_id))
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

  # For each tournament that is not complete, check if there are any new matches
  def create_new_matches(ps_tournament)
    existing_match_ids = ps_tournament.panda_score_matches.pluck(:panda_score_id)
    fetched_matches = PandaScoreAPI.matches(tournament_id: ps_tournament.panda_score_id)

    fetched_matches.each do |match|
      next if existing_match_ids.include?(match["id"])

      PandaScore::Match.new(panda_score_id: match["id"], data: match).save!
    end
  end

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