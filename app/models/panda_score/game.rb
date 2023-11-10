# frozen_string_literal: true

class PandaScore::Game < ApplicationRecord
  self.table_name = 'panda_score_games'

  def winner
    Team.find_by(panda_score_id: data["winner"]["id"])
  end

  def match
    Match.find_by(panda_score_id: data["match_id"])
  end
end
