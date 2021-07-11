# frozen_string_literal: true

# Needed for when I want to run individual specs...
# require 'rails_helper'

RSpec.describe SnapshotSeeder do
  describe "#call" do
    subject { SnapshotSeeder.new(league).call }

    let(:league) { create(:league, series: series) }
    let(:series) { [serie1] }
    let(:serie1) { create(:serie, tournaments: [s1_tournament], begin_at: "2020-01-01", year: 2020) }
    let(:s1_tournament) { create(:tournament, teams: [team1, team2], matches: s1_t1_matches) }
    let(:s1_t1_matches) { [] }
    let(:team1) { create(:team, name: "team1") }
    let(:team2) { create(:team, name: "team2") }

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

    context "when the league has one series" do
      before { subject }

      context "when the series has a match with two games" do
        let(:s1_t1_matches) { create_list(:match, 1, opponent_1: team1, opponent_2: team2, games: s1_t1_m1_games) }
        let(:s1_t1_m1_games) { [s1_t1_m1_game2, s1_t1_m1_game1] }
        let(:s1_t1_m1_game1) { create(:game, winner: team1, end_at: "2020-01-02") }
        let(:s1_t1_m1_game2) { create(:game, winner: team2, end_at: Date.parse("2020-01-02") + 1.hour) }
        
        it "calculates the games in the correct order" do
          team1_elo, team2_elo = [1500, 1500]
          team1_elo1, team2_elo1 = EloCalculator::GameResults.new(winner_elo: team1_elo, loser_elo: team2_elo).new_elos
          team2_elo2, team1_elo2 = EloCalculator::GameResults.new(winner_elo: team2_elo1, loser_elo: team1_elo1).new_elos

          expect(team1.elo).to eq team1_elo2
          expect(team2.elo).to eq team2_elo2
        end
      end

      context "when the series has two matches with a game each" do
        let(:s1_t1_matches) { [s1_t1_match2, s1_t1_match1] }
        let(:s1_t1_match1) { create(:match, opponent_1: team1, opponent_2: team2, games: [s1_t1_m1_game1], end_at: "2020-01-02") }
        let(:s1_t1_m1_game1) { create(:game, winner: team1, end_at: "2020-01-02") }
        let(:s1_t1_match2) { create(:match, opponent_1: team1, opponent_2: team2, games: [s1_t1_m2_game1], end_at: "2020-01-03") }
        let(:s1_t1_m2_game1) { create(:game, winner: team2, end_at: "2020-01-03") }

        it "calculates elos from the matches in the correct order" do
          team1_elo, team2_elo = [1500, 1500]
          team1_elo1, team2_elo1 = EloCalculator::GameResults.new(winner_elo: team1_elo, loser_elo: team2_elo).new_elos
          team2_elo2, team1_elo2 = EloCalculator::GameResults.new(winner_elo: team2_elo1, loser_elo: team1_elo1).new_elos

          expect(team1.elo).to eq team1_elo2
          expect(team2.elo).to eq team2_elo2
        end
      end
    end

    context "when the league has two series in the same year" do
      before { subject }

      let(:series) { [serie2, serie1]}
      let(:s1_t1_matches) { create_list(:match, 1, opponent_1: team1, opponent_2: team2, games: s1_t1_m1_games) }
      let(:s1_t1_m1_games) { create_list(:game, 1, winner: team1, end_at: "2020-01-02") }
      
      let(:serie2) { create(:serie, tournaments: [s2_tournament], begin_at: "2020-06-01", year: 2020) }
      let(:s2_tournament) { create(:tournament, teams: [team1, team2], matches: s2_t1_matches) }
      let(:s2_t1_matches) { create_list(:match, 1, opponent_1: team1, opponent_2: team2, games: s2_t1_m1_games) }
      let(:s2_t1_m1_games) { create_list(:game, 1, winner: team2, end_at: "2020-06-02") }

      it "calculates the series in the correct order" do
        team1_elo, team2_elo = [1500, 1500]
        team1_elo1, team2_elo1 = EloCalculator::GameResults.new(winner_elo: team1_elo, loser_elo: team2_elo).new_elos
        team2_elo2, team1_elo2 = EloCalculator::GameResults.new(winner_elo: team2_elo1, loser_elo: team1_elo1).new_elos

        expect(team1.elo).to eq team1_elo2
        expect(team2.elo).to eq team2_elo2
      end
    end
  end
end