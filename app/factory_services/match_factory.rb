# frozen_string_literal: true

class MatchFactory
  
  def initialize(match_data)
    @match_data = match_data
  end
  
  def call
    if match_data.nil?
      raise "match_data is required"
    end

    if opponent1.nil? || opponent2.nil?
      raise "team does not exist"
    end
    
    match.assign_attributes({
      end_at: match_data['end_at'],
      opponent1: opponent1,
      opponent2: opponent2
    })

    match
  end
    
  private

  attr_reader :match_data

  def match
    @match ||= Match.find_or_initialize_by(panda_score_id: match_data['id'])
  end

  def opponent1
    Team.find_by(panda_score_id: match_data['opponents'].first['opponent']['id'])
  end

  def opponent2
    Team.find_by(panda_score_id: match_data['opponents'].second['opponent']['id'])
  end
end
