class Match < ApplicationRecord
  belongs_to :tournament
  belongs_to :opponent_1, class_name: "Team"
  belongs_to :opponent_2, class_name: "Team"
  has_many :games
end
