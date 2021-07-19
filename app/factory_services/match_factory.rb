# frozen_string_literal: true

class MatchFactory
  
  def initialize(match_data)
    @match_data = match_data
  end
  
  def call
    if match_data.nil?
      raise "match_data is required"
    end

    if opponent_1.nil? || opponent_2.nil?
      raise "team does not exist"
    end
    
    match.assign_attributes({
      end_at: match_data['end_at'],
      opponent_1: opponent_1,
      opponent_2: opponent_2
    })

    match
  end
    
  private

  attr_reader :match_data

  def match
    @match ||= Match.find_or_initialize_by(panda_score_id: match_data['id'])
  end

  def opponent_1
    Team.find_by(panda_score_id: match_data['opponents'].first['opponent']['id'])
  end

  def opponent_2
    Team.find_by(panda_score_id: match_data['opponents'].second['opponent']['id'])
  end

  # def completed_games_data(match_data)
  #   match_data['games'].reject { |game| game['forfeit'] }
  # end
end
