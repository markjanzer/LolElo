# frozen_string_literal: true

class TournamentFactory
  def initialize(tournament_data)
    @tournament_data = tournament_data
  end
  
  def call
    if tournament_data.nil?
      raise "tournament_data is required"
    end
    
    create_tournament
  end
  
  private

  attr_reader :tournament_data

  def create_tournament
    tournament.tap do |t|
      t.name = tournament_data['name']
    end
  end

  def tournament
    @tournament ||= Tournament.find_or_initialize_by(panda_score_id: tournament_data['id'])
  end
end
