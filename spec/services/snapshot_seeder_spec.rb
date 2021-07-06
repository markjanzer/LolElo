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
      let(:serie) { create(:serie, tournaments: [tournament]) }
      let(:tournament) { create(:tournament, teams: [team1, team2]) }
      let(:team1) { create(:team) }
      let(:team2) { create(:team) }

      context "when the serie has no games" do
        it "creates a snapshot for each team in the serie" do
          subject
          expect(team1.snapshots.count).to eq(1)
          expect(team2.snapshots.count).to eq(1)
        end

        it "create snapshots with elo of the NEW_TEAM_ELO"
      end

      context "when the series has a game" do
        it "creates a snapshot with "
      end
    end
  end
end