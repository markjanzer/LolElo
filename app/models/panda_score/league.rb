# frozen_string_literal: true

class PandaScore::League < ApplicationRecord
  self.table_name = 'panda_score_leagues'

  def panda_score_series
    series_ids = data["series"].map { |serie| serie["id"] }
    PandaScore::Serie.where(panda_score_id: series_ids)
  end
end