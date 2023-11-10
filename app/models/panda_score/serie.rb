# frozen_string_literal: true

class PandaScore::Serie < ApplicationRecord
  self.table_name = 'panda_score_series'

  def league
    League.find_by(panda_score_id: data['league_id'])
  end

  def panda_score_tournaments
    tournament_ids = data["tournaments"].map { |tournament| tournament["id"] }
    PandaScore::Tournament.where(panda_score_id: tournament_ids)
  end
end
