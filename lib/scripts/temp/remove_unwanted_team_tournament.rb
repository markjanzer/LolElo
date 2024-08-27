require_relative '../../../config/environment'

# Snake esports belongs to an LCK tournament for some reason
TeamsTournament.find_by(team_id: 376, tournament_id: 511).destroy!