# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PandaScore::Serie do
  describe "#league" do
    it "returns the league from the data" do
      league = create(:league)
      panda_score_serie = create(:panda_score_serie, data: { "league_id" => league.panda_score_id })

      expect(panda_score_serie.league).to eq(league)
    end
  end
end