# frozen_string_literal: true

class Serie < ApplicationRecord
  belongs_to :league
  has_many :tournaments
  has_many :teams, -> { distinct }, through: :tournaments
  has_many :matches, through: :tournaments
  has_many :snapshots

  # I want to remove this from here but tests break atm
  def self.valid_name?(name)
    name.split.first.match?('Spring|Summer')
  end

  def panda_score_serie
    PandaScore::Serie.find_by(panda_score_id: panda_score_id)
  end
end

# Serie.first.get_data(path: "/lol/series", params: {
#   "filter[league_id]": 4198,
#   "filter[year]": 2019,
#   "filter[season]": "Summer"
# })
