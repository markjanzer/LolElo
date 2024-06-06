# frozen_string_literal: true

class PandaScore::Serie < ApplicationRecord
  self.table_name = 'panda_score_series'

  scope :incomplete, -> { where("data ->> 'end_at' IS NULL") }

  def league
    League.find_by(panda_score_id: data['league_id'])
  end

  def panda_score_tournaments
    PandaScore::Tournament.where("data ->> 'serie_id' = ?", panda_score_id.to_s)
  end

  def create_new_tournaments
    existing_tournament_ids = panda_score_tournaments.pluck(:panda_score_id)
    fetched_tournaments = PandaScoreAPI.tournaments(serie_id: panda_score_id)

    fetched_tournaments.each do |tournament|
      next if existing_tournament_ids.include?(tournament["id"])
      ps_tournament = PandaScore::Tournament.create!(panda_score_id: tournament["id"], data: tournament)
      ps_tournament.create_teams
    end
  end
end
