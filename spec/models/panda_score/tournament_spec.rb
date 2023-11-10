# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PandaScore::Tournament do
  describe "#serie" do
    it "returns the serie from the data" do
      serie = create(:serie)
      panda_score_tournament = create(:panda_score_tournament, data: { "serie_id" => serie.panda_score_id })

      expect(panda_score_tournament.serie).to eq(serie)
    end
  end
end