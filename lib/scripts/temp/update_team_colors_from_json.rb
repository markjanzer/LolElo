require_relative '../../../config/environment'

json = File.read(Rails.root.join('config', 'team_colors.json'))
colors_hash = JSON.parse(json)
colors_hash.each do |panda_score_id, color|
  team = Team.find_by(panda_score_id: panda_score_id)
  team.update(color: color)
end