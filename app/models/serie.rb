class Serie < ApplicationRecord
  belongs_to :league
  has_many :matches
  has_many :series_teams
  has_many :teams, through: :series_teams
end


# Serie.first.get_data(path: "/lol/series", params: {
#   "filter[league_id]": 4198,
#   "filter[year]": 2019,
#   "filter[season]": "Summer"
# })