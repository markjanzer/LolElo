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
    let(:winning_team_snapshot) { create(:snapshot, elo: 1500, date: "2020-01-01") }
    let(:losing_team_snapshot) { create(:snapshot, elo: 1500, date: "2020-01-01") }

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
      expect(winning_team.snapshots.reload.last.elo).to be > 1500
    end

    it "creates a lower elo snapshot for the team that lost" do
      subject
      expect(losing_team.snapshots.reload.last.elo).to be < 1500
    end
  end
end