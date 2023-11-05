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
end