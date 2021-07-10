# frozen_string_literal: true

class Game < ApplicationRecord
  # I think I should remove all of these optionals
  belongs_to :winner, class_name: 'Team', optional: true
  belongs_to :match, optional: true

  def loser
    return if winner.nil?
    
    # There probably is a more elegant way to do this
    if winner == match.opponent_1
      match.opponent_2
    else
      match.opponent_1
    end
  end
end
