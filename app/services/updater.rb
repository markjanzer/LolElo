# This updater looks at PandaScore models that are not complete and then updates them 
# and their children.

# This will have to be paired with a service that updates the native models from the PandaScore models.
# How will I deal with PandaScore objects that haven't been created?
# Also how will this work if the API gets too many calls?

class Updater
  def call
    create_new_series
    create_new_tournaments
    create_new_matches
    create_new_games
    update_games
  end

  private

  # For each League, check if there is a new series, if there is create it 
  # There is an edge case here where we might need to populate this separately if the serie is already completed.
  def create_new_series
    League.all.each do |league|
      fetched_series = PandaScoreAPI.series(league_id: league.panda_score_id)

      existing_serie_ids = PandaScore::Serie.pluck(:panda_score_id)
      fetched_series.each do |serie|
        next if existing_serie_ids.include?(serie["id"])

        PandaScore::Serie
          .find_or_initialize_by(panda_score_id: serie["id"])
          .update(data: serie)
      end
    end
  end

  # For each series that is not complete, create any new tournaments
  # Also update the serie if there are any changes
  def create_new_tournaments
    PandaScore::Serie.all.each do |serie|
      next if serie["end_at"].present?

      fetched_tournaments = PandaScoreAPI.tournaments(serie_id: serie.panda_score_id)
      existing_tournament_ids = serie.panda_score_tournaments.pluck(:panda_score_id)

      fetched_tournaments.each do |tournament|
        next if existing_tournament_ids.include?(tournament["id"])

        # Need to create teams
        tournament = PandaScore::Tournament
          .find_or_initialize_by(panda_score_id: tournament["id"])
          .update(data: tournament)
        
        tournament.teams.each do |team|
          PandaScoreAPISeeder::CreateTeam.call(team["id"])
        end
      end

      serie.update(data: serie)
    end
  end

  # For each tournament that is not complete, check if there are any new matches
  def create_new_matches
  end

  # For each match that isn’t complete, check if there are any new games
  def create_new_games
  end

  # For a game that isn’t complete, check if the game has completed
  def update_games
  end
end