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

  describe "#create_games" do
    context "games already exist" do
      it "does not create a game" do
        ps_match = create(:panda_score_match)
        ps_game = create(:panda_score_game, data: {
          "id"=>99,
          "match_id"=>ps_match.panda_score_id
        })

        allow(PandaScoreAPI).to receive(:games).with(match_id: ps_match.panda_score_id).and_return([ps_game.data])
        expect { ps_match.create_games }.not_to change { PandaScore::Match.count }
      end
    end

    it "creates games" do
      ps_match = create(:panda_score_match)
      new_game_data = {
        "id"=>99
      }

      allow(PandaScoreAPI).to receive(:games).with(match_id: ps_match.panda_score_id).and_return([new_game_data])
      expect { ps_match.create_games }.to change { PandaScore::Game.count }.by 1
    end
  end
end