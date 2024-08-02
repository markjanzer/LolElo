# frozen_string_literal: true

# Needed for when I want to run individual specs...
require 'rails_helper'

RSpec.describe EloSnapshots::LeagueProcessor do
  describe "#call" do
    subject { EloSnapshots::LeagueProcessor.new(league).call }

    let(:league) { create(:league, series: series) }
    let(:series) { [serie1] }
    let(:serie1) { create(:serie, tournaments: [s1_tournament], begin_at: "2020-01-01", year: 2020) }
    let(:s1_tournament) { create(:tournament, teams: [team1, team2], matches: s1_t1_matches) }
    let(:s1_t1_matches) { [] }
    let(:team1) { create(:team, name: "team1") }
    let(:team2) { create(:team, name: "team2") }

=begin
This spec file is testing some weird shit.
It's stuff I wanted tested early, but I'm not really at risk of calculating elos
out of order for two games in a match. Or at least I don't think so

Here's what I want to test.
For two separate games, it creates elos for each in the right order
For series in separate years it creates reset elos for them
It finds the first game without an elo and removes/recalculates elos after that point
    From games as well as serie resets.
=end

    context "if the league is not defined" do
      let(:league) { nil }

      it "raises an error" do
        expect { subject }.to raise_error "league not defined"
      end
    end

    context "when the league does not have any series" do
      before { subject }
      
      let(:series) { [] }

      it "doesn't create any snapshots" do
        expect(Snapshot.count).to eq(0)
      end
    end

    context "when there are two games without snapshots" do
      let(:s1_t1_matches) { create_list(:match, 1, opponent1: team1, opponent2: team2, games: s1_t1_m1_games) }
      let(:s1_t1_m1_games) { [s1_t1_m1_game2, s1_t1_m1_game1] }
      let(:s1_t1_m1_game1) { create(:game, winner: team1, end_at: "2020-01-02") }
      let(:s1_t1_m1_game2) { create(:game, winner: team2, end_at: Date.parse("2020-01-02") + 1.hour) }
      
      it "calculates the games in the correct order" do
        team1_elo, team2_elo = [1500, 1500]
        team1_elo1, team2_elo1 = EloCalculator::GameResults.new(winner_elo: team1_elo, loser_elo: team2_elo).new_elos
        team2_elo2, team1_elo2 = EloCalculator::GameResults.new(winner_elo: team2_elo1, loser_elo: team1_elo1).new_elos

        subject

        expect(team1.elo).to eq team1_elo2
        expect(team2.elo).to eq team2_elo2
      end
    end

    context "when the serie has three games, the first and third of which already has a elo" do
      let(:s1_t1_matches) { create_list(:match, 1, opponent1: team1, opponent2: team2, games: s1_t1_m1_games) }
      let(:s1_t1_m1_games) { [s1_t1_m1_game2, s1_t1_m1_game1, s1_t1_m1_game3] }
      let(:s1_t1_m1_game1) { create(:game, winner: team1, end_at: "2020-01-02") }
      let(:s1_t1_m1_game2) { create(:game, winner: team2, end_at: Date.parse("2020-01-02") + 1.hour) }
      let(:s1_t1_m1_game3) { create(:game, winner: team2, end_at: Date.parse("2020-01-02") + 2.hours) }
      let!(:game1_team1_snapshot) { create(:snapshot, game: s1_t1_m1_game1, team: team1, elo: 2550, datetime: s1_t1_m1_game1.end_at, serie: serie1) }
      let!(:game1_team2_snapshot) { create(:snapshot, game: s1_t1_m1_game1, team: team2, elo: 2450, datetime: s1_t1_m1_game1.end_at, serie: serie1) }
      let!(:game3_team1_snapshot) { create(:snapshot, game: s1_t1_m1_game3, team: team1, elo: 2600, datetime: s1_t1_m1_game3.end_at, serie: serie1) }
      let!(:game3_team2_snapshot) { create(:snapshot, game: s1_t1_m1_game3, team: team2, elo: 2400, datetime: s1_t1_m1_game3.end_at, serie: serie1) }

      it "creates snapshots for games without snapshots" do
        subject
        expect(Snapshot.where(game: s1_t1_m1_game2).count).to eq 2
      end

      it "deletes the snapshots with a date that is after the games without snapshots" do
        subject
        expect(Snapshot.where(id: game3_team1_snapshot.id)).to be_empty
        expect(Snapshot.where(id: game3_team2_snapshot.id)).to be_empty
      end

      it "doesn't delete snapshots with a date that  is before games without snapshots" do
        subject
        expect(Snapshot.where(id: game1_team1_snapshot.id)).to be_present
        expect(Snapshot.where(id: game1_team2_snapshot.id)).to be_present
      end
    end

    context "when the league has two series in different years" do
      let(:series) { [serie0, serie1]}
      let(:s1_t1_matches) { create_list(:match, 1, opponent1: team1, opponent2: team2, games: s1_t1_m1_games) }
      let(:s1_t1_m1_games) { create_list(:game, 1, winner: team1, end_at: "2020-01-02") }
      
      let(:serie0) { create(:serie, tournaments: [s0_tournament], begin_at: "2019-06-01", year: 2020) }
      let(:s0_tournament) { create(:tournament, teams: [team1, team2], matches: s0_t1_matches) }
      let(:s0_t1_matches) { create_list(:match, 1, opponent1: team1, opponent2: team2, games: s0_t1_m1_games) }
      let(:s0_t1_m1_games) { create_list(:game, 1, winner: team2, end_at: "2019-06-02") }

      it "generates a elo reset for both teams" do
        subject
        expect(Snapshot.where(team: team1, datetime: serie0.begin_at, elo_reset: true, serie: serie0)).to be_present
        expect(Snapshot.where(team: team2, datetime: serie0.begin_at, elo_reset: true, serie: serie0)).to be_present
      end

      context "when there are already reset snapshots for the second serie" do
        let!(:t1_s1_reset_snapshot) { create(:snapshot, team: team1, elo: 1500, datetime: serie1.begin_at, elo_reset: true, serie: serie1) }
        let!(:t2_s1_reset_snapshot) { create(:snapshot, team: team2, elo: 1500, datetime: serie1.begin_at, elo_reset: true, serie: serie1) }

        it "removes the previous elo resets" do
          subject

          expect(Snapshot.where(id: t1_s1_reset_snapshot.id)).not_to be_present
          expect(Snapshot.where(id: t2_s1_reset_snapshot.id)).not_to be_present
        end
      end
    end
  end
end