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

    context "with a valid league_id" do
      let(:league_id) { 1 }

      before do
        allow(PandaScore).to receive(:league_data).with(league_id).and_return(
          { "name" => "First League" }
        )
      end

      it "returns a league with set attributes" do
        expect(subject).to have_attributes({
          external_id: league_id,
          name: "First League",
          time_zone: time_zone
        })
      end

      it "does not create the league" do
        expect(subject).to_not be_persisted
      end
    end
  end
end
