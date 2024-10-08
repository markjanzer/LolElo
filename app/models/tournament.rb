# frozen_string_literal: true

class Tournament < ApplicationRecord
  belongs_to :serie
  has_many :teams_tournaments, dependent: :destroy
  has_many :teams, through: :teams_tournaments
  has_many :matches, dependent: :destroy

  def panda_score_tournament
    PandaScore::Tournament.find_by(panda_score_id: panda_score_id)
  end
end
