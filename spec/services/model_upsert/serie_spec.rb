# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ModelUpsert::Serie do
  describe "#call" do
    context "when the serie does not exist" do
      it "creates a serie" do
        panda_score_serie = create(:panda_score_serie, data: {
          full_name: "Spring 2020"
        })
        league = create(:league)
        allow(panda_score_serie).to receive(:league).and_return(league)
        
        expect { described_class.call(panda_score_serie) }.to change { Serie.count }.by(1)
      end
    end

    context "when the serie does exist" do
      it "does not create a new serie" do
        panda_score_serie = create(:panda_score_serie, data: {
          full_name: "Spring 2020"
        })
        league = create(:league)
        allow(panda_score_serie).to receive(:league).and_return(league)
        create(:serie, panda_score_id: panda_score_serie.panda_score_id)

        expect { described_class.call(panda_score_serie) }.not_to change { Serie.count }
      end
    end

    it "sets the serie with correct attributes" do
      league = create(:league)
      time = Time.parse("2020-01-01")
      panda_score_serie = create(:panda_score_serie, data: {
        "year" => 2020,
        "begin_at" => time,
        "full_name" => "Spring 2020",
        "league_id" => league.panda_score_id
      })

      described_class.call(panda_score_serie)
      
      serie = Serie.find_by(panda_score_id: panda_score_serie.panda_score_id)

      expect(serie).to have_attributes(
        panda_score_id: panda_score_serie.panda_score_id,
        year: panda_score_serie.data["year"],
        begin_at: time,
        full_name: panda_score_serie.data["full_name"],
        league: league
      )
    end
  end
end