# frozen_string_literal: true

class PandaScore::Team < ApplicationRecord
  self.table_name = 'panda_score_teams'

  def self.create_from_id(id)
    # Creates team from panda_score id if it doesn't exist
    return if exists?(panda_score_id: id)
    api_data = PandaScoreAPI.team(id: id)
    create(panda_score_id: id, data: api_data)
  end

  def upsert_model(tournament)
    team = Team.find_or_initialize_by(panda_score_id: panda_score_id)

    if team.color.nil?
      team.color = unique_team_color(tournament)
    end

    team.update!(
      name: data["name"],
      acronym: data["acronym"],
    )
  end

  def team
    Team.find_by(panda_score_id: panda_score_id)
  end

  private

  def unique_team_color(tournament)
    taken_colors = tournament.serie.teams.pluck(:color)
    remaining_colors = Team::UNIQUE_COLORS - taken_colors

    if remaining_colors.empty?
      return Team::UNIQUE_COLORS.sample
    end
    
    remaining_colors.sample
  end
end
