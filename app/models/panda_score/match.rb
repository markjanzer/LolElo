# frozen_string_literal: true

class PandaScore::Match < ApplicationRecord
  self.table_name = 'panda_score_matches'

  scope :incomplete, -> { where("data ->> 'end_at' IS NULL") }

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

  def create_games
    existing_game_ids = panda_score_games.pluck(:panda_score_id)
    fetched_games = PandaScoreAPI.games(match_id: panda_score_id)
    
    fetched_games.each do |game|
      next if existing_game_ids.include?(game["id"])
      PandaScore::Game.create!(panda_score_id: game["id"], data: game)
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
