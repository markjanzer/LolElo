# frozen_string_literal: true

RSpec.describe SnapshotSeeder do
  describe "#call" do
    subject { SnapshotSeeder.new(league).call }
    let(:league) { create(:league) }

    xcontext "if the serie is not defined" do
      it "raises an error" do
        expect { subject }.to raise_error "serie not defined"
      end
    end

    context "when the league does not have any series" do
      it "doesn't create any snapshots" do
        expect { subject }.not_to change { Snapshot.count }
      end
    end

    context "when the league has one series" do
      let(:league) { create(:league, series: series) }
      let(:series) { create_list(:serie, 1) }

      # Need to create teams for the serie
      # Teams belong to tournaments though..

      context "when the serie has no games" do
        it "creates a snapshot for each team in the serie"
        it "create snapshots with elo of the NEW_TEAM_ELO"
      end
    end
  end
end