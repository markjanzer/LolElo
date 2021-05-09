# frozen_string_literal: true

RSpec.xdescribe MatchFactory do
  describe "#call" do
    subject { MatchFactory.new(match_data: match_data).call }
    let(:match_data) {
      {
        "id" => 1, 
      }
    }

    context "without match_data" do
      let(:match_data) { nil }

      it "raises an error" do
        expect { subject }.to raise_error "match_data is required"
      end
    end

    it "returns a match with set attributes" do
      expect(subject).to have_attributes({
        external_id: 1,
      })
    end

    it "does not create the match" do
      expect(subject).to_not be_persisted
    end
  end
end
