# frozen_string_literal: true

class Game < ApplicationRecord
  # I think I should remove all of these optionals
  belongs_to :winner, class_name: 'Team', optional: true
  belongs_to :match, optional: true
  has_many :snapshots

  def loser
    return if winner.nil?
    
    # There probably is a more elegant way to do this
    if winner == match.opponent1
      match.opponent2
    else
      match.opponent1
    end
  end
end
