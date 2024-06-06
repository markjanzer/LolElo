# frozen_string_literal: true

class PandaScore::League < ApplicationRecord
  self.table_name = 'panda_score_leagues'

  def panda_score_series
    PandaScore::Serie.where("data ->> 'league_id' = ?", panda_score_id.to_s)
  end

  def create_series
    fetched_series = PandaScoreAPI.series(league_id: panda_score_id)
    existing_series_ids = panda_score_series.pluck(:panda_score_id)
    fetched_series.each do |serie|
      next if existing_series_ids.include?(serie["id"])
      PandaScore::Serie.create!(panda_score_id: serie["id"], data: serie)
    end
  end
end