# frozen_string_literal: true

RSpec.describe GameFactory do
  describe "#call" do
    subject { GameFactory.new(game_data: game_data).call }

    let(:game_data) {
      {
        "id" => 1,
        "end_at" => end_at,
        "winner" => {
          "id" => winner&.external_id
        }
      }
    }

    let(:end_at) { (Date.current).to_s }
    let!(:winner) { create(:team) }

    context "without game_data" do
      let(:game_data) { nil }

      it "raises an error" do
        expect { subject }.to raise_error "game_data is required"
      end
    end

    context "when winning team doesn't exist" do
      let(:winner) { nil }

      it "raises an error" do
        expect { subject }.to raise_error "winning team does not exist"
      end
    end

    it "returns a match with set attributes" do
      expect(subject).to have_attributes({
        external_id: 1,
        end_at: Date.parse(end_at),
        winner: winner
      })
    end

    context "without end_at" do
      let(:game_data) {
        {
          "id" => 1,
          "end_at" => nil,
          "begin_at" => (Date.current - 1.day).to_s,
          "length" => 3600,
          "winner" => {
            "id" => winner&.external_id
          }
        }
      }

      it "calculates end_at from begin_at and length" do
        expect(subject.end_at).to eq(Date.current - 1.day + 3600.seconds)
      end
    end

    it "does not create the game" do
      expect(subject).to_not be_persisted
    end
  end
end
