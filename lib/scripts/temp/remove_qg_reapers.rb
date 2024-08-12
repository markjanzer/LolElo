# QG reapers have been added to tournaments, but given no games
# They should be taking place of JD Gaming, as JD Gaming did not buy them
# but rather bought their spot. Regardless, PandaScore is showing all of the games
# as JD Gaming, which makes the QG Reapers team useless.
team = Team.find_by(panda_score_id: 1541)
team.teams_tournaments.destroy_all