class Tournament < ApplicationRecord
  belongs_to :serie
  has_many :teams_tournaments
  has_many :teams, through: :teams_tournaments
  has_many :matches
end
