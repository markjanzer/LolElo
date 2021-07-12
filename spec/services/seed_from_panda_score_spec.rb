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

      subject
    end

    context "when there is only one of each object" do

      it "creates one league" do
        expect(League.count).to eq 1
      end

      it "creates one serie" do
        expect(Serie.count).to eq 1
      end

      it "creates a series that belongs to the league" do
        expect(Serie.last.league).to eq League.last
      end

      it "creates one tournament" do
        expect(Tournament.count).to eq 1
      end

      it "creates a tournament that belong to the serie" do
        expect(Tournament.last.serie).to eq Serie.last
      end

      it "creates two teams" do
        expect(Team.count).to eq 2
      end

      it "creates two teams that belong to the tournament" do
        expect(Tournament.last.teams.pluck(:id)).to eq [Team.first.id, Team.second.id]
      end

      it "creates one match" do
        expect(Match.count).to eq 1
      end

      it "creates a match that belongs to the tournament" do
        expect(Match.first.tournament).to eq Tournament.first
      end

      it "creates a match that has the two teams as opponents" do
        opponent_ids = [Match.first.opponent_1.id, Match.first.opponent_2.id]
        expect(opponent_ids).to eq [Team.first.id, Team.second.id]
      end

      it "creates one game" do
        expect(Game.count).to eq 1
      end

      it "creates a game that belongs to the match" do
        expect(Game.first.match).to eq Match.first
      end

      it "creates a game that has one of the teams as a winner" do
        expect(Game.first.winner).to eq Team.first
      end
    end

  end
end