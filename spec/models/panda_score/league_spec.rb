# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PandaScore::League do
  describe "#panda_score_series" do
    it "returns the series for the league" do
      panda_score_league = create(:panda_score_league, panda_score_id: 1, data: { "series" => [{ "id" => 2 }] })
      panda_score_serie = create(:panda_score_serie, panda_score_id: 2, data: { "id" => 2, "league_id" => 1 })

      expect(panda_score_league.panda_score_series).to eq([panda_score_serie])
    end
  end

  describe "#create_new_series" do
    it "creates new series for the league" do
      panda_score_league = create(:panda_score_league, panda_score_id: 1)
      allow(PandaScoreAPI).to receive(:series).with(league_id: 1).and_return([{ "id" => 2 }])
      expect { panda_score_league.create_new_series }.to change { PandaScore::Serie.count }.by(1)
    end

    it "does not create a series that already exists" do
      panda_score_league = create(:panda_score_league, panda_score_id: 1)
      create(:panda_score_serie, panda_score_id: 2, data: { "id" => 2, "league_id" => 1 })
      allow(PandaScoreAPI).to receive(:series).with(league_id: 1).and_return([{ "id" => 2 }])
      expect { panda_score_league.create_new_series }.not_to change { PandaScore::Serie.count }
    end
  end
end