# LPL 2016 Spring and Summer have matches that have no games
LPL_INCOMPLETE_SERIE_IDS = [39, 426]

Serie.where(panda_score_id: LPL_INCOMPLETE_SERIE_IDS).destroy_all
league = League.find_by(name: "LPL")
first_serie = league.series.find_by(full_name: "Spring 2017")
# Recreate snapshots from beginning of 2017 Spring onwards
EloSnapshots::LeagueProcessor.call(league, first_serie.begin_at)