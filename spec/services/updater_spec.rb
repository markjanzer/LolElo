# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Updater do
  describe "#call" do
    # This is a little tricky because it continues to run the code
    # Which attempts to access the API, and I don't want to spec everything out
    # This might be a little easier when I move logic around.
    it "calls create_new_tournaments with each ps_serie that hasn't finished"

    it "updates the ps_serie"
    it "does not do anything if the serie is complete"
    
    it "calls create_new_matches with each non-complete tournament"
    it "update each non-complete tournament"
    it "does nothing if the tournament is complete"

    it "calls create_new_games for each non-complete match"
    it "updates each non-complete match"
    it "does nothing if the match is complete"

    it "updates each non-complete game"
    it "does nothing if the game is complete"
  end

  describe "#create_new_games" do
    context "games already exist" do
      it "does not create a game" do
        ps_tournament = create(:panda_score_tournament)
        ps_match = create(:panda_score_match)
        new_match_data = {
          "id"=>ps_match.panda_score_id
        }
        ps_tournament.data["matches"] = [new_match_data]

        allow(PandaScoreAPI).to receive(:matches).with(tournament_id: ps_tournament.panda_score_id).and_return([new_match_data])
        expect { described_class.new.send(:create_new_matches, ps_tournament) }.not_to change { PandaScore::Match.count }
      end
    end

    it "creates games" do
      ps_match = create(:panda_score_match)
      new_game_data = {
        "id"=>99
      }

      allow(PandaScoreAPI).to receive(:games).with(match_id: ps_match.panda_score_id).and_return([new_game_data])
      expect { described_class.new.send(:create_new_games, ps_match) }.to change { PandaScore::Game.count }.by 1
    end
  end
end