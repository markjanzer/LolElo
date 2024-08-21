# frozen_string_literal: true

class League < ApplicationRecord
  has_many :series, class_name: 'Serie'

  # I don't think we really need this but I couldn't figure out
  # the legit way to do this in EloSnapshots::LeagueProcessor
  has_many :tournaments, through: :series
  has_many :matches, through: :tournaments
  has_many :games, through: :matches

  has_many :snapshots, through: :series

  LEAGUE_ORDER = {
    "LCS" => 1,
    "LEC" => 2,
    "LPL" => 3,
    "LCK" => 4,
  }

  def panda_score_league
    PandaScore::League.find_by(panda_score_id: panda_score_id)
  end
end
