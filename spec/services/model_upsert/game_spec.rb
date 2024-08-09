# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ModelUpsert::Game do
  describe ".call" do
    context "when the game does not exist" do
      it "creates a game" do
        panda_score_game = create(:panda_score_game, data: {
          end_at: DateTime.now
        })

        team1 = create(:team)
        allow(panda_score_game).to receive(:winner).and_return(team1)
        match = create(:match)
        allow(panda_score_game).to receive(:match).and_return(match)
        
        expect { described_class.call(panda_score_game) }.to change { Game.count }.by(1)
      end
    end

    context "when the game already exists" do
      it "does not create a new game" do
        panda_score_game = create(:panda_score_game, data: {
          end_at: DateTime.now
        })

        team1 = create(:team)
        allow(panda_score_game).to receive(:winner).and_return(team1)

        create(:game, panda_score_id: panda_score_game.panda_score_id)

        expect { described_class.call(panda_score_game) }.not_to change { Game.count }
      end
    end

    context "when the game is forfeited" do
      it "does not create the game" do
        panda_score_game = create(:panda_score_game, data: {
          end_at: DateTime.now,
          forfeit: true
        })

        team1 = create(:team)
        allow(panda_score_game).to receive(:winner).and_return(team1)
        match = create(:match)
        allow(panda_score_game).to receive(:match).and_return(match)

        expect { described_class.call(panda_score_game) }.not_to change { Game.count }
      end
    end

    context "when there is no match" do
      it "does not create the game" do
        panda_score_game = create(:panda_score_game, data: {
          end_at: DateTime.now
        })

        team1 = create(:team)
        allow(panda_score_game).to receive(:winner).and_return(team1)
        allow(panda_score_game).to receive(:match).and_return(nil)

        expect { described_class.call(panda_score_game) }.not_to change { Game.count }
      end
    end

    context "when the game has not started" do
      it "does not create the game" do
        panda_score_game = create(:panda_score_game, data: {
          end_at: DateTime.now,
          status: "not_started"
        })

        team1 = create(:team)
        allow(panda_score_game).to receive(:winner).and_return(team1)
        match = create(:match)
        allow(panda_score_game).to receive(:match).and_return(match)

        create(:game, panda_score_id: panda_score_game.panda_score_id)

        expect { described_class.call(panda_score_game) }.not_to change { Game.count }
      end
    end

    context "when the game has no end_at" do
      it "uses the begin_at and length to calculate the end_at value" do
        panda_score_game = create(:panda_score_game, data: {
          "end_at"=> nil,
          "begin_at"=> DateTime.parse("2020-01-01 00:00:00 UTC"),
          "length"=> 1200
        })

        team1 = create(:team)
        allow(panda_score_game).to receive(:winner).and_return(team1)
        match = create(:match)
        allow(panda_score_game).to receive(:match).and_return(match)

        described_class.call(panda_score_game)

        game = Game.last

        expect(game.end_at).to eq(DateTime.parse("2020-01-01 00:20:00 UTC"))
      end
      
      xcontext "the game has no begin_at and length" do
        it "uses the match end_at value" do
          panda_score_game = create(:panda_score_game, data: {
            "end_at"=> nil
          })
          
          match_end_at = DateTime.parse("2020-01-01 00:00:00 UTC")
          panda_score_match = create(:panda_score_match, data: {
            "end_at"=> match_end_at
          })
          allow(panda_score_game).to receive(:panda_score_match).and_return(panda_score_match)

          team1 = create(:team)
          allow(panda_score_game).to receive(:winner).and_return(team1)
          match = create(:match)
          allow(panda_score_game).to receive(:match).and_return(match)

          described_class.call(panda_score_game)

          game = Game.last

          expect(game.end_at).to eq(match_end_at)
        end
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

      described_class.call(panda_score_game)
      
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