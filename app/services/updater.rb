# This updater looks at PandaScore models that are not complete and then updates them 
# and their children.

# This will have to be paired with a service that updates the native models from the PandaScore models.
# How will I deal with PandaScore objects that haven't been created?
# Also how will this work if the API gets too many calls?

class Updater
  def call
    League.all.each do |league|
      create_new_series(league)
    end

    PandaScore::Serie.all.each do |ps_serie|
      next if ps_serie.data["end_at"].present?
      create_new_tournaments(ps_serie)

      # Update serie to check if complete
      # This logic was taken from 
      # /Users/markjanzer/dev/LolElo/app/services/panda_score_api_seeder/create_serie.rb
      ps_serie.update(PandaScoreAPI.serie(id: ps_serie.panda_score_id))
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

  # For each League, check if there is a new series, if there is create it 
  # There is an edge case here where we might need to populate this separately if the serie is already completed.
  def create_new_series(league)
    fetched_series = PandaScoreAPI.series(league_id: league.panda_score_id)

    existing_serie_ids = PandaScore::Serie.pluck(:panda_score_id)
    fetched_series.each do |serie|
      next if existing_serie_ids.include?(serie["id"])

      PandaScore::Serie
        .find_or_initialize_by(panda_score_id: serie["id"])
        .update(data: serie)
    end
  end

  # For each series that is not complete, create any new tournaments
  def create_new_tournaments(ps_serie)
    existing_tournament_ids = ps_serie.panda_score_tournaments.pluck(:panda_score_id)
    fetched_tournaments = PandaScoreAPI.tournaments(serie_id: ps_serie.panda_score_id)

    fetched_tournaments.each do |tournament|
      next if existing_tournament_ids.include?(tournament["id"])

      ps_tournament = PandaScore::Tournament
        .find_or_initialize_by(panda_score_id: tournament["id"])
        .tap { |t| t.update(data: tournament) }

      ps_tournament.data["teams"].each do |team|
        # If the team doesn't exist, make an API request to create it
        PandaScoreAPISeeder::CreateTeam.call(team["id"])
      end
    end
  end

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
  end
end