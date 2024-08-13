# LPL 2016 Spring and Summer have matches that have no games
INCOMPLETE_SERIE_IDS = [39, 426]

Serie.where(panda_score_id: INCOMPLETE_SERIE_IDS).destroy_all