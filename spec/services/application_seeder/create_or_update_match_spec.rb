# frozen_string_literal: true

# Needed for when I want to run individual specs...
require 'rails_helper'

RSpec.describe ApplicationSeeder::CreateOrUpdateMatch do
  describe "#call" do
    context "when the match does not exist" do
      it "creates a match" do
        panda_score_match = create(:panda_score_match)
        tournament = create(:tournament)
        allow(panda_score_match).to receive(:tournament).and_return(tournament)

        team1 = create(:team)
        team2 = create(:team)
        allow(panda_score_match).to receive(:opponent1).and_return(team1)
        allow(panda_score_match).to receive(:opponent2).and_return(team2)
        
        expect { described_class.new(panda_score_match).call }.to change { Match.count }.by(1)
      end
    end

    context "when the match does exist" do
      it "does not create a new match" do
        panda_score_match = create(:panda_score_match)
        tournament = create(:tournament)
        allow(panda_score_match).to receive(:tournament).and_return(tournament)

        team1 = create(:team)
        team2 = create(:team)
        allow(panda_score_match).to receive(:opponent1).and_return(team1)
        allow(panda_score_match).to receive(:opponent2).and_return(team2)

        match = create(:match, panda_score_id: panda_score_match.panda_score_id)

        expect { described_class.new(panda_score_match).call }.not_to change { Match.count }
      end
    end

    context "when the match was forfeited" do
      it "does not create a new match" do
        panda_score_match = create(:panda_score_match, data: { "forfeit" => true })
        tournament = create(:tournament)
        allow(panda_score_match).to receive(:tournament).and_return(tournament)

        team1 = create(:team)
        team2 = create(:team)
        allow(panda_score_match).to receive(:opponent1).and_return(team1)
        allow(panda_score_match).to receive(:opponent2).and_return(team2)

        expect { described_class.new(panda_score_match).call }.not_to change { Match.count }
      end
    end

    it "sets the match with correct attributes" do
      tournament = create(:tournament)
      panda_score_match = create(:panda_score_match, data: {
        "name" => "name",
        "tournament_id" => tournament.panda_score_id
      })

      team1 = create(:team)
      team2 = create(:team)
      allow(panda_score_match).to receive(:opponent1).and_return(team1)
      allow(panda_score_match).to receive(:opponent2).and_return(team2)

      described_class.new(panda_score_match).call
      
      match = Match.last

      expect(match).to have_attributes(
        panda_score_id: panda_score_match.panda_score_id,
        end_at: panda_score_match.data["end_at"],
        opponent1: panda_score_match.opponent1,
        opponent2: panda_score_match.opponent2,
        tournament: tournament
      )
    end
  end
end