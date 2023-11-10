# frozen_string_literal: true

class PandaScore::Tournament < ApplicationRecord
  self.table_name = 'panda_score_tournaments'

  def serie
    Serie.find_by(panda_score_id: data['serie_id'])
  end

  def panda_score_teams
    team_ids = data["teams"].map { |team| team["id"] }
    PandaScore::Team.where(panda_score_id: team_ids)
  end

  def panda_score_matches
    match_ids = data["matches"].map { |match| match["id"] }
    PandaScore::Match.where(panda_score_id: match_ids)
  end
end
