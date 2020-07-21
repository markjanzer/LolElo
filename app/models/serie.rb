class Serie < ApplicationRecord
  belongs_to :league
  has_many :tournaments
  has_many :teams, -> { distinct }, through: :tournaments
  has_many :matches, through: :tournaments

end


# Serie.first.get_data(path: "/lol/series", params: {
#   "filter[league_id]": 4198,
#   "filter[year]": 2019,
#   "filter[season]": "Summer"
# })