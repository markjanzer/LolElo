# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Updater do
  describe "#call" do

    describe "changes to the series" do
      context "the serie does not exist" do
        it "creates a new serie" do
          league = create(:league)
          allow(PandaScoreAPI).to receive(:series).and_return([{ "id" => 1 }])
          expect { described_class.new.call }.to change { PandaScore::Serie.count }.by(1)
        end
      end

      context "the serie exists" do 
        it "does nothing" do
          league = create(:league)
          create(:panda_score_serie, panda_score_id: 1)
          allow(PandaScoreAPI).to receive(:series).and_return([{ "id" => 1 }])
          expect { described_class.new.call }.not_to change { PandaScore::Serie.count }
        end
      end

    end

    xdescribe "changes to the tournaments" do
      xcontext "the serie is complete" do
        # Do we have a good way of testing this? Maybe we should make thet pandascore api response have a
        # response. Let's take a test of the successful pass and alter it for here.
        it "does nothing" do
          serie_data = { "id" => 1, "end_at" => Time.now }
          serie = create(:panda_score_serie, data: serie_data)

          expect { described_class.new.call }.not_to change { PandaScore::Tournament.count }
        end
      end

      it  "creates a new tournament" do
        serie = create(:panda_score_serie, panda_score_id: 1)
        allow(PandaScoreAPI).to receive(:tournaments).and_return([{ "id" => 1 }])
        expect { described_class.new.call }.to change { PandaScore::Tournament.count }.by(1)
      
      end

      xcontext "the tournament exists" do
        it "does nothing" do
          league = create(:league)
          serie = create(:serie)

        end
      end
    end
  end
end