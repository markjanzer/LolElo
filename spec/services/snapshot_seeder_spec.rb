# frozen_string_literal: true

# Needed for when I want to run individual specs...
require 'rails_helper'

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

      context "when the serie has no games" do
        it "creates a snapshot for each team in the serie" do
          expect(team1.snapshots.count).to eq(1)
          expect(team2.snapshots.count).to eq(1)
        end

        it "create snapshots with elo of the NEW_TEAM_ELO" do
          expect(team1.snapshots.last.elo).to eq(EloVariables::NEW_TEAM_ELO)
          expect(team2.snapshots.last.elo).to eq(EloVariables::NEW_TEAM_ELO)
        end

        it "creates snapshots with the start time of the serie" do
          expect(Snapshot.first.date).to eq(serie1.begin_at)
        end
      end

      # TODO, test that it looks at the matches/games in order

      context "when the series has a match" do
        let(:s1_t1_matches) { create_list(:match, 1, opponent_1: team1, opponent_2: team2, games: s1_t1_m1_games) }
        let(:s1_t1_m1_games) { [s1_t1_m1_game1] }
        let(:s1_t1_m1_game1) { create(:game, winner: team1, end_at: "2020-01-02") }


        it "creates two snapshots for each game" do
          expect(Snapshot.count).to eq(2 + 2)
        end

        it "creates a higher elo snapshot for the team that won" do
          chance_of_losing = 0.5
          expect(team1.snapshots.last.elo).to eq(EloVariables::NEW_TEAM_ELO + (chance_of_losing * EloVariables::K))
        end

        it "creates a lower elo snapshot for the team that lost" do
          chance_of_winning = 0.5
          expect(team2.snapshots.last.elo).to eq(EloVariables::NEW_TEAM_ELO - (chance_of_winning * EloVariables::K))
        end

        context "when a match has many games" do
          let(:s1_t1_m1_games) { [s1_t1_m1_game1, s1_t1_m1_game2] }
          let(:s1_t1_m1_game2) { create(:game, winner: team1, end_at: "2020-01-03") }

          it "creates a two snapshots for each game" do

            expect(Snapshot.count).to eq(2 + (2 * 2))
          end

          # This is going to be really difficult until I have a win_expentancy public method to use
          xit "shows the elo result of all of the games played"
        end
      end
    end

    context "when the league has multiple series in different years" do
      before { subject }

      let(:series) { [serie1, serie2]}
      let(:s1_t1_matches) { create_list(:match, 1, opponent_1: team1, opponent_2: team2, games: s1_t1_m1_games) }
      let(:s1_t1_m1_games) { [s1_t1_m1_game1] }
      let(:s1_t1_m1_game1) { create(:game, winner: team1, end_at: "2020-01-02") }
      
      let(:serie2) { create(:serie, tournaments: [s2_tournament], begin_at: "2021-01-01", year: 2021) }
      let(:s2_tournament) { create(:tournament, teams: [team1, team2, team3], matches: s2_t1_matches) }
      let(:s2_t1_matches) { [s2_t1_match1] }
      let(:s2_t1_match1) { create(:match, opponent_1: team3, opponent_2: team1, games: s2_t1_m1_games) }
      let(:s2_t1_m1_games) { create_list(:game, 1, winner: team3, end_at: "2021-01-03") }
      let(:team3) { create(:team, name: "team3") }

      context "between the series" do
        it "reverts existing team elos closer to the RESET_ELO" do
          team2_elo_at_end_of_series1 = team2.snapshots.where("date < '2020-12-31'").order(date: :desc).first.elo
          new_team2_elo = team2_elo_at_end_of_series1 - ((team2_elo_at_end_of_series1 - EloVariables::RESET_ELO) * EloVariables::RATE_OF_REVERSION).to_i
          expect(team2.snapshots.last.elo).to eq(new_team2_elo)
        end

        it "sets the reversion snapshot date to the beginning of the year" do
          team2_last_snapshot = team2.snapshots.order(date: :desc).first
          expect(team2_last_snapshot.date).to eq("2021-01-01")
        end

        it "sets new team elos to the standard starting elo" do
          team3_first_snapshot = team3.snapshots.order(date: :asc).first
          expect(team3_first_snapshot.elo).to eq(EloVariables::NEW_TEAM_ELO)
        end

        it "sets new team elos with a date of the beginning of the series" do
          team3_first_snapshot = team3.snapshots.order(date: :asc).first
          expect(team3_first_snapshot.date).to eq(serie2.begin_at)
        end
      end
    end
  end
end