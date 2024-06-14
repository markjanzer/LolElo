# frozen_string_literal: true

class PandaScore::Team < ApplicationRecord
  self.table_name = 'panda_score_teams'

  def self.create_from_id(id)
    # Creates team from panda_score id if it doesn't exist
    return if exists?(panda_score_id: id)
    create(panda_score_id: id, dat: api_data)
  end

  def api_data
    PandaScoreAPI.team(id: panda_score_id)
  end
end
