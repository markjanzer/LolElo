# frozen_string_literal: true

class TeamFactory
  def initialize(team_data:, serie:)
    @team_data = team_data
    @serie = serie
  end
  
  def call
    if team_data.nil?
      raise "team_data is required"
    end

    if serie.nil?
      raise "serie is required to set the color"
    end

    if Team.exists?(panda_score_id: team_data["id"])
      return Team.find_by(panda_score_id: team_data["id"])
    end

    Team.new(
      panda_score_id: team_data["id"],
      name: team_data["name"],
      acronym: team_data["acronym"],
      color: color,
    )
  end
  
  private
  
  attr_reader :team_data, :serie

  def remaining_colors
    Team::UNIQUE_COLORS - serie.teams.pluck(:color)
  end

  def color
    remaining_colors.sample
  end
end
