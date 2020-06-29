class Serie < ApplicationRecord
  has_many :matches

  def teams
    matches.flat_map { |m| [m.opponent_1, m.opponent_2] }.uniq
  end

  def pandascore_data
    get_data(path: "/lol/series", params: { "filter[id]": external_id })
  end
end


# Serie.first.get_data(path: "/lol/series", params: {
#   "filter[league_id]": 4198,
#   "filter[year]": 2020,
#   "filter[season]": "Summer"
# })