# frozen_string_literal: true

RSpec.describe LeagueFactory do
  # Lets fill this out

  describe "#call" do
    subject { LeagueFactory.new(league_id: league_id, time_zone: time_zone).call }
    let(:time_zone) { 'America/Los_Angeles' }

    context "with an invalid league_id" do
      allow(PandaScore).to receive(:league_data, league_id) { nil }
      it "raises an error" do
        expect(subject).to raise "Yo this ain't right"
      end
    end
  end
end
