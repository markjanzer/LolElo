# frozen_string_literal: true

class PandaScore::Game < ApplicationRecord
  self.table_name = 'panda_score_games'

  def winner
    Team.find_by(panda_score_id: data["winner"]["id"])
  end

  def match
    Match.find_by(panda_score_id: data["match_id"])
  end

  def update_from_api
    api_data = PandaScoreAPI.game(id: panda_score_id)
    update(data: api_data)
  end
end
