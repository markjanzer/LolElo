# frozen_string_literal: true

class PandaScore::Match < ApplicationRecord
  self.table_name = 'panda_score_matches'

  def tournament
    Tournament.find_by(panda_score_id: data["tournament_id"])
  end

  def opponent1
    Team.find_by(panda_score_id: opponent_id(0))
  end

  def opponent2
    Team.find_by(panda_score_id: opponent_id(1))
  end

  private

  def opponent_id(index)
    data["opponents"][index]["opponent"]["id"]
  end
end
