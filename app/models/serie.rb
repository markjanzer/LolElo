class Serie < ApplicationRecord
  belongs_to :league
  has_many :matches
  has_many :series_teams
  has_many :teams, through: :series_teams

  # def teams
  #   matches.includes(:opponent_1, :opponent_2).flat_map { |m| [m.opponent_1, m.opponent_2] }.uniq
  # end

  def pandascore_data
    self.get_data(path: "/lol/series", params: { "filter[id]": external_id })
  end
end


# Serie.first.get_data(path: "/lol/series", params: {
#   "filter[league_id]": 4198,
#   "filter[year]": 2019,
#   "filter[season]": "Summer"
# })