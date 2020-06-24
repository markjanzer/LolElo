class Match < ApplicationRecord
  # I think I should remove all of these optionals
  belongs_to :opponent_1, class_name: "Team", optional: true
  belongs_to :opponent_2, class_name: "Team", optional: true

  def pandascore_data
    get_data(path: "/lol/matches", params: { "filter[id]": external_id })
  end
end
