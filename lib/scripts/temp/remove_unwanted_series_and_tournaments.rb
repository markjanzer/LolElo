require_relative '../../../config/environment'

UNWANTED_SERIE_IDS = [2299, 2516]

def unwanted_series
  Serie.where(panda_score_id: UNWANTED_SERIE_IDS)
end

def unwanted_tournaments
  Tournament.where('name ILIKE ?', '%promotion%')
end

def unused_teams
  Team.left_outer_joins(:teams_tournaments)
    .where(teams_tournaments: { id: nil })
end

def remove_unwanted_series_and_tournaments
  unwanted_series.destroy_all
  unwanted_tournaments.destroy_all
  unused_teams.destroy_all
end

remove_unwanted_series_and_tournaments