# frozen_string_literal: true

# Needed for when I want to run individual specs...
require 'rails_helper'

RSpec.describe ApplicationSeeder::CreateOrUpdateGame do
  describe "#call" do
    context "when the game does not exist" do
      it "creates a game" do
        panda_score_game = create(:panda_score_game)
        match = create(:match)
        allow(panda_score_game).to receive(:match).and_return(match)

        team1 = create(:team)
        allow(panda_score_game).to receive(:winner).and_return(team1)
        
        expect { described_class.new(panda_score_game).call }.to change { Game.count }.by(1)
      end
    end

    context "when the game does exist" do
      it "does not create a new game" do
        panda_score_game = create(:panda_score_game)
        match = create(:match)
        allow(panda_score_game).to receive(:match).and_return(match)

        team1 = create(:team)
        allow(panda_score_game).to receive(:winner).and_return(team1)

        game = create(:game, panda_score_id: panda_score_game.panda_score_id)

        expect { described_class.new(panda_score_game).call }.not_to change { Game.count }
      end
    end

    context "when the game is forfeited" do
      it "does not create the game" do
        panda_score_game = create(:panda_score_game, data: {
          "forfeit" => true
        })
        match = create(:match)
        allow(panda_score_game).to receive(:match).and_return(match)

        team1 = create(:team)
        allow(panda_score_game).to receive(:winner).and_return(team1)

        game = create(:game, panda_score_id: panda_score_game.panda_score_id)

        expect { described_class.new(panda_score_game).call }.not_to change { Game.count }
      end
    end

    context "when the game has no end_at" do
      it "uses the begin_at and length to calculate the end_at value" do
        panda_score_game = create(:panda_score_game, data: {
          "end_at"=> nil,
          "begin_at"=> DateTime.parse("2020-01-01 00:00:00 UTC"),
          "length"=> 1200
        })
        match = create(:match)
        allow(panda_score_game).to receive(:match).and_return(match)

        team1 = create(:team)
        allow(panda_score_game).to receive(:winner).and_return(team1)

        described_class.new(panda_score_game).call

        game = Game.last

        expect(game.end_at).to eq(DateTime.parse("2020-01-01 00:20:00 UTC"))
      end
    end

    it "sets the game with correct attributes" do
      match = create(:match)
      end_at = DateTime.parse("2020-01-01")
      panda_score_game = create(:panda_score_game, data: {
        "name" => "name",
        "match_id" => match.panda_score_id,
        "end_at"=> end_at
      })


      team1 = create(:team)
      allow(panda_score_game).to receive(:winner).and_return(team1)

      described_class.new(panda_score_game).call
      
      game = Game.last

      expect(game).to have_attributes(
        panda_score_id: panda_score_game.panda_score_id,
        end_at: end_at,
        winner: panda_score_game.winner,
        match: panda_score_game.match
      )
    end
  end
end