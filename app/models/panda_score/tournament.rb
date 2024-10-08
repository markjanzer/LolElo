# frozen_string_literal: true

class PandaScore::Tournament < ApplicationRecord
  self.table_name = 'panda_score_tournaments'

  scope :incomplete, -> { where("(data ->> 'end_at') <= NOW()") }

  def self.create_or_update_from_api(tournament_id)
    find_or_initialize_by(panda_score_id: tournament_id)
      .update_from_api
  end

  def tournament
    Tournament.find_by(panda_score_id: panda_score_id)
  end

  def serie
    Serie.find_by(panda_score_id: data['serie_id'])
  end

  def panda_score_serie
    PandaScore::Serie.find_by(panda_score_id: data['serie_id'])
  end

  def panda_score_teams
    team_ids = data["teams"].map { |team| team["id"] }
    PandaScore::Team.where(panda_score_id: team_ids)
  end

  def panda_score_matches
    PandaScore::Match.where("data ->> 'tournament_id' = ?", panda_score_id.to_s)
  end

  def create_panda_score_teams
    data["teams"].each do |team|
      PandaScore::Team.create_from_id(team["id"])
    end
  end

  def create_matches
    existing_match_ids = panda_score_matches.pluck(:panda_score_id)
    fetched_matches = PandaScoreAPI.matches(tournament_id: panda_score_id)

    fetched_matches.each do |match|
      next if existing_match_ids.include?(match["id"])
      PandaScore::Match.create!(panda_score_id: match["id"], data: match)
    end
  end

  def update_from_api
    api_data = PandaScoreAPI.tournament(id: panda_score_id)
    update(data: api_data)
  end

  # Method to display the first level of the data attribute
  def shallow_data
    data.keys.each_with_object({}) do |key, hash|
      if data[key].is_a?(Hash)
        hash[key] = "Hash"
      elsif data[key].is_a?(Array)
        hash[key] = "Array"
      else
        hash[key] = data[key]
      end
    end
  end
end
