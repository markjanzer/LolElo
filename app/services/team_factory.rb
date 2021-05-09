# frozen_string_literal: true

class TeamFactory
  def initialize(team_data:)
    @team_data = team_data
  end
  
  def call
    if team_data.nil?
      raise "team_data is required"
    end

    if Team.exists?(external_id: team_data["id"])
      return Team.find_by(external_id: team_data["id"])
    end

    Team.new(
      external_id: team_data["id"],
      name: team_data["name"],
      acronym: team_data["acronym"],
    )
  end
  
  private
  
  attr_reader :team_data
end
