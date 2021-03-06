# frozen_string_literal: true

class Match < ApplicationRecord
  belongs_to :tournament
  belongs_to :opponent1, class_name: 'Team'
  belongs_to :opponent2, class_name: 'Team'
  has_many :games

  def teams
    [opponent1, opponent2]
  end
end
