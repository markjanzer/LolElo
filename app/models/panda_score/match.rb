# frozen_string_literal: true

class PandaScore::Match < ApplicationRecord
  self.table_name = 'panda_score_matches'

  scope :incomplete, -> { where("data ->> 'end_at' IS NULL") }
  scope :started, -> { where("
    data ->> 'status' = 'running' 
    OR data ->> 'status' = 'not_started' 
      AND (data ->> 'scheduled_at')::timestamp <= ?", Time.now)
  }

  def tournament
    Tournament.find_by(panda_score_id: data["tournament_id"])
  end

  def opponent1
    Team.find_by(panda_score_id: opponent_id(0))
  end

  def opponent2
    Team.find_by(panda_score_id: opponent_id(1))
  end

  def panda_score_games
    PandaScore::Game.where("data ->> 'match_id' = ?", panda_score_id.to_s)
  end

  # Creates/Updates games from #data["games"]
  def create_or_update_games
    data["games"].each do |game|
      PandaScore::Game
        .find_or_initialize_by(panda_score_id: game["id"])
        .update!(data: game)
    end
  end

  def update_from_api 
    api_data = PandaScoreAPI.match(id: panda_score_id)
    update(data: api_data)
  end

  private

  def opponent_id(index)
    data["opponents"][index]["opponent"]["id"]
  end
end
