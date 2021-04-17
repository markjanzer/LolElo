# frozen_string_literal: true

RSpec.fdescribe LeagueFactory do
  # Lets fill this out

  describe "#call" do
    subject { LeagueFactory.new(league_id: league_id, time_zone: time_zone).call }
    let(:time_zone) { 'America/Los_Angeles' }

    context "with an invalid league_id" do
      let(:league_id) { 0 }
      it "raises an error" do
        allow(PandaScore).to receive(:league_data).with(league_id).and_return(nil)
        expect { subject }.to raise_error "League not found"
      end
    end
  end
end
