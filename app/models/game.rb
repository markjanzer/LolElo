class Game < ApplicationRecord
  belongs_to :opponent_1, class_name: "Team", optional: true
  belongs_to :opponent_2, class_name: "Team", optional: true
  belongs_to :winner, class_name: "Team", optional: true


  def match_data
    get_data(path: "/lol/matches", params: { "filter[id]": external_match_id })
  end
end
