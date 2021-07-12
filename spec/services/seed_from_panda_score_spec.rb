# frozen_string_literal: true

# Needed for when I want to run individual specs...
require 'rails_helper'

RSpec.describe SeedFromPandaScore do
  describe "#call" do
    subject { SeedFromPandaScore.new(leagues_seed_data).call }

    let(:leagues_seed_data) { [{ abbreviation: "nalcs", league_id: 1, time_zone: 'America/Los_Angeles' }] }
    let(:league_data) { { "id" => 1, "name" => "First League" } }
    let(:series_data) { 
      [{ 
        "id" => 1, 
        "year" => 2019, 
        "begin_at" => "2019-01-26T22:00:00Z",
        "full_name" => "Spring 2019",
      }] 
    }
    let(:tournaments_data) {
      [{
        "id" => 1, 
        "name" => "Regular season",
      }]
    }
    let(:teams_data) {
      [
        {
          "id" => 1,
          "name" => "Cloud9",
          "acronym" => "C9"
        },
        {
          "id" => 2,
          "name" => "Golden Guardians",
          "acronym" => "GG"
        }
      ]
    }
    let(:matches_data) {
      [
        {
          "id" => 1,
          "opponents" => match_opponents_data
        }
      ]
    }
    let(:match_opponents_data) { 
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
    }
    let(:games_data) {
      [{
        "id" => 1,
        "end_at" => "2019-02-26T22:00:00Z",
        "winner" => {
          "id" => 1
        }
      }]
    }

    before do
      allow(PandaScore).to receive(:league) { league_data }
      allow(PandaScore).to receive(:series) { series_data }
      allow(PandaScore).to receive(:tournaments) { tournaments_data }
      allow(PandaScore).to receive(:teams) { teams_data }
      allow(PandaScore).to receive(:matches) { matches_data }
      allow(PandaScore).to receive(:games) { games_data }
    end

    context "when there is only one of each object" do
      it "creates one league" do
        subject
        expect(League.count).to eq 1
      end
      it "creates one serie"
      it "creates a series that belongs to the league"
      it "creates one tournament"
      it "creates a tournament that belong to the serie"
      it "creates two teams"
      it "creates two teams that belong to the tournament"
      it "creates one match"
      it "creates a match that belongs to the tournament"
      it "creates a match that has the two teams as opponents"
      it "creates one game"
      it "creates a game that belongs to the match"
      it "creates a game that has one of the teams as a winner"
    end

  end
end