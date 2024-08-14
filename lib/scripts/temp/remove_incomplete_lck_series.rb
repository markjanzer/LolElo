# LCK 2015 Summer split has NaJin e-mFire and Kongdoo Monster even though they are
# the same team renamed. Removing serie until I can combine teams.
LCK_INCOMPLETE_SERIE_IDS = [1525]

Serie.where(panda_score_id: LCK_INCOMPLETE_SERIE_IDS).destroy_all
league = League.find_by(name: "LCK")
first_serie = league.series.find_by(full_name: "Spring 2016")
EloSnapshots::LeagueProcessor.call(league, first_serie.begin_at)