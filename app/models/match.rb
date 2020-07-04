class Match < ApplicationRecord
  belongs_to :serie
  # I think I should remove all of these optionals
  belongs_to :opponent_1, class_name: "Team", optional: true
  belongs_to :opponent_2, class_name: "Team", optional: true
  has_many :games

  def pandascore_data
    self.get_data(path: "/lol/matches", params: { "filter[id]": external_id }).first
  end
end
