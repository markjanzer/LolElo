# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InvalidMatchesCorrector do
  describe "#call" do
    subject { InvalidMatchesCorrector.new(matches_data: matches_data, correct_matches_data: correct_matches_data).call }

    # matches_corrections makes more sense here
    # maybe panda_score_matches and matches_corrections
    let(:correct_matches_data) do
      [
        {
          "id" => 1,
          "winner_id" => 1,
          "games" => [
            {
              "begin_at" => "2019-01-26T23:15:12Z"
            }
          ]
        }
      ]
    end

    let(:matches_data) do
      [
        {
          "id" => 1,
          "name" => "C9 vs. TL",
          "winner_id" => 3
        },
        { 
          "id" => 2
        }
      ]
    end
    
    context "matches_data without correct data" do
      it "does not change the match data" do
        expect(subject.second).to eq matches_data.second
      end
    end
    
    context "matches_data with correct data" do
      it "overwrites value from correct data" do
        expect(subject.first["winner_id"]).to eq 1
        expect(subject.first["games"]).to eq correct_matches_data.first["games"]
      end

      it "adds new values from correct data" do
        expect(subject.first["games"]).to eq correct_matches_data.first["games"]
      end

      it "does not change values not in correct data" do
        expect(subject.first["name"]).to eq matches_data.first["name"]
      end
    end

    # it "loads json from faulty_panda_score_match_data.json" do
    #   expect(File).to receive(:read)
    #     .with('./lib/assets/faulty_panda_score_match_data.json')
    # end
  end
end