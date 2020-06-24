class Game < ApplicationRecord
  # I think I should remove all of these optionals
  belongs_to :winner, class_name: "Team", optional: true
  belongs_to :match, optional: true
end
