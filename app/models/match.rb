# frozen_string_literal: true

class Match < ApplicationRecord
  belongs_to :tournament
  belongs_to :opponent1, class_name: 'Team'
  belongs_to :opponent2, class_name: 'Team'
  has_many :games, dependent: :destroy

  validates :end_at, presence: true

  scope :with_games, -> { joins(:games).distinct }

  def teams
    [opponent1, opponent2]
  end

  def opponent_of(team)
    if team == opponent1
      opponent2
    elsif team == opponent2
      opponent1
    else
      raise ArgumentError, "Team #{team.name} is not in match #{id}"
    end
  end

  def panda_score_match
    PandaScore::Match.find_by(panda_score_id: panda_score_id)
  end
end
