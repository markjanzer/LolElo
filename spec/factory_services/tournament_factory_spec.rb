# frozen_string_literal: true

RSpec.describe TournamentFactory do
  describe "#call" do
    subject { TournamentFactory.new(tournament_data).call }
    let(:tournament_data) {
      {
        "id" => 1, 
        "name" => "Regular season",
      }
    }

    context "without tournament_data" do
      let(:tournament_data) { nil }

      it "raises an error" do
        expect { subject }.to raise_error "tournament_data is required"
      end
    end

    it "returns a tournament with set attributes" do
      expect(subject).to have_attributes({
        external_id: 1,
        name: "Regular season",
      })
    end

    it "does not create the tournament" do
      expect(subject).to_not be_persisted
    end
  end
end
