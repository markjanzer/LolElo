# frozen_string_literal: true

RSpec.describe MatchFactory do
  describe "#call" do
    subject { MatchFactory.new(match_data).call }
    let(:match_data) {
      {
        "id" => 1, 
        "opponents" => opponents_data
      }
    }
    let(:opponents_data) {
      [
        { 
          "opponent" => { 
            "id" => team1.panda_score_id
          }
        },
        {
          "opponent" => {
            "id" => team2.panda_score_id
          }
        }
      ]
    }

    let(:team1) { create(:team, panda_score_id: 1) }
    let(:team2) { create(:team, panda_score_id: 2) }

    context "without match_data" do
      let(:match_data) { nil }

      it "raises an error" do
        expect { subject }.to raise_error "match_data is required"
      end
    end

    context "when team doesn't exist" do
      let(:opponents_data) {
        [
          { 
            "opponent" => { 
              "id" => 0
            }
          },
          {
            "opponent" => {
              "id" => 0
            }
          }
        ]
      }

      it "raises an error" do
        expect { subject }.to raise_error "team does not exist"
      end
    end

    it "returns a match with set attributes" do
      expect(subject).to have_attributes({
        panda_score_id: 1,
      })
    end

    it "has both teams assigned as opponents" do
      expect(subject.opponent_1).to eq team1
      expect(subject.opponent_2).to eq team2
    end

    it "does not create the match" do
      expect(subject).to_not be_persisted
    end
  end
end
