# frozen_string_literal: true

RSpec.fdescribe LeagueFactory do
  describe "#call" do
    subject { LeagueFactory.new(league_data: league_data, time_zone: time_zone).call }
    let(:league_data) { { "id" => 1, "name" => "First League" } }
    let(:time_zone) { 'America/Los_Angeles' }

    context "without league_data" do
      let(:league_data) { nil }

      it "raises an error" do
        expect { subject }.to raise_error "league_data is required"
      end
    end

    context "without time_zone" do
      let(:time_zone) { nil }

      it "raises an error" do
        expect { subject }.to raise_error "time_zone is required"
      end
    end

    it "returns a league with set attributes" do
      expect(subject).to have_attributes({
        external_id: 1,
        name: "First League",
        time_zone: time_zone
      })
    end

    it "does not create the league" do
      expect(subject).to_not be_persisted
    end
  end
end
