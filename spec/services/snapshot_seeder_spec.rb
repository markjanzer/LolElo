# frozen_string_literal: true

RSpec.describe SnapshotSeeder do
  describe "#call" do
    subject { SnapshotSeeder.new(league).call }
    let(:league) { create(:league) }

    context "if the league is not defined" do
      let(:league) { nil }

      it "raises an error" do
        expect { subject }.to raise_error "league not defined"
      end
    end

    context "when the league does not have any series" do
      it "doesn't create any snapshots" do
        expect { subject }.not_to change { Snapshot.count }
      end
    end

    context "when the league has one series" do

      let(:league) { create(:league, series: [serie]) }
      let(:serie) { create(:serie, tournaments: [tournament], begin_at: Date.current) }
      let(:tournament) { create(:tournament, teams: [team1, team2], matches: matches) }
      let(:matches) { [] }
      let(:team1) { create(:team) }
      let(:team2) { create(:team) }

      context "when the serie has no games" do
        it "creates a snapshot for each team in the serie" do
          subject
          expect(team1.snapshots.count).to eq(1)
          expect(team2.snapshots.count).to eq(1)
        end

        it "create snapshots with elo of the NEW_TEAM_ELO" do
          subject
          expect(team1.snapshots.last.elo).to eq(SnapshotSeeder::NEW_TEAM_ELO)
          expect(team2.snapshots.last.elo).to eq(SnapshotSeeder::NEW_TEAM_ELO)
        end

        it "creates snapshots with the start time of the serie" do
          subject
          expect(Snapshot.first.date).to eq(serie.begin_at)
        end
      end

      # TODO, test that it looks at the matches/games in order

      context "when the series has a match" do
        let(:matches) { create_list(:match, 1, opponent_1: team1, opponent_2: team2, games: games) }
        let(:games) { [game1] }
        let(:game1) { create(:game, winner: team1) }


        it "creates two snapshots for each game" do
          subject
          expect(Snapshot.count).to eq(2 + 2)
        end

        it "creates a higher elo snapshot for the team that won" do
          subject
          chance_of_losing = 0.5
          expect(team1.snapshots.last.elo).to eq(SnapshotSeeder::NEW_TEAM_ELO + (chance_of_losing * SnapshotSeeder::K))
        end

        it "creates a lower elo snapshot for the team that lost" do
          subject
          chance_of_winning = 0.5
          expect(team2.snapshots.last.elo).to eq(SnapshotSeeder::NEW_TEAM_ELO - (chance_of_winning * SnapshotSeeder::K))
        end

        context "when a match has many games" do

          let(:games) { [game1, game2] }
          let(:game2) { create(:game, winner: team1) }

          it "creates a two snapshots for each game" do
            subject
            expect(Snapshot.count).to eq(2 + 2*2)
          end

          # This is going to be really difficult until I have a win_expentancy public method to use
          xit "shows the elo result of all of the games played"
        end
      end
    end

    context "when the league has multiple series" do
      context "between the series" do
        it "reverts existing team elos closer to the RESET_ELO"
        it "sets the reversion snapshot date to the beginning of the year"
        it "sets new team elos to the standard starting elo"
        it "sets new team elos with a date of the beginning of the series"
      end
    end
  end
end