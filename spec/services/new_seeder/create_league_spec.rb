# frozen_string_literal: true

# Needed for when I want to run individual specs...
require 'rails_helper'

RSpec.describe NewSeeder::CreateLeague do
  describe "#call" do
    let(:response) { { "name"=>"LCS" } }
  
    before do
      allow(PandaScore).to receive(:league).with(id: 4198).and_return(response)
    end

    context "there is a existing league with the same panda_score_id" do
      it "does not create a new league" do
        PandaScore::League.create!(panda_score_id: 4198, data: {})

        expect { described_class.new(4198).call }.not_to change { PandaScore::League.count }
      end

      it "updates the data" do
        league = PandaScore::League.create!(panda_score_id: 4198, data: {})

        expect { described_class.new(4198).call }.to change { league.reload.data }.from({}).to(response)
      end
    end

    it "creates a new league" do
      expect { described_class.new(4198).call }.to change { PandaScore::League.count }.by(1)
    end

    it "the new league has the correct information" do
      described_class.new(4198).call

      expect(PandaScore::League.last.data).to eq(response)
    end
  end
end