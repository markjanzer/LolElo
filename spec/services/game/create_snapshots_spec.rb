# frozen_string_literal: true

# Needed for when I want to run individual specs...
require 'rails_helper'

RSpec.describe Game::CreateSnapshots do
  describe "#call" do
    subject { Game::CreateSnapshots.new(game).call }

    let!(:serie) { create(:serie, begin_at: "2020-01-01", year: 2020, tournaments: [tournament] )}
    let(:tournament) { create(:tournament, matches: [match]) }
    let!(:match) { create(:match, opponent1: winning_team, opponent2: losing_team, games: [game]) }
    let(:game) { create(:game, winner: winning_team, end_at: "2020-02-01") }
    let(:winning_team) { create(:team, name: "winning_team") }
    let(:losing_team) { create(:team, name: "losing_team") }
    let!(:winning_team_snapshot) { create(:snapshot, elo: 1500, serie: serie, team: winning_team, datetime: "2020-01-01") }
    let!(:losing_team_snapshot) { create(:snapshot, elo: 1500, serie: serie, team: losing_team, datetime: "2020-01-01") }

    context "teams do not have existing elos from this year" do
      let(:winning_team) { create(:team, name: "winning_team", snapshots: []) }
      let(:losing_team) { create(:team, name: "losing_team", snapshots: []) }
      let(:winning_team_snapshot) { nil }
      let(:losing_team_snapshot) { nil }

      it "creates two snapshots for the winning team" do
        expect { subject }.to change { winning_team.snapshots.count }.by 2
      end

      it "creates two snapshots for the losing team" do
        expect { subject }.to change { losing_team.snapshots.count }.by 2
      end
    end
    
    it "creates a snapshot for the winning team" do
      expect { subject }.to change { winning_team.snapshots.count }.by 1
    end

    it "creates a snapshot for the losing team" do
      expect { subject }.to change { losing_team.snapshots.count }.by 1
    end

    it "create snapshots that belong to the serie" do
      subject
      expect(winning_team.snapshots.reload.last.serie).to eq serie
      expect(losing_team.snapshots.reload.last.serie).to eq serie
    end

    it "creates snapshots that are not elo_resets" do
      subject
      expect(winning_team.snapshots.reload.last.elo_reset).to be false
      expect(losing_team.snapshots.reload.last.elo_reset).to be false
    end

    it "creates snapshots that belong to the game" do
      subject
      expect(winning_team.snapshots.reload.last.game).to eq(game)
      expect(losing_team.snapshots.reload.last.game).to eq(game) 
    end

    it "creates snapshots that have datetime of the game end_at" do
      subject
      expect(winning_team.snapshots.reload.last.datetime).to eq(game.end_at)
      expect(losing_team.snapshots.reload.last.datetime).to eq(game.end_at)
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