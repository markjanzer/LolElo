# frozen_string_literal: true

# Needed for when I want to run individual specs...
# require 'rails_helper'

RSpec.describe Game::CreateSnapshots do
  describe "#call" do
    subject { Game::CreateSnapshots.new(game).call }

    let!(:match) { create(:match, opponent_1: winning_team, opponent_2: losing_team, games: [game]) }
    let(:game) { create(:game, winner: winning_team, end_at: "2020-02-01") }
    let(:winning_team) { create(:team, name: "winning_team", snapshots: [winning_team_snapshot]) }
    let(:losing_team) { create(:team, name: "losing_team", snapshots: [losing_team_snapshot]) }
    let(:winning_team_snapshot) { create(:snapshot, elo: winning_team_previous_elo, date: "2020-01-01") }
    let(:losing_team_snapshot) { create(:snapshot, elo: losing_team_previous_elo, date: "2020-01-01") }
    let(:winning_team_previous_elo) { 1500 }
    let(:losing_team_previous_elo) { 1500 }

    it "creates a snapshot for the winning team" do
      expect { subject }.to change { winning_team.snapshots.count }.by(1)
    end

    it "creates a snapshot for the losing team" do
      expect { subject }.to change { losing_team.snapshots.count }.by(1)
    end

    it "creates snapshots that belong to the game" do
      subject
      expect(winning_team.snapshots.reload.last.game).to eq(game)
      expect(losing_team.snapshots.reload.last.game).to eq(game) 
    end

    it "creates snapshots that have the date of the game end_at" do
      subject
      expect(winning_team.snapshots.reload.last.date).to eq(game.end_at)
      expect(losing_team.snapshots.reload.last.date).to eq(game.end_at)
    end

    it "creates a higher elo snapshot for the team that won" do
      subject
      chance_of_losing = 0.5
      expect(winning_team.snapshots.reload.last.elo).to eq(EloVariables::NEW_TEAM_ELO + (chance_of_losing * EloVariables::K))
    end

    it "creates a lower elo snapshot for the team that lost" do
      subject
      chance_of_winning = 0.5
      expect(losing_team.snapshots.reload.last.elo).to eq(EloVariables::NEW_TEAM_ELO - (chance_of_winning * EloVariables::K))
    end

    context "when the teams are even in elo" do
      it "increases the winning team's elo by half of K" do
        expect { subject }.to change { winning_team.elo }.by(EloVariables::K / 2)
      end

      it "decreases the losing team's elo by half of K" do
        expect { subject }.to change { losing_team.elo }.by(EloVariables::K / -2)
      end
    end

    # Not sure if these tests will be resilient. Might need to calculate chance of winning
    context "when winning team has a lower elo" do
      let(:winning_team_previous_elo) { 1400 }
      let(:losing_team_previous_elo) { 1600 }

      it "greatly increases the winning team's elo" do
        expect { subject }.to change { winning_team.elo }.by(24)
      end

      it "greatly decreases the losing team's elo" do
        expect { subject }.to change { losing_team.elo }.by(-24)
      end
    end

    context "when the winning team has a higher elo" do
      let(:winning_team_previous_elo) { 1600 }
      let(:losing_team_previous_elo) { 1400 }

      it "slightly increases the winning team's elo" do
        expect { subject }.to change { winning_team.elo }.by(8)
      end

      it "slightly decreases the losing team's elo" do
        expect { subject }.to change { losing_team.elo }.by(-8)
      end
    end
  end
end