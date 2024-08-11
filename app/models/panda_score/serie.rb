# frozen_string_literal: true

class PandaScore::Serie < ApplicationRecord
  self.table_name = 'panda_score_series'

  scope :incomplete, -> { where("data ->> 'end_at' IS NULL") }

  def self.create_or_update_from_api(serie_id)
    find_or_initialize_by(panda_score_id: serie_id)
      .update_from_api
  end

  def league
    League.find_by(panda_score_id: data['league_id'])
  end

  def panda_score_tournaments
    PandaScore::Tournament.where("data ->> 'serie_id' = ?", panda_score_id.to_s)
  end

  def create_tournaments
    existing_tournament_ids = panda_score_tournaments.pluck(:panda_score_id)
    fetched_tournaments = PandaScoreAPI.tournaments(serie_id: panda_score_id)

    fetched_tournaments.each do |tournament|
      next if existing_tournament_ids.include?(tournament["id"])
      ps_tournament = PandaScore::Tournament.find_or_initialize_by(panda_score_id: tournament["id"])
      ps_tournament.update!(data: tournament)
      ps_tournament.create_panda_score_teams
    end
  end

  def update_from_api
    api_data = PandaScoreAPI.serie(id: panda_score_id)
    update(data: api_data)
  end

  def upsert_model
    Serie.find_or_initialize_by(panda_score_id: panda_score_id)
      .update!(
        year: data["year"],
        begin_at: data["begin_at"],
        full_name: data["full_name"],
        league: league
      )
  end
end
