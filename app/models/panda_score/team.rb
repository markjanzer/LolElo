# frozen_string_literal: true

class PandaScore::Team < ApplicationRecord
  self.table_name = 'panda_score_teams'

  def tournament
    Tournament.find_by(panda_score_id: data["tournament_id"])
  end
end
