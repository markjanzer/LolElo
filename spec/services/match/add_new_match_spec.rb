# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Match::AddNewMatch do
  describe "#call" do
    subject { Match::AddNewMatch.new(match_data).call }

    let(:match_data) do
      {
        "id" => 1,
        "league_id" => 1,
        "serie_id" => 1,
        "serie" => match_serie_data,
        "tournament_id" => 1,
        "opponents" => opponents_data,
        "games" => games_data,
      }
    end

    let(:match_serie_data) do
      {
        "full_name" => "Spring 2020",
      }
    end

    let(:opponents_data) do
      [
        { 
          "opponent" => {
            "id" => 1
          }
        },
        {
          "opponent" => {
            "id" => 2
          }
        }
      ]
    end

    let(:games_data) do
      [
        {
          "end_at" => Date.current - 5.days,
          "winner" => {
            "id" => 1
          }
        }
      ]
    end

    let!(:league) { create(:league, panda_score_id: 1) }
    let!(:tournament) { create(:tournament, panda_score_id: 1) }
    let!(:serie) { create(:serie, panda_score_id: 1) }
    let!(:team1) { create(:team, panda_score_id: 1) }
    let!(:team2) { create(:team, panda_score_id: 2) }

    context "when the league does not exist" do
      let!(:league) { nil }

      it "raises an error" do

        expect { subject }.to raise_error "League does not exist"
      end
    end

    context "when the match already exists" do
      let!(:existing_match) { create(:match, panda_score_id: 1) }

      it "does nothing" do
        expect { subject }.not_to change { Match.count }
      end
    end

    context "when the serie is not legitimate" do
      let(:match_serie_data) do
        {
          "full_name" => "Promotion 2020"
        }
      end
      
      it "does nothing" do
        expect { subject }.not_to change { Match.count }
      end
    end

    context "when the match does not exist" do
      it "creates the match" do
        expect { subject }.to change { Match.count }.by 1
      end

      it "creates the games in the match" do
        expect(subject.games.length).to eq 1
      end

      it "creates games that belong to the match" do
        match = subject
        expect(match.games.first.match).to eq match
      end
    end

    context "when the tournament does not exist" do
      let(:tournament) { nil }
      let(:serie) { nil }

      it "creates a tournament" do
        expect { subject }.to change { Tournament.count }.by 1
      end

      it "creates a tournament that belongs to the league"
      it "creates teams for the tournament"
    end

    context "when the serie does not exist" do
      it "creates a serie"
      it "creates a serie that belongs to the tournament"
    end
  end
end