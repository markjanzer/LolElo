# frozen_string_literal: true

# Needed for when I want to run individual specs...
require 'rails_helper'

RSpec.describe ApplicationSeeder::CreateLeague do
  describe "#call" do
    let(:response) { { "name"=>"LCS" } }
    let(:league_id) { 4198 }
  
    before do
      allow(PandaScoreAPI).to receive(:league).with(id: league_id).and_return(response)
    end

    context "there is a existing league with the same panda_score_id" do
      it "does not create a new league" do
        PandaScore::League.create!(panda_score_id: league_id, data: {})

        expect { described_class.new(league_id).call }.not_to change { PandaScore::League.count }
      end

      it "updates the data" do
        league = PandaScore::League.create!(panda_score_id: league_id, data: {})

        expect { described_class.new(league_id).call }.to change { league.reload.data }.from({}).to(response)
      end
    end

    it "creates a new league" do
      expect { described_class.new(league_id).call }.to change { PandaScore::League.count }.by(1)
    end

    it "the new league has the correct information" do
      described_class.new(league_id).call

      expect(PandaScore::League.last.data).to eq(response)
    end

    it "enqueues a job to create series" do
      expect(Seed::EnqueueSeriesCreationJob).to receive(:perform_async).with(league_id)
      described_class.new(league_id).call
    end
  end
end