# frozen_string_literal: true

class PandaScore::League < ApplicationRecord
  self.table_name = 'panda_score_leagues'

  def self.create_or_update_from_api(league_ps_id)
    find_or_initialize_by(panda_score_id: league_ps_id)
      .update_from_api
  end

  def panda_score_series
    PandaScore::Serie.where("data ->> 'league_id' = ?", panda_score_id.to_s)
  end

  def create_series
    fetched_series = PandaScoreAPI.series(league_id: panda_score_id)
    existing_series_ids = panda_score_series.pluck(:panda_score_id)
    new_series = fetched_series.reject { |serie| existing_series_ids.include?(serie["id"]) }
    new_series.each do |serie|
      PandaScore::Serie.create!(panda_score_id: serie["id"], data: serie)
    end
  end

  def update_from_api
    update!(data: PandaScoreAPI.league(id: panda_score_id))
  end

  def upsert_model
    League.find_or_initialize_by(panda_score_id: panda_score_id)
      .update!(
        name: data["name"],
        time_zone: time_zone
      )
  end
  
  # I have definitely done this before, I should try to find it.
  def create_model
    League.create!(panda_score_id: panda_score_id, name: data.dig('name'))
  end
end