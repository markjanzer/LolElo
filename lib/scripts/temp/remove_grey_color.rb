require_relative '../../../config/environment'

color = "#a9a9a9"
Team.where(color: color).each do |team|
  ps_team = PandaScore::Team.find_by(panda_score_id: team.panda_score_id)
  team.update(color: nil)
  ps_team.upsert_model(team.tournaments.last)
end