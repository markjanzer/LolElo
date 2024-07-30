# frozen_string_literal: true

class PandaScore::Game < ApplicationRecord
  self.table_name = 'panda_score_games'

  def winner
    Team.find_by(panda_score_id: data["winner"]["id"])
  end

  def panda_score_match
    PandaScore::Match.find_by(panda_score_id: data["match_id"])
  end

  def match
    Match.find_by(panda_score_id: data["match_id"])
  end

  def update_from_api
    api_data = PandaScoreAPI.game(id: panda_score_id)
    update(data: api_data)
  end

  def upsert_model
    Game.find_or_initialize_by(panda_score_id: panda_score_id)
      .update!(
        end_at: end_at,
        winner: winner,
        match: match
      )
  end

  private

  # There is at least one game (ps_id: 149787) without an end_at that wasn't forfeited.
  def end_at
    return data["end_at"] unless data["end_at"].nil?

    # Not sure if I want this. Maybe I want things to break?
    raise if data["begin_at"].nil? || data["length"].nil?

    DateTime.parse(data["begin_at"]) + data["length"].seconds
  end
end
