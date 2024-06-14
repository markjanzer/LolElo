# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PandaScore::Match do
  describe "#tournament" do
    it "returns the tournament from the data" do
      tournament = create(:tournament)
      panda_score_match = create(:panda_score_match, data: { "tournament_id" => tournament.panda_score_id })

      expect(panda_score_match.tournament).to eq(tournament)
    end
  end

  # This might break now
  describe "#create_or_update_games" do
    it "creates games" do
      ps_match = create(:panda_score_match)
      new_game_data = {
        "id"=>99
      }
      
      allow(PandaScoreAPI).to receive(:games).with(match_id: ps_match.panda_score_id).and_return([new_game_data])
      expect { ps_match.create_or_update_games }.to change { PandaScore::Game.count }.by 1
    end

    it "updates existing games" do
      ps_match = create(:panda_score_match)
      ps_game = create(:panda_score_game, panda_score_id: 99, data: {
        "id"=>99,
        "match_id"=>ps_match.panda_score_id
      })
      new_game_data = {
        "id"=>99,
        "match_id"=>ps_match.panda_score_id,
        "new_data"=>"new"
      }

      allow(PandaScoreAPI).to receive(:games).with(match_id: ps_match.panda_score_id).and_return([new_game_data])
      expect { ps_match.create_or_update_games }.not_to change { PandaScore::Game.count }
      expect(ps_game.reload.data["new_data"]).to eq("new")
    end
  end
end