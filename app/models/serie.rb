class Serie < ApplicationRecord
  has_many :matches

  def teams
    matches.flat_map { |m| [m.opponent_1, m.opponent_2] }.uniq
  end
end
