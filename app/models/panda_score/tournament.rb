# frozen_string_literal: true

class PandaScore::Tournament < ApplicationRecord
  self.table_name = 'panda_score_tournaments'

  scope :incomplete, -> { where("data ->> 'end_at' IS NULL") }

  def serie
    Serie.find_by(panda_score_id: data['serie_id'])
  end

  def panda_score_teams
    team_ids = data["teams"].map { |team| team["id"] }
    PandaScore::Team.where(panda_score_id: team_ids)
  end

  def panda_score_matches
    PandaScore::Match.where("data ->> 'tournament_id' = ?", panda_score_id.to_s)
  end

  def create_teams
    data["teams"].each do |team|
      # If the team doesn't exist, make an API request to create it
      PandaScoreAPISeeder::CreateTeam.call(team["id"])
    end
  end

  def create_new_matches
    existing_match_ids = panda_score_matches.pluck(:panda_score_id)
    fetched_matches = PandaScoreAPI.matches(tournament_id: panda_score_id)

    fetched_matches.each do |match|
      next if existing_match_ids.include?(match["id"])
      PandaScore::Match.create!(panda_score_id: match["id"], data: match)
    end
  end
end
