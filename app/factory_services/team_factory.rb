# frozen_string_literal: true

class TeamFactory
  def initialize(team_data:, color:)
    @team_data = team_data
    @color = color
  end
  
  def call
    if team_data.nil?
      raise "team_data is required"
    end

    if color.nil?
      raise "color is required"
    end

    if Team.exists?(external_id: team_data["id"])
      return Team.find_by(external_id: team_data["id"])
    end

    Team.new(
      external_id: team_data["id"],
      name: team_data["name"],
      acronym: team_data["acronym"],
      color: color,
    )
  end
  
  private
  
  attr_reader :team_data, :color
end
