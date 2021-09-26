# frozen_string_literal: true

RSpec.describe TeamFactory do
  describe "#call" do
    subject { TeamFactory.new(team_data: team_data, serie: serie).call }
    let(:team_data) {
      {
        "id" => 1,
        "name" => "Cloud9",
        "acronym" => "C9"
      }
    }
    let(:serie) { create(:serie) }

    context "without team_data" do
      let(:team_data) { nil }

      it "raises an error" do
        expect { subject }.to raise_error "team_data is required"
      end
    end

    context "without serie" do
      let(:serie) { nil }

      it "raises and error" do
        expect { subject }.to raise_error "serie is required to set the color"
      end
    end

    it "returns a team with set attributes" do
      expect(subject).to have_attributes({
        panda_score_id: team_data["id"],
        name: team_data["name"],
        acronym: team_data["acronym"],
      })
    end

    it "does not create the match" do
      expect(subject).to_not be_persisted
    end
  end
end
